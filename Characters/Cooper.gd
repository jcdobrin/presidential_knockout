extends AnimatedSprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var States = null;
var ActiveState = null;
var MoveDelta=0;
var AttackCounter=0;
var Health = 100
var Stun = 0
var StunCounter = 0
var DefaultStunCounter=3
var StunOverRide=0
var isHit = false
var isDown = false
var downTimer=0
var OpponentWeak=false
var isDefeated=false
var noBlock=false
onready var HitSound=get_node("../Hit")
onready var HitEndSound=get_node("../HitEnd")
onready var BlockSound=get_node("../Block")
onready var LongSwingSound=get_node("../LongSwing")
onready var QuickSwingSound=get_node("../QuickSwing")
onready var LongTauntSound=get_node("../LongTaunt")
onready var QuickTauntSound=get_node("../QuickTaunt")
var MoveQueue = [];
var HitCount=0;
var default_state = "IDLE_LOW"
var Difficulty = 1
var PunchesThrown = 0;
var StateOffsetStart = [0,0];
var StateOffsetEnd = [0,0];
var StateOffsetDuration = 0.0
var StateOffsetDurationTotal = 0.0
var StunHits = 0
var resetStunOverride = false

var PlayerHitCount=0
var PlayerBlockCount=0
var PlayerDodgeCount=0

var EnemyBlockCount=0
var EnemyHitCount=0
var EnemySuperHitCount=0
var EnemyDodgeCount=0

