extends Node


#游戏中分数
const scoreList=[100,200,400,500,800,1000,2000,4000,5000,8000]
const koopaScore=[500, 800, 1000, 2000, 4000, 5000, 8000]
var fireBallScore={goomba:100,koopa:200,plant:200,bloober:200,
cheapcheap:200,flyingfish:200,hammerBro:1000,lakitu:200,spiny:200}

#类型
const empty="empty"
const mario="mario"
const goomba="goomba"
const koopa="koopa"
const mushroom="mushroom"
const star="star"
const fireflower="fireflower"
const coin="coin"
const mushroom1up="mushroom1up"
const fireball="fireball"
const coins6="coins6"
const box="box"
const brick='brick'
const brickPiece="brickPiece"
const pipe="pipe"
const bg='background'
const pole ='pole'
const checkPoint="checkPoint" #死亡后的检查点
const castlePos="castlePos"  #城堡大门
const plant="plant"
const pipeIn="pipeIn"  #水管进入
const pipeOut="pipeOut" #水管出去
const bigCoin='bigCoin'
const platform="platform"
const collision='collision'	#碰撞体
const beetle="beetle"#甲壳虫
const castleFlag="castleFlag"
const spinFireball='spinFireball'  #旋转的火焰
const bridge='bridge'  #桥
const bowser='bowser' #关底boss
const fire='fire' #火焰
const axe='axe'  #斧头
const vine='vine' #藤曼
const jumpingBoard='jumpingBoard'  #跳板
const cheapcheap='cheapcheap' #飞鸟
const bloober='bloober' #乌贼
const podoboo='podoboo' #火焰
const bulletBill='bulletBill' #大子弹
const lakitu='lakitu' #天上飞的云朵
const hammerBro='hammerBro' #锤子兄弟
const bubble='bubble' #气泡
const spiny='spiny' #有刺的
const hammer='hammer' #锤子
const cannon='cannon' #炮塔
const linkPlatform='linkPlatform' #联动平台
const staticPlatform='staticPlatform' #基本不动的平台
const flyingfish='flyingfish' #飞鱼
const maze='maze'
const mazeGate='mazeGate'

#方向
const right="right"
const left="left"
const down="down"
const up="up"
