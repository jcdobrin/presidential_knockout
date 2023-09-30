extends AnimatedSprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var States = null;
var ActiveState = null;

var Health = 100;
var Dodged = false;
var DodgeReleased = true;
var BlockReleased = true;
var Hit = false;
var wasBlockedOrNot = false;

var DownTime=0
var GetUpCounter = 10
var KnockDownCounter=0;
var Stamina = 100
var WeakCounter = 0
var longDodge=0
var isDefeated=false
var isDown=false
var default_state = "IDLE"
var PowerAttacks=0
var TimeElapsed=0
var DodgeLength = 6
var KnockDownOffset=0

onready var HitSound=get_node("../Hit")
onready var BlockSound=get_node("../Block")
onready var DingSound=get_node("../Ding")
onready var UpperCutSound=get_node("../UpperCut")


# Called when the node enters the scene tree for the first time.
func _ready():
	var low_punch_left = InputEventKey.new();
	low_punch_left.set_scancode(KEY_A)
	InputMap.add_action("low_punch_left")
	InputMap.action_erase_event("low_punch_left", low_punch_left)
	InputMap.action_add_event("low_punch_left", low_punch_left);
	
	var low_punch_right = InputEventKey.new();
	low_punch_right.set_scancode(KEY_S)
	InputMap.add_action("low_punch_right");
	InputMap.action_erase_event("low_punch_right", low_punch_right);
	InputMap.action_add_event("low_punch_right", low_punch_right);
	
	States = {
		"inverse":false,
		"activeFrame":0,
		"delta":0,
		"IDLE": [
			["Idle", 12.0/60.0,  0, "IDLE", 1, [  0,  0] , [  0,  0], "CanBeHit"],
			["Idle", 12.0/60.0,  1, "IDLE", 0, [  0,  0] , [  0,  0], "CanBeHit"],
		],
		"LOW_PUNCH": [
			["LowPunch", 3.0/60.0,  0, "LOW_PUNCH", 1, [  0,  0] , [  0,  0], "CanBeHit"],
			["LowPunch", 3.0/60.0,  1, "LOW_PUNCH", 2, [  0,  0] , [  0,  0], "CanBeHit"],
			["LowPunch", 6.0/60.0,  2, "LOW_PUNCH", 3, [  0,  0] , [  0,  0], "LowAttack"],
			["LowPunch", 3.0/60.0,  1, "LOW_PUNCH", 4, [  0,  0] , [  0,  0], "CanBeHit"],
			["Idle",     4.0/60.0,  1, "",      0, [  0,  0] , [  0,  0], "CanBeHit"],
		],
		"LOW_PUNCH_BLOCKED": [
			["LowPunch", 12.0/60.0, 2, "LOW_PUNCH_BLOCKED", 1, [  0,  0] , [  0,  0], "CanBeHit"],
			["LowPunch",  3.0/60.0, 1, "LOW_PUNCH_BLOCKED", 2, [  0,  0] , [  0,  0], "CanBeHit"],
			["Idle",      4.0/60.0, 1, "",      0, [  0,  0] , [  0,  0], "CanBeHit"],
		],
		"HIGH_PUNCH": [
			["HighPunch", 3.0/60.0,  0, "HIGH_PUNCH", 1, [  0,  0] , [5,-5], "CanBeHit"],
			["HighPunch", 3.0/60.0,  1, "HIGH_PUNCH", 2, [5,-5] , [10,-20], "CanBeHit"],
			["HighPunch", 6.0/60.0,  2, "HIGH_PUNCH", 3, [10,-20] , [5,-5], "HighAttack"],
			["HighPunch", 3.0/60.0,  1, "HIGH_PUNCH", 4, [5,-5] , [  0,  0], "CanBeHit"],
			["Idle",      4.0/60.0,  1, "",       0, [  0,  0] , [  0,  0], "CanBeHit"],
			
		],
		"HIGH_PUNCH_BLOCKED": [
			["HighPunch", 6.0/60.0,  2, "HIGH_PUNCH_BLOCKED", 1, [10,-20] , [10,-20], "CanBeHit"],
			["HighPunch", 6.0/60.0,  2, "HIGH_PUNCH_BLOCKED", 2, [10,-20] , [5,-5], "CanBeHit"],
			["HighPunch", 3.0/60.0,  1, "HIGH_PUNCH_BLOCKED", 3, [5,-5] , [  0,  0], "CanBeHit"],
			["Idle",      4.0/60.0,  1, "",       0, [  0,  0] , [  0,  0], "CanBeHit"],
			
		],
		"UPPER_CUT": [
			["UpperCut", 12.0/60.0,  0, "UPPER_CUT",  1, [  0,  0] , [0,-2], "CanBeHit"],
			["UpperCut",  3.0/60.0,  1, "UPPER_CUT",  2, [  0,  0]   , [0,-2], "CanBeHit"],
			["UpperCut",  3.0/60.0,  2, "UPPER_CUT" , 3, [0,-2]  , [0,-10], "CanBeHit"],
			["UpperCut",  3.0/60.0,  3, "UPPER_CUT" , 4, [0,-10] , [0,-25], "CanBeHit"],
			["UpperCut", 3.0/60.0,  4, "UPPER_CUT" , 5, [0,-20] , [0,-10], "SuperAttack"],
			["UpperCut", 12.0/60.0,  5, ""      , 0, [0,-10] , [0,20], "SuperAttack"],
		],
		
		"BLOCK": [
			["Block",     1.0/60.0,  0, "BLOCK",  0,  [  0,  0]   , [  0,  0], "Blocking"],
		],
		
		"DODGE": [
			["Dodge",     3.0/60.0,  0, "DODGE",   1,  [  0,  0]   , [2,0], "CantBeHit"],
			["Dodge",     3.0/60.0,  1, "DODGE",   2,  [2,0]   , [10,0], "CantBeHit"],
			["Dodge",     3.0/60.0,  2,  "DODGE",  3,  [10,0]   , [10,0], "CantBeHit"],
			["Dodge",     3.0/60.0,  1, "DODGE",   4,  [10,0]   , [2,0], "CanBeHit"],
			["Idle",      3.0/60.0,  0, "",       0,  [10,0]   , [2,0], "CanBeHit"],
		],
		"HIT": [
			["Hit",     3.0/60.0,  0, "HIT",   1,  [  0,  0]   , [  0,  0], "CanBeHit"],
			["Hit",     3.0/60.0,  1, "HIT",   2,  [  0,  0]   , [  0,  0], "CanBeHit"],
			["Hit",     8.0/60.0, 0, "",       0,  [  0,  0]   , [  0,  0], "CanBeHit"],
		],
		
		"KNOCKOUT": [
			["Hit",          3.0/60.0,  0, "KNOCKOUT",   1,  [  0,  0]   , [  0,  0], "Down"],
			["Hit",          3.0/60.0,  1, "KNOCKOUT",   2,  [  0,  0]   , [  0,  0], "Down"],
			["Knockout",     30.0/60.0, 0, "KNOCKOUT",   3,  [  0,  0]   , [  0,200], "Down"],
			["Weak",         6.0/60.0,  0, "KNOCKOUT",   4,  [  0,200]   , [  0,200], "Down"],
			["Weak",         6.0/60.0,  1, "KNOCKOUT",   3,  [  0,200]   , [  0,200], "Down"],
		],
		
		"WEAK": [
			["Weak",     6.0/60.0,  0, "WEAK",   1,  [  0,  0]   , [  0,  0], "Weak"],
			["Weak",     6.0/60.0,  1, "WEAK",   0,  [  0,  0]   , [  0,  0], "Weak"],
		],
		
		"WAKEUP": [
			["Weak",     30.0/60.0,  0, "",   1,  [0,150]   , [  0,  0], "Down"],
		],
	};
	
	if(global.GameMode=='Easy'):
		States['DODGE'] = [
			["Dodge",     3.0/60.0,  0, "DODGE",   1,  [  0,  0]   , [2,0], "CantBeHit"],
			["Dodge",     3.0/60.0,  1, "DODGE",   2,  [2,0]   , [10,0], "CantBeHit"],
			["Dodge",     3.0/60.0,  2, "DODGE",  3,  [10,0]   , [10,0], "CantBeHit"],
			["Dodge",     3.0/60.0,  1, "DODGE",   4,  [10,0]   , [2,0], "CanBeHit"],
			["Idle",      3.0/60.0,  0, "",        0,  [10,0]   , [2,0], "CanBeHit"],
		]
		DodgeLength=10
	ActiveState = default_state;
	States.delta = 0;
	States.activeFrame = 0;
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta, Enemy):
	if(Stamina > 100):
		Stamina = 100
	if(WeakCounter > 2):
		WeakCounter = 2
	self.offset.x = 0
	self.offset.y = 0
	var dodgeLEvent = Input.is_action_pressed("ui_left") || Input.is_action_pressed("dodge_left")
	var dodgeREvent = Input.is_action_pressed("ui_right") || Input.is_action_pressed("dodge_right")
	
	var blockEvent = Input.is_action_pressed("ui_down") || Input.is_action_pressed("gui_block")
	
	var lowPunchLEvent = Input.is_action_just_pressed("low_punch_left")
	var lowPunchREvent = Input.is_action_just_pressed("low_punch_right")
	
	var highPunchLEvent = Input.is_action_just_pressed("high_punch_left")
	var highPunchREvent = Input.is_action_just_pressed("high_punch_right")
	
	var upperCutEvent = PowerAttacks > 0 && (Input.is_action_just_pressed("ui_select") || Input.is_action_just_pressed("gui_upper_cut"))
	
	var EnemyState = Enemy.getCurrentState()
	
	if(Input.is_action_pressed("ui_up")):
		highPunchLEvent = highPunchLEvent || Input.is_action_just_pressed("low_punch_left")
		highPunchREvent = highPunchREvent || Input.is_action_just_pressed("low_punch_right")
	else:
		lowPunchLEvent = lowPunchLEvent || Input.is_action_just_pressed("low_punch_left")
		lowPunchREvent = lowPunchREvent || Input.is_action_just_pressed("low_punch_right")
	
	
	if(!dodgeLEvent && !dodgeREvent):
		DodgeReleased = true
	
	if(!blockEvent):
		BlockReleased = true
		
		
	if(WeakCounter > 0 && ActiveState == 'IDLE'):
		default_state = "WEAK"
		self.setActiveState(default_state)
	
	elif(self.ActiveState == 'WEAK' && Stamina>0):
		default_state = "IDLE"
		self.setActiveState(default_state)
	
	#handle block
	if(ActiveState=="BLOCK" && BlockReleased):
		setActiveState("IDLE")
	
	elif blockEvent && ((ActiveState == "IDLE" && BlockReleased)):
		setActiveState("BLOCK")
		BlockReleased = false
	
	#handle dodges
	elif dodgeLEvent && (ActiveState == default_state) && DodgeReleased:
		setActiveState("DODGE")
		DodgeReleased = false
		
	elif dodgeREvent && (ActiveState == default_state) && DodgeReleased:
		setActiveState("DODGE", true)
		DodgeReleased = false
	
	#handle attacks
	elif ActiveState == "IDLE" && WeakCounter == 0 && (EnemyState[7] != 'Down' && EnemyState[7] != 'Walk'):
		wasBlockedOrNot=false
		if highPunchLEvent:
			setActiveState("HIGH_PUNCH",true)
		
		elif highPunchREvent:
			setActiveState("HIGH_PUNCH")
		
		elif lowPunchLEvent:
			setActiveState("LOW_PUNCH",true)
		
		elif lowPunchREvent:
			setActiveState("LOW_PUNCH")
		
		elif upperCutEvent:
			setActiveState("UPPER_CUT")
			playSound('UpperCut')
			PowerAttacks-=1
		else:
			if(Stamina > 0 && Stamina < 100):
				Stamina += delta/2.0
	
	elif ActiveState == "KNOCKOUT":
		if(global.GameMode != 'Easy'):
			DownTime+=delta
		isDown=true
		if DownTime > 10:
			isDefeated=true
	
		#handle getting up
		elif Input.is_action_just_released("gui_getup"):
			KnockDownCounter+=1
			KnockDownOffset = -1 * int(float(KnockDownCounter)/float(GetUpCounter)*50.0)
			if(KnockDownCounter>=GetUpCounter):
				KnockDownOffset=0
				setActiveState("WAKEUP")
				Enemy.MoveDelta = 0
				Enemy.MoveQueue = [["", false], ["", false]]
				DownTime = 0
				Stamina=10 * min((10 / (DownTime+.01)), 10)
				WeakCounter=0
				Health=100
				GetUpCounter+=10
				KnockDownCounter=0
				isDown=false

	if ActiveState == default_state:
		States.inverse = false;
		longDodge=0
	
	self.set_flip_h(States.inverse)
	self.animation = States[ActiveState][States.activeFrame][0];
	self.frame     = States[ActiveState][States.activeFrame][2];
	States.delta += delta;
	var inv = 1.0;
	if  !States.inverse && ActiveState=='DODGE':
		inv = -1.0;
	
	self.offset.x += lerp(States[ActiveState][States.activeFrame][5][0],
		States[ActiveState][States.activeFrame][6][0],
		States.delta/States[ActiveState][States.activeFrame][1]
	) * inv
	
	self.offset.y += lerp(States[ActiveState][States.activeFrame][5][1],
		States[ActiveState][States.activeFrame][6][1],
		States.delta/States[ActiveState][States.activeFrame][1]
	) + KnockDownOffset
	
	
	while (States.delta > States[ActiveState][States.activeFrame][1]):
		States.delta -= States[ActiveState][States.activeFrame][1]
		var nextFrame = States[ActiveState][States.activeFrame][4]
		var nextState = States[ActiveState][States.activeFrame][3]
		if(nextState == ""):
			nextState = default_state

		if (ActiveState == "DODGE"  && nextFrame==3 && longDodge<DodgeLength && (dodgeLEvent || dodgeREvent)):
			nextFrame = States.activeFrame
			longDodge += 1
		States.activeFrame = nextFrame
		ActiveState = nextState

func getCurrentState():
	return States[ActiveState][States.activeFrame];
	
func setActiveState(State, inv=false):
	ActiveState = State
	States.delta = 0;
	States.activeFrame = 0;
	States.inverse = inv;
	
func playSound(sound):
	if(sound=="Hit"):
			HitSound.play()
	if(sound=="Block"):
			BlockSound.play()
	if(sound=="Ding"):
		DingSound.play()
	if(sound=="UpperCut"):
		UpperCutSound.play()

func handleDodge(Enemy):
	Enemy.HitCount=0
	WeakCounter-=1;
	WeakCounter = max(WeakCounter, 0)
	Dodged=true
	if(WeakCounter == 0 && Stamina == 0):
		default_state = "IDLE"
		Stamina+=75