# Called when the node enters the scene tree for the first time.
func _ready():
	States = {
		"inverse":false,
		"activeFrame":0,
		"delta":0,
		"IDLE": [
			["Idle Low",    8.0/60.0,  0, "IDLE",             1, [  0,  0], [  0,  0], "CantBeHit",  0.0, 0],
			["Idle Low",    8.0/60.0,  1, "IDLE",             2, [  0,  0], [  0,  0], "CantBeHit",  0.0, 0],
			["Idle High",   8.0/60.0,  2, "IDLE",             3, [  0,  0], [  0,  0], "CantBeHit",  0.0, 0],
			["Idle High",   8.0/60.0,  3, "IDLE",             4, [  0,  0], [  0,  0], "CantBeHit",  0.0, 0],
			["Idle Low",    8.0/60.0,  4, "IDLE",             5, [  0,  0], [  0,  0], "CantBeHit",  0.0, 0],
			["Idle Low",    8.0/60.0,  5, "IDLE",             6, [  0,  0], [  0,  0], "CantBeHit",  0.0, 0],
			["Idle High",   8.0/60.0,  6, "IDLE",             7, [  0,  0], [  0,  0], "CantBeHit",  0.0, 0],
			["Idle High",   8.0/60.0,  7, "",                 0, [  0,  0], [  0,  0], "CantBeHit",  0.0, 0],
		],
		
		"IDLE_LOW": [
			["Idle Low",    8.0/60.0,  0, "IDLE_LOW",             1, [  0,  0], [  0,  0], "CanBeHighHit",  0.0, 0],
			["Idle Low",    8.0/60.0,  1, "IDLE_LOW",             2, [  0,  0], [  0,  0], "CanBeHighHit",  0.0, 0],
			["Idle Low",    8.0/60.0,  2, "IDLE_LOW",             3, [  0,  0], [  0,  0], "CanBeHighHit",  0.0, 0],
			["Idle Low",    8.0/60.0,  3, "",                     0, [  0,  0], [  0,  0], "CanBeHighHit",  0.0, 0],
		],
		"IDLE_HIGH": [
			["Idle High",   8.0/60.0,  0, "IDLE_HIGH",        1, [  0,  0], [  0,  0], "CanBeLowHit",   0.0, 0],
			["Idle High",   8.0/60.0,  1, "IDLE_HIGH",        2, [  0,  0], [  0,  0], "CanBeLowHit",   0.0, 0],
			["Idle High",   8.0/60.0,  2, "IDLE_HIGH",        3, [  0,  0], [  0,  0], "CanBeLowHit",   0.0, 0],
			["Idle High",   8.0/60.0,  3, "",                 0, [  0,  0], [  0,  0], "CanBeLowHit",   0.0, 0],
		],
		"TAUNT": [
			["Idle Low",   3.0/60.0,  0, "TAUNT",             1, [  0,  0], [  0,  0], "WindUp",  0.0, 0],
			["Idle High",  3.0/60.0,  0, "TAUNT",             2, [  0,  0], [  0,  0], "WindUp",  0.0, 0],
			["Idle Low",   3.0/60.0,  0, "TAUNT",             3, [  0,  0], [  0,  0], "WindUp",  0.0, 0],
			["Idle High",  3.0/60.0,  0, "TAUNT",             4, [  0,  0], [  0,  0], "CanBeLowHit", 0.0, 0],
			["Idle Low",   3.0/60.0,  0, "TAUNT",             5, [  0,  0], [  0,  0], "WindUp",  0.0, 0],
			["Idle High",  3.0/60.0,  0, "",                  0, [  0,  0], [  0,  0], "WindUp",  0.0, 0],
		],
		"PUNCH": [
			["Punch",       3.0/60.0,  0, "PUNCH",            1, [  0,  0], [  0,  0], "CanBeLowHit",   10.0, 3],
			["Punch",       12.0/60.0, 1, "PUNCH",            2, [  0,  0], [  0,  0], "WindUp",        0.0, 0],
			["Punch",       9.0/60.0,  2, "PUNCH",            3, [  0,  0], [  0,  0], "CanBeLowHit",   0.0, 1],
			["Punch",       3.0/60.0,  2, "PUNCH",            4, [  0,  0], [ 10, 20], "WindUp",        0.0, 0],
			["Punch",       3.0/60.0,  3, "PUNCH",            5, [ 10, 20], [ 10, 20], "Attack",        0.0, 0],
			["Punch",       6.0/60.0,  3, "PUNCH",            6, [ 10, 20], [ 10, 20], "Attack",        0.0, 0],
			["Punch",       6.0/60.0,  3, "PUNCH",            7, [ 10, 20], [  0,  0], "CanBeHighHit",  3.0, 0],
			["Punch",       30.0/60.0, 3, "" ,                0, [  0,  0], [  0,  0], "CanBeHighHit",  3.0, 0],
		],
		"PUNCH_HIT": [
			["Punch",       6.0/60.0,  3, "PUNCH_HIT",        1, [ 10, 20], [  0,  0], "CantBeHit",     0.0, 0],
			["Punch",       6.0/60.0,  3, "" ,                0, [  0,  0], [  0,  0], "CantBeHit",     0.0, 0],
		],
		"PUNCH_BLOCKED": [
			["Punch",       16.0/60.0, 4, "",                 0, [  0,  0], [  0,  0], "CantBeHit",     0.0, 0],
		],
		"FAST_PUNCH": [
			["Punch",       3.0/60.0,  0, "FAST_PUNCH",            1, [  0,  0], [  0,  0], "CanBeLowHit",   10.0, 3],
			["Punch",       9.0/60.0,  1, "FAST_PUNCH",            2, [  0,  0], [  0,  0], "CanBeLowHit",   0.0, 1],
			["Punch",       9.0/60.0,  2, "FAST_PUNCH",            3, [  0,  0], [  0,  0], "CanBeLowHit",   0.0, 1],
			["Punch",       3.0/60.0,  2, "FAST_PUNCH",            4, [  0,  0], [ 10, 20], "WindUp",        0.0, 0],
			["Punch",       3.0/60.0,  3, "FAST_PUNCH",            5, [ 10, 20], [ 10, 20], "Attack",        0.0, 0],
			["Punch",       6.0/60.0,  3, "FAST_PUNCH",            6, [ 10, 20], [ 10, 20], "Attack",        0.0, 0],
			["Punch",       6.0/60.0,  3, "FAST_PUNCH",            7, [ 10, 20], [  0,  0], "CanBeHighHit",  1.0, 0],
			["Punch",       3.0/60.0, 3, "" ,                      0, [  0,  0], [  0,  0], "CanBeHighHit",  0.0, 0],
		],
		"FAST_PUNCH_HIT": [
			["Punch",       6.0/60.0,  3, "PUNCH_HIT",        1, [ 10, 20], [  0,  0], "CantBeHit",     2.0, 0],
			["Punch",       6.0/60.0,  3, "" ,                0, [  0,  0], [  0,  0], "CantBeHit",     2.0, 0],
		],
		"FAST_PUNCH_BLOCKED": [
			["Punch",       6.0/60.0, 4, "",                 0, [  0,  0], [  0,  0], "CantBeHit",      0.0, 0],
		],
		"POWER_PUNCH": [
			["Power Punch", 12.0/60.0, 0, "POWER_PUNCH",      1, [  0,  0], [  0,  0], "WindUp",   0.0, 0],
			["Power Punch", 6.0/60.0,  1,  "POWER_PUNCH",     2, [  0,  0], [ 10,  0], "WindUp",   0.0, 0],
			["Power Punch", 16.0/60.0, 2, "POWER_PUNCH",      3, [ 10,  0], [  0,  0], "CanBeLowHit",   0.0, 1],
			["Power Punch", 6.0/60.0,  3, "POWER_PUNCH",      4, [  0,  0], [  0,  0], "Attack",        0.0, 0],
			["Power Punch", 45.0/60.0, 4, "",                 0, [  0,  0], [  0,  0], "CanBeHighHit",  2.0, 0],
		],
		"POWER_PUNCH_HIT": [
			["Power Punch", 6.0/60.0,  3, "POWER_PUNCH_HIT",  1, [ 10,  0], [ 10,  0], "CantBeHit",     0.0, 0],
			["Power Punch", 12.0/60.0, 4, "",                 0, [ 10,  0], [  0,  0], "CantBeHit",     0.0, 0],
		],
		
		"POWER_PUNCH_BLOCKED": [
			["Power Punch", 16.0/60.0, 3, "",                 0, [ 10,  0], [ 10,  0], "CanBeHit",     0.0, 0],
		],
		
		"FAST_POWER_PUNCH": [
			["Power Punch", 3.0/60.0,  0, "FAST_POWER_PUNCH", 1, [  0,  0], [  0,  0], "WindUp",   0.0, 0],
			["Power Punch", 3.0/60.0,  1, "FAST_POWER_PUNCH", 2, [  0,  0], [ 10,  0], "WindUp",   0.0, 0],
			["Power Punch", 16.0/60.0, 2, "FAST_POWER_PUNCH", 3, [ 10,  0], [  0,  0], "CanBeLowHit",        0.0, 0],
			["Power Punch", 6.0/60.0,  3, "FAST_POWER_PUNCH", 4, [  0,  0], [  0,  0], "Attack",        0.0, 0],
			["Power Punch", 6.0/60.0,  4, "",                 0, [  0,  0], [  0,  0], "CantBeHit",     0.0, 0],
		],
		"FAST_POWER_PUNCH_BLOCKED": [
			["Power Punch", 3.0/60.0,  3, "",                 0, [ 10,  0], [ 10,  0], "CantBeHit",     0.0, 0],
		],
		"FAST_POWER_PUNCH_HIT": [
			["Power Punch", 6.0/60.0,  3, "",                 1, [ 10,  0], [ 10,  0], "CantBeHit",     0.0, 0],
		],
		"HIGH_BLOCK": [
			["Block High",  6.0/60.0,  0, "HIGH_BLOCK",       1, [  0,  0], [ 10,  0], "Blocking",      0.0, 0],
			["Block High",  6.0/60.0,  0, "",                 0, [ 10,  0], [  0,  0], "Blocking",      0.0, 0],
		],
		"LOW_BLOCK": [
			["Block Low",   6.0/60.0,  0, "LOW_BLOCK",        1, [  0,  0], [ 10,  0], "Blocking",      0.0, 0],
			["Block Low",   6.0/60.0,  0, "",                 0, [ 10,  0], [  0,  0], "Blocking",      0.0, 0],
		],
		"HIGH_HIT": [
			["Hit High",    6.0/60.0,  0, "HIGH_HIT",         1, [  0,  0], [ 10,  0], "BeingHit",      0.0, 0],
			["Hit High",    6.0/60.0,  0, "",                 0, [ 10,  0], [  0,  0], "BeingHit",      0.0, 0],
		],
		"HIGH_HIT_LONG": [
			["Hit High",    6.0/60.0,  0, "HIGH_HIT_LONG",    1, [  0,  0], [ 25,  0], "BeingHit",      0.0, 0],
			["Hit High",    6.0/60.0,  0, "HIGH_HIT_LONG",    2, [ 25,  0], [ 25,  0], "BeingHit",      0.0, 0],
			["Hit High",    6.0/60.0,  0, "",                 0, [ 25,  0], [  0,  0], "BeingHit",      0.0, 0],
		],
		"LOW_HIT": [
			["Hit Low",     6.0/60.0,  0, "LOW_HIT",          1, [  0,  0], [ 10,  0], "BeingHit",      0.0, 0],
			["Hit Low",     6.0/60.0,  0, "",                 0, [ 10,  0], [  0,  0], "BeingHit",      0.0, 0],
		],
		"LOW_HIT_LONG": [
			["Hit Low",     6.0/60.0,  0, "LOW_HIT_LONG",     1, [  0,  0], [ 25,  0], "BeingHit",      0.0, 0],
			["Hit Low",     6.0/60.0,  0, "LOW_HIT_LONG",     2, [ 25,  0], [ 25,  0], "BeingHit",      0.0, 0],
			["Hit Low",     6.0/60.0,  0, "",                 0, [ 25,  0], [  0,  0], "BeingHit",      0.0, 0],
		],
		"STUN":[
			["Stun",        6.0/60.0,  0, "STUN",              1, [  0,  0], [  0,  0], "CanBeHit", 0.0, 0],
			["Stun",        6.0/60.0,  1, "STUN",              2, [  0,  0], [  0,  0], "CanBeHit", 0.0, 0],
			["Stun",        6.0/60.0,  2, "STUN",              3, [  0,  0], [  0,  0], "CanBeHit", 0.0, 0],
			["Stun",        6.0/60.0,  3, "STUN",              4, [  0,  0], [  0,  0], "CanBeHit", 0.0, 0],
			["Stun",        6.0/60.0,  4, "STUN",              5, [  0,  0], [  0,  0], "CanBeHit", 0.0, 0],
			["Stun",        6.0/60.0,  5, "STUN",              6, [  0,  0], [  0,  0], "CanBeHit", 0.0, 0],
			["Stun",        6.0/60.0,  6, "STUN",              7, [  0,  0], [  0,  0], "CanBeHit", 0.0, 0],
			["Stun",        6.0/60.0,  7, "STUN",              0, [  0,  0], [  0,  0], "CanBeHit", 0.0, 0],
		],
		"KNOCKDOWN":[
			["Knockdown",    6.0/60.0, 0, "KNOCKDOWN",         1, [  0,  0], [ 15,  0], "Down",         0.0, 0],
			["Knockdown",   60.0/60.0, 1, "KNOCKOUT",          0, [ 15,  0], [ 550,  0], "Down",         0.0, 0],
		],
		"KNOCKOUT":[
			["Knockdown",   1.0/60.0,  2, "KNOCKOUT",          0, [ 550,  0], [ 550,  0], "Down",         0.0, 0],
		],
		"GETUP":[
			["Get Up",      6.0/60.0, 0, "GETUP",             1, [ 0,  0], [  0,  0], "Down",         0.0, 0],
			["Get Up",      6.0/60.0, 1, "",                  0, [ 0,  0], [  0,  0], "Down",         0.0, 0],
		],
		"WALK":[
			["Walk",    6.0/60.0,  0, "WALK",             1, [  0,  0], [  0,  0], "Walk",  0.0, 0],
			["Walk",    6.0/60.0,  1, "WALK",             2, [  0,  0], [  0,  0], "Walk",  0.0, 0],
			["Walk",    6.0/60.0,  2, "WALK",             3, [  0,  0], [  0,  0], "Walk",  0.0, 0],
			["Walk",    6.0/60.0,  3, "",                 0, [  0,  0], [  0,  0], "Walk",  0.0, 0],
		]
	};
	ActiveState = "WALK";
	MoveQueue.push_back(["WALK", false])
	MoveQueue.push_back(["WALK", false])
	MoveQueue.push_back(["WALK", false])
	StateOffsetStart = [250,0];
	StateOffsetEnd = [0,0];
	StateOffsetDuration = 96.0/60.0
	StateOffsetDurationTotal = StateOffsetDuration
	States.delta = 0;
	States.activeFrame = 0;

