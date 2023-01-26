extends Node
#保存所有的常量

#游戏中分数
const scoreList=[100,200,400,500,800,1000,2000,4000,5000,8000]
const koopaScore=[500, 800, 1000, 2000, 4000, 5000, 8000]

#游戏状态
const stateChange='stateChange'
const startState='startState'
const freeze="freeze"
const flagDown="flagDown"  #mario下降旗
const inCastle="inCastle" #在城堡里面
const pause="pause"
const gameEnd="gameEnd"
const nextLevel="nextLevel"
const gameIdle="gameIdle"
const gameRestart="gameRestart"
const nextSublevel="nextSublevel" #mario从水管或者树里面进入
const loadSublevel="loadSublevel" #mario从水管或者树里面出现

#方块状态
const resting="resting"  #静止
const bumped="bumped"	#突起
const opened="opened"	#已打开

#蘑菇 星星状态
const growing="growing" #出现
const moving="moving" #移动
const stop="stop"
const jumping="jumping"

#敌人的状态
const walking="walking"
const dead="dead"
const deadJump="deadJump"
const sliding="sliding"
const shell='shell'
const plantOut="plantOut"
const plantIn="plantIn"
const revive="revive" #复活
const flying='flying' #飞行
const koopaJump='koopaJump'
const figures='figures' #人物


#子弹状态
const fly='fly' 
const boom='boom'

#旗杆状态
const flagLanding="flagLanding"

#时间状态
const countDown="countDown"
const fastCountDown="fastCountDown"

#旗子的状态
const rising="rising"

#旋转火球的状态
const rotate='rotate'

#跳板状态
const boardStretch='boardStretch'

#其他的状态
const spin="spin"

#平台的状态
const moveUp="moveUp"
const moveDown="moveDown"
const upAndDown='upAndDown'
const leftAndRight='leftAndRight'

#乌贼的状态
const upward='upward'
const downward='downward'
const blooberAcceleration=500
const blooberMaxXSpeed=700
const blooberMaxYSpeed=700

#火焰的数据
const podobooGravity=500
const podobooIdle='podobooIdle'

#Spiny数据
const spinyEgg='spinyEgg'

#lakitu数据
const lakituIdle='lakituIdle'
const lakituDistance=32*3

#mario的状态
const idle="idle"
const stand="stand"
const walk="walk"
const jump ="jump"
const fall="fall"
const small2big="small2big"
const big2fire="big2fire"
const big2small="big2small"
const crouch="crouch"
const poleSliding='poleSliding' #在旗杆上下降
const walkingToCastle="walkingToCastle"#走到城堡里面
const sitBottomOfPole="sitBottomOfPole" #旗已经到了底部
#const pipeIn='pipeIn'
#const pipeOut='pipeOut'
const walkInPipe="walkInPipe" #走到水管里
const onlywalk='onlywalk' #自动往前走
const grabVine='grabVine' #爬藤蔓
const autoGrabVine='autoGrabVine' #从藤蔓爬出来
const onBoard='onBoard' #在跳板上
const swim="swim" #


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


#方向
const right="right"
const left="left"
const down="down"
const up="up"

#mario 数据
#var mario_speed=180
#var mario_max_speed=300		#跑的时候最大速度

#var runAccel=8 #奔跑加速度
#var friction=9	#摩檫力
#var animation_speed=120	#动画速度
#var gravity=1100	#重力
#const gravityJump=700	#跳跃的时候重力

#const dropSpeed=400 #下落最大速度
#const jumpSpeed=400	#跳跃高度

#敌人的数据
const enemyGravity=1700
const enemyJumpGravity=1000
const enemyMaxVel=900
const bowserGravity=300

#气泡y速度
const bubbleMaxVel=190

const fireballGravity=1600

const slideFriction=700 #滑行的加速度
const crouchFriction=440 #蹲下去时加速度
const acceleration=240	#移动加速度
const runAcceleration=400 #跑的加速度
const marioWalkMaxSpeed=170 #走的时候最大速度
const marioRunMaxSpeed=340 #跑的时候最大速度
const marioAniSpeed=100
const marioGravity=1800 #重力
const marioJumpGravity=1000
const marioUnderWaterGravity=800 #水下重力
const marioJumpSpeed=500
const marioDeathGravity=1000
const boxGravity=1800 #箱子重力
const deathJumpGravity=1200
const marioMaxYVel=900 #最大y速度
const boxHeight=5 #跨过的间隙时最低的高度
const fireballMaxYVel=900
const underwaterMaxHeight=16 #在水下最大高度
const underwaterAcceleration=180
const underwaterRunAcceleration=300
const underwaterWalkMaxSpeed=110
const underwaterRunMaxSpeed=280
const underwatermarioMaxYVel=220 #水下最大y速度

