"""extract_level_buttons.py — 从 menu/levels.png 图集中提取"无数字"的关卡按钮底图。

原图集中 menu/levels/buttons/{normal,active,disabled}/{1..15}.png 每张都烘焙了数字，
导致关卡数量被锁死在 15。本脚本把数字当作"墨迹"擦除，输出 3 张通用底图：

    sprites/atlas/level_btn_normal.png     (绿色，已通关)
    sprites/atlas/level_btn_active.png     (橙色，当前可玩)
    sprites/atlas/level_btn_disabled.png   (灰色，未解锁)

数字改由 Godot 的 Label 动态绘制（见 scripts/menu/level_btn.gd），因此关卡数量不再受限。

原理：按钮内圈是纯色填充，数字是唯一"墨迹"。
  1. 统计内圈出现最多的颜色作为底色 fill；
  2. 找出与 fill 差异 > 28 的连通域，其中"不接触图像边界"的就是数字（边框/外描边一定接触边界）；
  3. 从数字出发，在"与 fill 差异 > 4"的像素上做洪水填充，连抗锯齿描边一起吃掉；
  4. 把这些像素刷成 fill —— 因为底色本来是纯色，结果和原画无差别。

用法: python tools/extract_level_buttons.py
"""
import json
import os
from collections import Counter, defaultdict
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ATLAS_PNG = os.path.join(ROOT, "sprites", "menu", "levels.png")
ATLAS_JSON = os.path.join(ROOT, "sprites", "menu", "levels.json")
OUT_DIR = os.path.join(ROOT, "sprites", "atlas")

STATES = ["normal", "active", "disabled"]
TARGET_SIZE = (67, 60)      # 三种状态统一尺寸（原图 66~71 px）
SEED_THRESHOLD = 28         # 认定"墨迹"的色差阈值
FLOOD_THRESHOLD = 4         # 顺带清掉抗锯齿描边的色差阈值

# 数字颜色（取自原画）+ 共用高光色，供 Godot 端 Label 使用
INK_COLORS = {
    "normal": (74, 78, 1),
    "active": (199, 54, 1),
    "disabled": (120, 84, 71),
}
HIGHLIGHT = (255, 254, 187)


def max_channel_dist(c, f):
    return max(abs(c[0] - f[0]), abs(c[1] - f[1]), abs(c[2] - f[2]))


def load_groups():
    with open(ATLAS_JSON, encoding="utf-8") as f:
        frames = json.load(f)["frames"]
    groups = defaultdict(list)
    for key, info in frames.items():
        parts = key.split("/")
        if parts[:3] == ["menu", "levels", "buttons"] and len(parts) == 5:
            groups[parts[3]].append((int(parts[4].replace(".png", "")), info["frame"]))
    return groups


def find_components(mask, w, h):
    """8 连通域标记，返回 [(pixels, touches_border), ...]"""
    seen = [[False] * w for _ in range(h)]
    out = []
    for sy in range(h):
        for sx in range(w):
            if not mask[sy][sx] or seen[sy][sx]:
                continue
            stack = [(sx, sy)]
            seen[sy][sx] = True
            pixels = []
            touches_border = False
            while stack:
                x, y = stack.pop()
                pixels.append((x, y))
                if x == 0 or y == 0 or x == w - 1 or y == h - 1:
                    touches_border = True
                for dy in (-1, 0, 1):
                    for dx in (-1, 0, 1):
                        nx, ny = x + dx, y + dy
                        if 0 <= nx < w and 0 <= ny < h and mask[ny][nx] and not seen[ny][nx]:
                            seen[ny][nx] = True
                            stack.append((nx, ny))
            out.append((pixels, touches_border))
    return out


def detect_fill(px, w, h):
    """内圈（避开圆角边框）出现最多的颜色即纯色底。"""
    inset = 9
    counter = Counter()
    for y in range(inset, h - inset):
        for x in range(inset, w - inset):
            if px[x, y][3] > 200:
                counter[px[x, y]] += 1
    return counter.most_common(1)[0][0]