#func _process(delta):
#	if(self.position.x==0):
#		self.position.x = 400
#	if(ActiveState == default_state):
#		setActiveState('KNOCKDOWN', true)
#	if(ActiveState=="KNOCKOUT"):
#		StunHits+=1
#		if(StunHits==100):
#			setSecondWind()
#	process(delta, self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta, Player):
	
	self.offset.x = 0
	self.offset.y = 0
	if(Player.isDown):
		MoveDelta=0
		MoveQueue=[]
		AttackCounter=0
		if ActiveState != default_state:
			setActiveState(default_state)
	if(Health<=0 && !isDown):
		isDown=true
		isHit=false
		MoveDelta=0
		AttackCounter=0
		Stun = 0
		setActiveState("KNOCKDOWN", States.inverse)
	elif Stun > 0:
		MoveDelta=0
		if(ActiveState == default_state):
			isHit=false
			setActiveState("STUN")

		if ActiveState == "STUN":
			Stun-=delta
			if(Stun < 0 || StunHits==StunCounter):
				Stun = 0
				StunHits = 0
				setActiveState(default_state)
	
	
	elif(isDown && ActiveState == "KNOCKOUT"):
		downTimer+=delta
		if downTimer > 2:
			if(Difficulty==1):
				if(global.GameMode=='Easy' || global.GameMode=='Normal'):
					isDefeated=true
				else:
					setSecondWind()
			#elif(Difficulty==2):
			#	setThirdWind()
			else:
				isDefeated=true
	elif(MoveDelta > 1.5):
		MoveDelta = 0.0;
		AttackCounter+=1
		if(OpponentWeak):
			MoveQueue.push_front(["FAST_POWER_PUNCH", false])
		elif(Difficulty==2):
			if(AttackCounter == 4):
				AttackCounter = 0
				createSpecialAttack()
			elif(randf() > 0.55):
				createDoubleUpperCut()
			else:
				createTriplePunch()
			
		elif(AttackCounter>=1):
			AttackCounter=0
			if(Health>25):
				MoveQueue = [["POWER_PUNCH", false]]
			else:
				MoveQueue.push_front(["PUNCH", false])
				MoveQueue.push_front(["FAST_POWER_PUNCH",true])
	else:
		if ActiveState == default_state:
			States.inverse = false;
			if(resetStunOverride):
				StunOverRide=0
			isHit=false
			MoveDelta+=delta
			resetStunOverride = false

	if(HitCount >=3 && Difficulty==1):
		HitCount = 0
		if default_state == 'IDLE_LOW':
			default_state = 'IDLE_HIGH'
		elif(default_state == 'IDLE_HIGH'):
			default_state = 'IDLE_LOW'
	
	self.set_flip_h(States.inverse)
	self.animation = States[ActiveState][States.activeFrame][0];
	self.frame     = States[ActiveState][States.activeFrame][2];
	States.delta += delta;
	if(StateOffsetDuration > 0):
			StateOffsetDuration -= delta
	var inv = 1.0;
	if  States.inverse:
		inv = -1.0;
	
	self.offset.x += lerp(States[ActiveState][States.activeFrame][5][0],
		States[ActiveState][States.activeFrame][6][0],
		States.delta/States[ActiveState][States.activeFrame][1]
	) * inv
	
	self.offset.y += lerp(States[ActiveState][States.activeFrame][5][1],
		States[ActiveState][States.activeFrame][6][1],
		States.delta/States[ActiveState][States.activeFrame][1]
	)
	
	if(StateOffsetDuration > 0):
		var x = lerp(StateOffsetEnd[0], StateOffsetStart[0], StateOffsetDuration/StateOffsetDurationTotal) * inv
		self.offset.x += x
		self.offset.y += lerp(StateOffsetStart[1], StateOffsetEnd[1], StateOffsetDuration/StateOffsetDurationTotal)
	
	while (States.delta > States[ActiveState][States.activeFrame][1]):
		States.delta -= States[ActiveState][States.activeFrame][1]
		var nextFrame = States[ActiveState][States.activeFrame][4]
		var nextState = States[ActiveState][States.activeFrame][3]
		if(nextState == ActiveState):
			if(States[ActiveState][States.activeFrame][7] != 'Attack' && States[ActiveState][nextFrame][7] == 'Attack'):
				if(Player.ActiveState=="DODGE"):
					playSound("Swing")
		if(nextState == ""):
			if(MoveQueue.size() > 0):
				var q = MoveQueue.pop_front()
				nextState = q[0]
				States.inverse = q[1]
				if(q.size()>2):
					playSound(q[2])
			else:
				resetStunOverride=true
				
			if(nextState == ""):
				nextState = default_state
		States.activeFrame = nextFrame
		ActiveState = nextState
		