#图块类型
const tilesType=['del',"mario","goomba","koopa","brick","pipe"
			,"coin","bg","box",'flag','stick',"collision","plant","castleFlag",
			"pipeIn",'platform','mushroom','mushroom1up','fireflower','star',
			'spinFireball','pipeOut','bridge','bowser','figures','axe','jumpingBoard',
			'cheapcheap','bloober','podoboo','lakitu']

#图块 所有的图块
#const tiles=['del',"mario","goomba","koopa","brick","pipe"
#			,"coin","bg","box","box_blue",'box_grey','box_default']
			
const allTitle=[{'name':'del','type':'del'},
{'name':"mario",'type':'mario'},{'name':"koopa",'type':'koopa'},
{'name':"brick",'type':'brick'},{'name':"pipe",'type':'pipe'},
{'name':"coin",'type':'coin'},{'name':"bg",'type':'bg'},{
	'name':"box",'type':'box'},{'name':"box_blue",'type':'box'},
	{'name':"box_grey",'type':'box'},{'name':"box_default",'type':'box'}]
			
#图块属性  只有名字没有数字为默认属性
const tilesAttribute={
	"del":{
		"type": "del",
		"spriteIndex": 0,
		"x": 0,
		"y": 0
	},
	"mario": {
		"type": "mario",
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"goomba": {
		"type": "goomba",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"goomba01": {
		"type": "goomba",
		"spriteIndex": 1,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"goomba02": {
		"type": "goomba",
		"spriteIndex": 2,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"koopa": {
		"type": "koopa",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'ySpeed':100,  #用来设置飞行状态时的一个速度
		'layer':0,
	},
	"koopa01": {
		"type": "koopa",
		"spriteIndex": 1,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'ySpeed':100, 
		'layer':0,
	},
	"koopa02": {
		"type": "koopa",
		"spriteIndex": 2,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'ySpeed':100, 
		'layer':0,
	},
	"koopa03": {
		"type": "koopa",
		"spriteIndex": 3,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'ySpeed':100, 
		'layer':0,
	},
	"koopafly04": {
		"type": "koopa",
		"spriteIndex": 4,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'ySpeed':100, 
		'layer':0,
	},
	"koopafly05": {
		"type": "koopa",
		"spriteIndex": 5,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'ySpeed':100, 
		'layer':0,
	},
	"koopafly06": {
		"type": "koopa",
		"spriteIndex": 6,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'ySpeed':100, 
		'layer':0,
	},
	"koopafly07": {
		"type": "koopa",
		"spriteIndex": 7,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'ySpeed':100, 
		'layer':0,
	},
	"koopajump08": {
		"type": "koopa",
		"spriteIndex": 8,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'ySpeed':100, 
		'layer':0,
	},
	"koopajump09": {
		"type": "koopa",
		"spriteIndex": 9,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'ySpeed':100, 
		'layer':0,
	},
	"koopajump10": {
		"type": "koopa",
		"spriteIndex": 10,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'ySpeed':100, 
		'layer':0,
	},
	"koopajump11": {
		"type": "koopa",
		"spriteIndex": 11,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'ySpeed':100, 
		'layer':0,
	},
	'cheapcheap':{
		"type": "cheapcheap",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'status':'swim',
		'layer':0,
	},
	'cheapcheap1':{
		"type": "cheapcheap",
		"spriteIndex": 1,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'status':'swim',
		'layer':0,
	},
	'cheapcheap2':{
		"type": "cheapcheap",
		"spriteIndex": 2,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'status':'swim',
		'layer':0,
	},
	'cheapcheap3':{
		"type": "cheapcheap",
		"spriteIndex": 3,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'status':'swim',
		'layer':0,
	},
	'bloober':{
		"type": "bloober",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	'bloober1':{
		"type": "bloober",
		"spriteIndex": 1,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	'bloober2':{
		"type": "bloober",
		"spriteIndex": 2,
		"x": 0,
		"y": 0,
		'dir': 'left',
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	'podoboo':{
		"type": "podoboo",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		'dir': 'up',
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	'lakitu':{
		"type": "lakitu",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		'dir': 'up',
		"offsetX":0,
		"offsetY":0,
		'layer':0,
		'end':0,
	},
	'lakitu1':{
		"type": "lakitu",
		"spriteIndex": 1,
		"x": 0,
		"y": 0,
		'dir': 'up',
		"offsetX":0,
		"offsetY":0,
		'layer':0,
		'end':0,
	},
	'lakitu2':{
		"type": "lakitu",
		"spriteIndex": 2,
		"x": 0,
		"y": 0,
		'dir': 'up',
		"offsetX":0,
		"offsetY":0,
		'layer':0,
		'end':0,
	},
	'figures':{
		"type": "figures",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	'figures1':{
		"type": "figures",
		"spriteIndex": 1,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	'axe':{
		"type": "axe",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	'jumpingBoard1':{
		"type": "jumpingBoard",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	'jumpingBoard2':{
		"type": "jumpingBoard",
		"spriteIndex": 1,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"checkPoint":{
		"type":"collision",
		"spriteIndex": 1,
		"x": 0,
		"y": 0,
		"value":"checkPoint",
		'layer':0,
	},
	"castlePos":{
		"type":"collision",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"value":"castlePos",
		'layer':0,
	},
	"subLevelPos":{
		"type":"collision",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"value":"subLevelPos",
		"pos":0,
		'layer':0,
	},
	"castleFlag":{
		"type":"castleFlag",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		'layer':0,
	},
	"plant":{
		"type":"plant",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":-6,
		'layer':0,
	},
	"bowser0":{
		"type":"bowser",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"bowser1":{
		"type":"bowser",
		"spriteIndex": 1,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"bowser2":{
		"type":"bowser",
		"spriteIndex": 2,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	'spinFireball':{
		"type": "spinFireball",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"len":6,
		"offsetX":0,
		"offsetY":0,
		'layer':1,
	},
	"flag":{
		"type": "flag",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"len":2,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"coin": {
		"type": "coin",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	'platform':{
		"type": "platform",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'lens':1,
		'platformType':"moveDown",
		'dir':up,
		'speed':100,
		'layer':0,
	},
	'platformleft':{
		"type": "platform",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'lens':1,
		'platformType':"leftAndRight",
		'dir':left,
		'speed':100,
		'layer':0,
	},
	"box": {
		"type": "box",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"content": empty,
		"visible": "t",
		"offsetX":0,
		"offsetY":0,
		'level':"",
		"subLevel":'',
		"itemIndex":0,
		'layer':0,
	},
	"box_blue": {
		"type": "box",
		"spriteIndex": 1,
		"x": 0,
		"y": 0,
		"content": empty,
		"visible": "t",
		"offsetX":0,
		"offsetY":0,
		'level':"",
		"subLevel":'',
		"itemIndex":0,
		'layer':0,
	},
	"box_grey": {
		"type": "box",
		"spriteIndex": 2,
		"x": 0,
		"y": 0,
		"content": empty,
		"visible": "t",
		"offsetX":0,
		"offsetY":0,
		'level':"",
		"subLevel":'',
		"itemIndex":0,
		'layer':0,
	},
	"box_default": {
		"type": "box",
		"spriteIndex": 3,
		"x": 0,
		"y": 0,
		"content": "mushroom",
		"visible": "t",
		"offsetX":0,
		"offsetY":0,
		'level':"",
		"subLevel":'',
		"itemIndex":0,
		'layer':0,
	},
	"box_coin": {
		"type": "box",
		"spriteIndex": 3,
		"x": 0,
		"y": 0,
		"content": "coin",
		"visible": "t",
		"offsetX":0,
		"offsetY":0,
		'level':"",
		"subLevel":'',
		"itemIndex":0,
		'layer':0,
	},
	"box_star": {
		"type": "box",
		"spriteIndex": 3,
		"x": 0,
		"y": 0,
		"content": "star",
		"visible": "t",
		"offsetX":0,
		"offsetY":0,
		'level':"",
		"subLevel":'',
		"itemIndex":0,
		'layer':0,
	},
	"box_flower": {
		"type": "box",
		"spriteIndex": 3,
		"x": 0,
		"y": 0,
		"content": "fireflower",
		"visible": "t",
		"offsetX":0,
		"offsetY":0,
		'level':"",
		"subLevel":'',
		"itemIndex":0,
		'layer':0,
	},
	"box4": {
		"type": "box",
		"spriteIndex": 4,
		"x": 0,
		"y": 0,
		"content": empty,
		"visible": "t",
		"offsetX":0,
		"offsetY":0,
		'level':"",
		"subLevel":'',
		"itemIndex":0,
		'layer':0,
	},
	"box5": {
		"type": "box",
		"spriteIndex": 5,
		"x": 0,
		"y": 0,
		"content": empty,
		"visible": "t",
		"offsetX":0,
		"offsetY":0,
		'level':"",
		"subLevel":'',
		"itemIndex":0,
		'layer':0,
	},
	"box6": {
		"type": "box",
		"spriteIndex": 6,
		"x": 0,
		"y": 0,
		"content": empty,
		"visible": "t",
		"offsetX":0,
		"offsetY":0,
		'level':"",
		"subLevel":'',
		"itemIndex":0,
		'layer':0,
	},
	"brick": {
		"type": "brick",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick2": {
		"type": "brick",
		"spriteIndex": 1,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick3": {
		"type": "brick",
		"spriteIndex": 2,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick4": {
		"type": "brick",
		"spriteIndex": 3,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick5": {
		"type": "brick",
		"spriteIndex": 4,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick6": {
		"type": "brick",
		"spriteIndex": 5,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick7": {
		"type": "brick",
		"spriteIndex": 6,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick8": {
		"type": "brick",
		"spriteIndex": 7,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick9": {
		"type": "brick",
		"spriteIndex": 8,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick10": {
		"type": "brick",
		"spriteIndex": 9,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick11": {
		"type": "brick",
		"spriteIndex": 10,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick12": {
		"type": "brick",
		"spriteIndex": 11,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick13": {
		"type": "brick",
		"spriteIndex": 12,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick14": {
		"type": "brick",
		"spriteIndex": 13,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick15": {
		"type": "brick",
		"spriteIndex": 14,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick16": {
		"type": "brick",
		"spriteIndex": 15,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick17": {
		"type": "brick",
		"spriteIndex": 16,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick18": {
		"type": "brick",
		"spriteIndex": 17,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick19": {
		"type": "brick",
		"spriteIndex": 18,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick20": {
		"type": "brick",
		"spriteIndex": 19,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick21": {
		"type": "brick",
		"spriteIndex": 20,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick22": {
		"type": "brick",
		"spriteIndex": 21,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick23": {
		"type": "brick",
		"spriteIndex": 22,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick24": {
		"type": "brick",
		"spriteIndex": 23,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick25": {
		"type": "brick",
		"spriteIndex": 24,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick26": {
		"type": "brick",
		"spriteIndex": 25,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick27": {
		"type": "brick",
		"spriteIndex": 26,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick28": {
		"type": "brick",
		"spriteIndex": 27,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick29": {
		"type": "brick",
		"spriteIndex": 28,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick30": {
		"type": "brick",
		"spriteIndex": 29,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick31": {
		"type": "brick",
		"spriteIndex": 30,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick32": {
		"type": "brick",
		"spriteIndex": 31,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick33": {
		"type": "brick",
		"spriteIndex": 32,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick34": {
		"type": "brick",
		"spriteIndex": 33,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick35": {
		"type": "brick",
		"spriteIndex": 34,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick36": {
		"type": "brick",
		"spriteIndex": 35,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick37": {
		"type": "brick",
		"spriteIndex": 36,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick38": {
		"type": "brick",
		"spriteIndex": 37,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick39": {
		"type": "brick",
		"spriteIndex": 38,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick40": {
		"type": "brick",
		"spriteIndex": 39,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"brick41": {
		"type": "brick",
		"spriteIndex": 40,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"bridge": {
		"type": "bridge",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"offsetX":0,
		"offsetY":0,
		'layer':0,
	},
	"pipe": {
	"type": "pipe",
	"spriteIndex": 0,
	"x": 0,
	"y": 0,
	"rotate":0,
	"offsetX":0,
	"offsetY":0,
	"pipeType":empty,
	"pipeNo":0,
	"level":"",
	"subLevel":"",
	"dir":down,
	"warpzoneNum":'',
	'layer':0,
	},
	"pipe1": {
	"type": "pipe",
	"spriteIndex": 1,
	"x": 0,
	"y": 0,
	"rotate":0,
	"offsetX":0,
		"offsetY":0,
		"pipeType":empty,
	"pipeNo":0,
	"level":"",
	"subLevel":"",
	"dir":down,
	"warpzoneNum":'',
	'layer':0,
	},
	"pipe2": {
	"type": "pipe",
	"spriteIndex": 2,
	"x": 0,
	"y": 0,
	"rotate":0,
	"pipeType":empty,
	"pipeNo":0,
	"level":"",
	"subLevel":"",
	"dir":down,
	"warpzoneNum":'',
	'layer':0,
	},
	"pipe3": {
	"type": "pipe",
	"spriteIndex": 3,
	"x": 0,
	"y": 0,
	"rotate":0,
	"pipeType":empty,
	"pipeNo":0,
	"level":"",
	"subLevel":"",
	"dir":down,
	"warpzoneNum":'',
	'layer':0,
	},
	"pipe4": {
	"type": "pipe",
	"spriteIndex": 4,
	"x": 0,
	"y": 0,
	"rotate":0,
	"pipeType":empty,
	"pipeNo":0,
	"level":"",
	"subLevel":"",
	"dir":down,
	"warpzoneNum":'',
	'layer':0,
	},
	"pipe5": {
	"type": "pipe",
	"spriteIndex": 5,
	"x": 0,
	"y": 0,
	"rotate":0,
	"pipeType":empty,
	"pipeNo":0,
	"level":"",
	"subLevel":"",
	"dir":down,
	"warpzoneNum":'',
	'layer':0,
	},
	"pipe6": {
	"type": "pipe",
	"spriteIndex": 6,
	"x": 0,
	"y": 0,
	"rotate":0,
	"pipeType":empty,
	"pipeNo":0,
	"level":"",
	"subLevel":"",
	"dir":down,
	"warpzoneNum":'',
	'layer':0,
	},
	"pipe7": {
	"type": "pipe",
	"spriteIndex": 7,
	"x": 0,
	"y": 0,
	"rotate":0,
	"pipeType":empty,
	"pipeNo":0,
	"level":"",
	"subLevel":"",
	"dir":down,
	"warpzoneNum":'',
	'layer':0,
	},
	"pipe8": {
	"type": "pipe",
	"spriteIndex": 8,
	"x": 0,
	"y": 0,
	"rotate":0,
	"pipeType":empty,
	"pipeNo":0,
	"level":"",
	"subLevel":"",
	"dir":down,
	"warpzoneNum":'',
	'layer':0,
	},
	"pipe9": {
	"type": "pipe",
	"spriteIndex": 9,
	"x": 0,
	"y": 0,
	"rotate":0,
	"pipeType":empty,
	"pipeNo":0,
	"level":"",
	"subLevel":"",
	"dir":down,
	"warpzoneNum":'',
	'layer':0,
	},
	"bg": {
		"type": "bg",
		"spriteIndex": 0,
		"x": 0,
		"y": 0
	},
	"bg1": {
		"type": "bg",
		"spriteIndex": 1,
		"x": 0,
		"y": 0
	},
	"bg2": {
		"type": "bg",
		"spriteIndex": 2,
		"x": 0,
		"y": 0
	},
	"bg3": {
		"type": "bg",
		"spriteIndex": 3,
		"x": 0,
		"y": 0
	},
	"bg4": {
		"type": "bg",
		"spriteIndex": 4,
		"x": 0,
		"y": 0
	},
	"bg5": {
		"type": "bg",
		"spriteIndex": 5,
		"x": 0,
		"y": 0
	},
	"bg6": {
		"type": "bg",
		"spriteIndex": 6,
		"x": 0,
		"y": 0
	},
	"bg7": {
		"type": "bg",
		"spriteIndex": 7,
		"x": 0,
		"y": 0
	},
	"bg8": {
		"type": "bg",
		"spriteIndex": 8,
		"x": 0,
		"y": 0
	},
	"bg9": {
		"type": "bg",
		"spriteIndex": 9,
		"x": 0,
		"y": 0
	},
	"bg10": {
		"type": "bg",
		"spriteIndex": 10,
		"x": 0,
		"y": 0
	},
	"bg11": {
		"type": "bg",
		"spriteIndex": 11,
		"x": 0,
		"y": 0
	},
	"bg12": {
		"type": "bg",
		"spriteIndex": 12,
		"x": 0,
		"y": 0
	},
	"bg13": {
		"type": "bg",
		"spriteIndex": 13,
		"x": 0,
		"y": 0
	},
	"bg14": {
		"type": "bg",
		"spriteIndex": 14,
		"x": 0,
		"y": 0
	},
	"bg15": {
		"type": "bg",
		"spriteIndex": 15,
		"x": 0,
		"y": 0
	},
	"bg16": {
		"type": "bg",
		"spriteIndex": 16,
		"x": 0,
		"y": 0
	},
	"bg17": {
		"type": "bg",
		"spriteIndex": 17,
		"x": 0,
		"y": 0
	},
	"bg18": {
		"type": "bg",
		"spriteIndex": 18,
		"x": 0,
		"y": 0
	},
	"bg19": {
		"type": "bg",
		"spriteIndex": 19,
		"x": 0,
		"y": 0
	},
	"bg20": {
		"type": "bg",
		"spriteIndex": 20,
		"x": 0,
		"y": 0
	},
	"bg21": {
		"type": "bg",
		"spriteIndex": 21,
		"x": 0,
		"y": 0
	},
	"bg22": {
		"type": "bg",
		"spriteIndex": 22,
		"x": 0,
		"y": 0
	},
	"bg23": {
		"type": "bg",
		"spriteIndex": 23,
		"x": 0,
		"y": 0
	},
	"bg24": {
		"type": "bg",
		"spriteIndex": 24,
		"x": 0,
		"y": 0
	},
		"bg25": {
		"type": "bg",
		"spriteIndex": 25,
		"x": 0,
		"y": 0
	},
		"bg26": {
		"type": "bg",
		"spriteIndex": 26,
		"x": 0,
		"y": 0
	},
		"bg27": {
		"type": "bg",
		"spriteIndex": 27,
		"x": 0,
		"y": 0
	},
		"bg28": {
		"type": "bg",
		"spriteIndex": 28,
		"x": 0,
		"y": 0
	},
		"bg29": {
		"type": "bg",
		"spriteIndex": 29,
		"x": 0,
		"y": 0
	},
		"bg30": {
		"type": "bg",
		"spriteIndex": 30,
		"x": 0,
		"y": 0
	},
		"bg31": {
		"type": "bg",
		"spriteIndex": 31,
		"x": 0,
		"y": 0
	},
		"bg32": {
		"type": "bg",
		"spriteIndex": 32,
		"x": 0,
		"y": 0
	},
		"bg33": {
		"type": "bg",
		"spriteIndex": 33,
		"x": 0,
		"y": 0
	},
		"bg34": {
		"type": "bg",
		"spriteIndex": 34,
		"x": 0,
		"y": 0
	},
		"bg35": {
		"type": "bg",
		"spriteIndex": 35,
		"x": 0,
		"y": 0
	},
		"bg36": {
		"type": "bg",
		"spriteIndex": 36,
		"x": 0,
		"y": 0
	},
		"bg37": {
		"type": "bg",
		"spriteIndex": 37,
		"x": 0,
		"y": 0
	},
		"bg38": {
		"type": "bg",
		"spriteIndex": 38,
		"x": 0,
		"y": 0
	},
		"bg39": {
		"type": "bg",
		"spriteIndex": 39,
		"x": 0,
		"y": 0
	},
		"bg40": {
		"type": "bg",
		"spriteIndex": 40,
		"x": 0,
		"y": 0
	},
		"bg41": {
		"type": "bg",
		"spriteIndex": 41,
		"x": 0,
		"y": 0
	},
		"bg42": {
		"type": "bg",
		"spriteIndex": 42,
		"x": 0,
		"y": 0
	},
		"bg43": {
		"type": "bg",
		"spriteIndex": 43,
		"x": 0,
		"y": 0
	},
		"bg44": {
		"type": "bg",
		"spriteIndex": 44,
		"x": 0,
		"y": 0
	},
		"bg45": {
		"type": "bg",
		"spriteIndex": 45,
		"x": 0,
		"y": 0
	},
		"bg46": {
		"type": "bg",
		"spriteIndex": 46,
		"x": 0,
		"y": 0
	},
		"bg47": {
		"type": "bg",
		"spriteIndex": 47,
		"x": 0,
		"y": 0
	},
		"bg48": {
		"type": "bg",
		"spriteIndex": 48,
		"x": 0,
		"y": 0
	},
		"bg49": {
		"type": "bg",
		"spriteIndex": 49,
		"x": 0,
		"y": 0
	},
		"bg50": {
		"type": "bg",
		"spriteIndex": 50,
		"x": 0,
		"y": 0
	},
		"bg51": {
		"type": "bg",
		"spriteIndex": 51,
		"x": 0,
		"y": 0
	},
		"bg52": {
		"type": "bg",
		"spriteIndex": 52,
		"x": 0,
		"y": 0
	},
		"bg53": {
		"type": "bg",
		"spriteIndex": 53,
		"x": 0,
		"y": 0
	},
		"bg54": {
		"type": "bg",
		"spriteIndex": 54,
		"x": 0,
		"y": 0
	},
		"bg55": {
		"type": "bg",
		"spriteIndex": 55,
		"x": 0,
		"y": 0
	},
		"bg56": {
		"type": "bg",
		"spriteIndex": 56,
		"x": 0,
		"y": 0
	},
	"bg57": {
		"type": "bg",
		"spriteIndex": 57,
		"x": 0,
		"y": 0
	},
	"bg58": {
		"type": "bg",
		"spriteIndex": 58,
		"x": 0,
		"y": 0
	},
	"bg59": {
		"type": "bg",
		"spriteIndex": 59,
		"x": 0,
		"y": 0
	},
	"bg60": {
		"type": "bg",
		"spriteIndex": 60,
		"x": 0,
		"y": 0
	},
	"bg61": {
		"type": "bg",
		"spriteIndex": 61,
		"x": 0,
		"y": 0
	},
		"bg62": {
		"type": "bg",
		"spriteIndex": 62,
		"x": 0,
		"y": 0
	},
		"bg63": {
		"type": "bg",
		"spriteIndex": 63,
		"x": 0,
		"y": 0
	},
		"bg64": {
		"type": "bg",
		"spriteIndex": 64,
		"x": 0,
		"y": 0
	},
	"bg65": {
		"type": "bg",
		"spriteIndex": 65,
		"x": 0,
		"y": 0
	},
		"bg66": {
		"type": "bg",
		"spriteIndex": 66,
		"x": 0,
		"y": 0
	},
	"bg67": {
		"type": "bg",
		"spriteIndex": 67,
		"x": 0,
		"y": 0
	},
	"bg68": {
		"type": "bg",
		"spriteIndex": 68,
		"x": 0,
		"y": 0
	},
	"bg69": {
		"type": "bg",
		"spriteIndex": 69,
		"x": 0,
		"y": 0
	},
	"bg70": {
		"type": "bg",
		"spriteIndex": 70,
		"x": 0,
		"y": 0
	},
	"bg71": {
		"type": "bg",
		"spriteIndex": 71,
		"x": 0,
		"y": 0
	},
	"bg72": {
		"type": "bg",
		"spriteIndex": 72,
		"x": 0,
		"y": 0
	},
	"bg73": {
		"type": "bg",
		"spriteIndex": 73,
		"x": 0,
		"y": 0
	},
	"bg74": {
		"type": "bg",
		"spriteIndex": 74,
		"x": 0,
		"y": 0
	},
	"bg75": {
		"type": "bg",
		"spriteIndex": 75,
		"x": 0,
		"y": 0
	},
	"bg76": {
		"type": "bg",
		"spriteIndex": 76,
		"x": 0,
		"y": 0
	},
}
	
#属性值的	类型
const tilesAttributeType={
	'spriteIndex':"int",
	"x":"int",
	"y":"int",
	'layer':"int",
	"offsetX":"int",
	"offsetY":"int",
}
				
var mapTiles={}  #每个图块对应的图片

func _ready():
	for i in constants.tilesType:
		mapTiles[i]={}
	loadIcon()	

	pass


#载入方块的图片
func loadIcon():
	var dic=Directory.new()
	dic.open("res://icon")
	dic.list_dir_begin()
	while true:
		var file = dic.get_next()
		if file == "":
			break
#		print(file.get_extension())
#		print(dic.get_current_dir()+"/"+file)
#		print(file.get_file())
		if file.get_extension()=='png':
			var fileName=file.get_basename().split("#")
			var type = fileName[0]
			if fileName.size()>1:
				var index=fileName[1]
				if mapTiles.has(type): #载入文件
					mapTiles[type][index]=load(dic.get_current_dir()+"/"+file)
			else: #只有名字
				if mapTiles.has(type):
					mapTiles[type]["0"]=load(dic.get_current_dir()+"/"+file)
			pass	
	dic.list_dir_end()
	pass