def remove_digit(img):
    """擦除按钮中央的数字，返回 (清理后的图, 数字包围盒, 底色)。"""
    w, h = img.size
    px = img.load()
    fill = detect_fill(px, w, h)

    seed = [[max_channel_dist(px[x, y], fill) > SEED_THRESHOLD for x in range(w)]
            for y in range(h)]
    floodable = [[max_channel_dist(px[x, y], fill) > FLOOD_THRESHOLD for x in range(w)]
                 for y in range(h)]

    # 墨迹连通域里最大的那个（不接触边界的）就是数字
    digit = None
    for pixels, touches_border in find_components(seed, w, h):
        if touches_border:
            continue
        if digit is None or len(pixels) > len(digit):
            digit = pixels
    if digit is None:
        raise RuntimeError("未找到数字墨迹，按钮可能没有数字或阈值需要调整")

    # 从数字出发洪水填充，把抗锯齿描边一起吃干净
    start = digit[0]
    visited = [[False] * w for _ in range(h)]
    visited[start[1]][start[0]] = True
    stack = [start]
    erase = []
    while stack:
        x, y = stack.pop()
        erase.append((x, y))
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and floodable[ny][nx] and not visited[ny][nx]:
                    visited[ny][nx] = True
                    stack.append((nx, ny))

    bbox = (min(p[0] for p in erase), min(p[1] for p in erase),
            max(p[0] for p in erase) + 1, max(p[1] for p in erase) + 1)

    out = img.copy()
    opx = out.load()
    for (x, y) in erase:
        opx[x, y] = fill
    return out, bbox, fill


def main():
    groups = load_groups()
    atlas = Image.open(ATLAS_PNG).convert("RGBA")
    os.makedirs(OUT_DIR, exist_ok=True)

    results = {}
    for state in STATES:
        candidates = [(num, fr) for num, fr in sorted(groups[state])
                      if (fr["w"], fr["h"]) == TARGET_SIZE]
        if not candidates:
            candidates = sorted(groups[state])

        # 挑数字最窄的一帧（数字 "1"），需要修补的面积最小
        best = None
        for num, fr in candidates:
            crop = atlas.crop((fr["x"], fr["y"], fr["x"] + fr["w"], fr["y"] + fr["h"]))
            cleaned, bbox, fill = remove_digit(crop)
            area = (bbox[2] - bbox[0]) * (bbox[3] - bbox[1])
            if best is None or area < best[0]:
                best = (area, num, cleaned, bbox, fill)

        _, num, cleaned, bbox, fill = best
        results[state] = cleaned

        out_path = os.path.join(OUT_DIR, "level_btn_%s.png" % state)
        cleaned.save(out_path)
        print("[%s] 底图取自原数字 %d，%dx%d，底色 %s，擦除区域 %s"
              % (state, num, cleaned.width, cleaned.height, fill, bbox))
        print("   -> %s" % os.path.relpath(out_path, ROOT))

        # 校验：擦除区域现在应该和底色完全一致
        px = cleaned.load()
        bad = sum(1 for y in range(bbox[1], bbox[3]) for x in range(bbox[0], bbox[2])
                  if max_channel_dist(px[x, y], fill) > 2)
        print("   擦除区域残留: %d 像素（应为 0）" % bad)

    make_preview(results)


def make_preview(results):
    """用游戏字体把数字画在底图上，生成对照预览图。"""
    font_path = os.path.join(ROOT, "fonts", "gunplay.ttf")
    numbers = [1, 2, 3, 8, 10, 15, 26, 120]
    cols, rows = len(numbers), len(STATES)
    cell_w, cell_h = 90, 80
    pad = 20
    sheet = Image.new("RGBA", (pad * 2 + cols * cell_w, pad * 2 + rows * cell_h),
                      (58, 58, 58, 255))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.truetype(font_path, 34)

    for r, state in enumerate(STATES):
        base = results[state]
        for c, num in enumerate(numbers):
            cx = pad + c * cell_w
            cy = pad + r * cell_h
            sheet.alpha_composite(base, (cx + (cell_w - base.width) // 2,
                                         cy + (cell_h - base.height) // 2))
            text = str(num)
            tw = draw.textlength(text, font=font)
            tx = cx + (cell_w - tw) / 2
            ty = cy + (cell_h - 34) / 2 - 4
            # 左上高光（模拟原画的立体描边）
            for ox, oy in ((-2, -2), (-1, -2), (-2, -1), (-1, -1)):
                draw.text((tx + ox, ty + oy), text, font=font, fill=HIGHLIGHT + (255,))
            draw.text((tx, ty), text, font=font, fill=INK_COLORS[state] + (255,))

    out = os.path.join(ROOT, "tools", "_tmp_preview.png")
    sheet.save(out)
    print("\n预览图（数字由字体动态绘制）: %s" % out)


if __name__ == "__main__":
    main()