func setActiveState(State, inv=false):
	ActiveState = State
	States.delta = 0;
	States.activeFrame = 0;
	States.inverse = inv;

func getCurrentState():
	return States[ActiveState][States.activeFrame];

func playSound(sound):
	if(sound=="Hit"):
		if(StunHits > 0 && StunHits==StunCounter):
			HitEndSound.play()
		else:
			HitSound.play()
	if(sound=="Block"):
			BlockSound.play()
	if(sound=="Swing"):
		if(MoveQueue.size()>0):
			QuickSwingSound.play()
		else:
			LongSwingSound.play()
	if(sound=="LongTaunt"):
		LongTauntSound.play()
	if(sound=="QuickTaunt"):
		QuickTauntSound.play()

func createSpecialAttack():
	StunOverRide=5
	resetStunOverride=false
	MoveQueue = [
		['TAUNT', false, "QuickTaunt"],
		['TAUNT', false, "QuickTaunt"],
		['TAUNT', false, "LongTaunt"],
		['FAST_POWER_PUNCH', false],
		['FAST_POWER_PUNCH', true],
		['FAST_PUNCH', false],
		['PUNCH', false],
	]

func createDoubleUpperCut():
	StunOverRide=4
	resetStunOverride=false
	MoveQueue = [
		['TAUNT', false, "QuickTaunt"],
		['TAUNT', false, "LongTaunt"],
		['FAST_POWER_PUNCH', true],
		['POWER_PUNCH', false],
	]
	
func createTriplePunch():
	StunOverRide=4
	resetStunOverride=false
	MoveQueue = [
		['TAUNT', false, "LongTaunt"],
		['FAST_POWER_PUNCH', false],
		['FAST_POWER_PUNCH', true],
		['POWER_PUNCH', false],
	]

func setSecondWind():
	isDown=false
	isHit=false
	default_state='IDLE'
	setActiveState("GETUP", States.inverse)
	MoveQueue = []
	MoveQueue.push_back(["WALK", States.inverse])
	MoveQueue.push_back(["WALK", States.inverse])
	MoveQueue.push_back(["WALK", States.inverse])
	MoveQueue.push_back(["", false])
	StateOffsetStart = [550,0]
	StateOffsetDuration = 72.0/60.0
	StateOffsetDurationTotal = StateOffsetDuration
	downTimer=0
	Health=100
	Difficulty = 2
	pass
	
func setThirdWind():
	isDown=false
	isHit=false
	setActiveState("GETUP", States.inverse)
	MoveQueue = []
	MoveQueue.push_back(["WALK", States.inverse])
	MoveQueue.push_back(["WALK", States.inverse])
	MoveQueue.push_back(["WALK", States.inverse])
	MoveQueue.push_back(["", false])
	StateOffsetStart = [550,0]
	
	StateOffsetDuration = 72.0/60.0
	StateOffsetDurationTotal = StateOffsetDuration
	downTimer=0
	Health=100
	Difficulty = 3
	pass

func handleHit(Player):
	var PlayerState = Player.getCurrentState()
	var State = getCurrentState()
	var PowerHits = State[9]
	if(Stun == 0):
		if(State[8] > 0):
			Stun=State[8]
			StunCounter = max(DefaultStunCounter, StunOverRide)
	else:
		StunHits+=1
		Stun=1.5
	
	if ActiveState == default_state:
		HitCount+=1
		
	if(PlayerState[7]=='HighAttack'):
		EnemyHitCount+=1
		
		if((StunHits > 0 && StunHits == StunCounter) || State[9]>0):
			setActiveState('HIGH_HIT_LONG', Player.States.inverse)
		else:
			setActiveState('HIGH_HIT', Player.States.inverse)
		Health-=5
		
	if(PlayerState[7]=='SuperAttack'):
		EnemySuperHitCount+=1
		setActiveState('HIGH_HIT_LONG', !Player.States.inverse)
		MoveQueue = []
		Health-=10
		Stun = 0
		PowerHits=0
	
	if(PlayerState[7]=='LowAttack'):
		EnemyHitCount+=1
		if((StunHits > 0 && StunHits == StunCounter) || State[9]>0):
			setActiveState('LOW_HIT_LONG', Player.States.inverse)
		else:	
			setActiveState('LOW_HIT', Player.States.inverse)
		Health-=5
	
	if(MoveQueue.size() > 0):
		Stun = 0
		
	playSound("Hit")
	if(PowerHits>0):
		Player.playSound("Ding")
	Player.PowerAttacks+=PowerHits
	Player.wasBlockedOrNot = true
	
	if(Health < 0):
		Health=0
	
func handleBlock(Player):
	if(ActiveState != default_state):
		EnemyDodgeCount+=1
		pass
	else:
		EnemyBlockCount+=1
		var State = getCurrentState()
		var PlayerState = Player.getCurrentState()
		
		if(PlayerState[7]=='HighAttack'):
			setActiveState('HIGH_BLOCK', Player.States.inverse)
		
		if(PlayerState[7]=='LowAttack'):
			setActiveState('LOW_BLOCK', Player.States.inverse)
		
		Player.setActiveState(Player.ActiveState+'_BLOCKED', Player.States.inverse)
		playSound("Block")
		Player.wasBlockedOrNot = true
		Player.Stamina -= 3
		Player.Stamina = max(Player.Stamina, 0)
		if(Player.Stamina == 0):
			Player.WeakCounter = 1

func handlePlayerBlock(Player):
	PlayerBlockCount+=1
	HitCount=0
	Player.Stamina -= 5
	Player.playSound("Block")
	Player.setActiveState("IDLE", true)
	setActiveState(ActiveState+'_BLOCKED', States.inverse)
	Player.Stamina = max(Player.Stamina, 0)
	if(Player.Stamina == 0):
		Player.WeakCounter = 3

func handlePlayerHit(Player):
	PlayerHitCount+=1
	HitCount=0
	setActiveState(ActiveState+'_HIT', States.inverse)
	StunOverRide=0
	Player.Health -= 5
	Player.Stamina -= 5
	Player.Stamina = max(Player.Stamina, 0)

	if(Player.Stamina == 0):
		Player.WeakCounter = 3
	Player.Hit = true
	Player.playSound("Hit")
	
	if Player.Health <= 0:
		Player.Health =0
		Player.setActiveState('KNOCKOUT', true)
	else:
		Player.setActiveState('HIT', !States.inverse)
