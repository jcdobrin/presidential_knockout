extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Enemy = null;
var Player = null;
var time=0
var endtime=0
var PopUpAlpha = 1
var PopUpAlphaDir = 1
var TimeElapsed=0
var Paused=false
var MusicRestore=0 
onready var PopupNode   = get_node("PopUps")
onready var PopupText   = get_node("PopUps/Text")
onready var GUI         = get_node("GUI")
onready var UI          = get_node("UIBars")
onready var HighPunchL  = get_node("GUI/HighPunchL")
onready var LowPunchL   = get_node("GUI/LowPunchL")
onready var HighPunchR  = get_node("GUI/HighPunchR")
onready var LowPunchR   = get_node("GUI/LowPunchR")
onready var UpperCut    = get_node("GUI/UpperCutGroup")
onready var DodgeL      = get_node("GUI/DodgeL")
onready var DodgeR      = get_node("GUI/DodgeR")
onready var BlockL      = get_node("GUI/BlockL")
onready var BlockR      = get_node("GUI/BlockR")
onready var GetUpButton = get_node("GUI/GetUp")

onready var Flash       = get_node("Background/Flash")
onready var FightMusic  = get_node("BackgroundMusic")

export (String, FILE) var NextScene
export (NodePath) var EnemyPath
export (NodePath) var PlayerPath

# Called when the node enters the scene tree for the first time.
func _ready():
	Enemy = get_node(EnemyPath).get_child(0);
	Player = get_node(PlayerPath).get_child(0);
	GUI.visible = false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Flash.visible = false
	time += delta
	if(time < 3.1):
		Enemy.offset.x = 250;
		GUI.visible = false
		intro(delta)
	elif(Enemy.isDefeated):
		GUI.visible = false
		win(delta)
	elif(Player.isDefeated):
		GUI.visible = false
		lose(delta)
	elif(Paused):
		if(Input.is_action_pressed("gui_resume")):
			Paused=false
			FightMusic.play()
			FightMusic.seek(MusicRestore)
			UI.PauseMenu.visible=false
		if(Input.is_action_pressed("gui_quit")):
			UI.PauseMenu.visible=false
			get_tree().change_scene_to(load(NextScene))
	else:
		GUI.visible = true
		if(Input.is_action_pressed("gui_pause")):
			Paused=true
			MusicRestore = FightMusic.get_playback_position()
			FightMusic.stop()
			UI.PauseMenu.visible=true
		else:
			fight(delta)

func intro(_delta):
	FightMusic.volume_db = -30 + (  10 * (time/6) )
			
	if(time < 1):
		PopupText.visible = true
		PopupText.text = "READY"
	elif(time < 2):
		PopupText.visible = true
		PopupText.text = "FIGHT"
			
	if(time > 3):
		PopupText.text = ""
		PopupText.visible = false
		
	
	pass

func lose(delta):
	endtime+=delta
	if(endtime > 2):
		get_tree().reload_current_scene()
	if(endtime > 1):
		PopupText.visible = true
		PopupText.text = "YOU\nLOSE"
	pass

func win(delta):
	if(endtime==0):
		Player.play('Victory')
		UI.scores = []
		if(Enemy.EnemyDodgeCount==0 && Enemy.EnemyBlockCount==0 && Enemy.PlayerHitCount==0):
			UI.scores.push_back(['Flawless', 10000])
		
		elif(Enemy.PlayerHitCount==0):
			UI.scores.push_back(['Perfect', 5000])
		
		UI.scores.push_back(['Hits', 10*(Enemy.EnemySuperHitCount+Enemy.EnemyHitCount)])
		
		if(Player.TimeElapsed < 600):
			print(Player.TimeElapsed)
			UI.scores.push_back(['Time', int(1000 * (600-Player.TimeElapsed)/600)])
		if(Player.TimeElapsed < 300):
			UI.scores.push_back(['Time Bonus', 500])
			
		if(Enemy.EnemySuperHitCount > 0):
			UI.scores.push_back(['Power Hits', 100*Enemy.EnemySuperHitCount])
		if(Enemy.EnemySuperHitCount > 3):
			UI.scores.push_back(['Power Hit Bonus', 1000])
	
		#Achievements Scores
		if(Enemy.PlayerBlockCount > 25):
			UI.scores.push_back(['Stonewall', 10000])
		if(Enemy.EnemySuperHitCount > 10):
			UI.scores.push_back(['Overpowered', 1000])
		if(Player.TimeElapsed < 60):
			UI.scores.push_back(['Speed Demon', 10000])
		if(global.GameMode=='HARD' && Player.TimeElapsed < 120):
			UI.scores.push_back(['Speed Demon', 10000])
	
	endtime+=delta
	
	if(endtime > 15):
		get_tree().change_scene_to(load(NextScene))
	if(endtime > 2):
		UI.drawScores(delta)
	pass 
	
func fight(delta):
	var EnemyState = Enemy.getCurrentState()
	var PlayerState = Player.getCurrentState()
	var ActiveColor = Color(1,0.5,0.5,1)
	var InactiveColor = Color(1,1,1,1)
	if(global.GameMode=="Easy"):
		if(Enemy.States[Enemy.ActiveState].size() > Enemy.States.activeFrame+1
		 && Enemy.States[Enemy.ActiveState][Enemy.States.activeFrame+1][7]=='Attack'):
			DodgeL.set_modulate(ActiveColor)
			DodgeR.set_modulate(ActiveColor)
			BlockL.set_modulate(ActiveColor)
			BlockR.set_modulate(ActiveColor)
		elif(Enemy.States[Enemy.ActiveState].size() > Enemy.States.activeFrame+2
		 && Enemy.States[Enemy.ActiveState][Enemy.States.activeFrame+2][7]=='Attack'):
			DodgeL.set_modulate(ActiveColor)
			DodgeR.set_modulate(ActiveColor)
			BlockL.set_modulate(ActiveColor)
			BlockR.set_modulate(ActiveColor)
		elif(Enemy.States[Enemy.ActiveState].size() > Enemy.States.activeFrame+3
		 && Enemy.States[Enemy.ActiveState][Enemy.States.activeFrame+3][7]=='Attack'):
			DodgeL.set_modulate(ActiveColor)
			DodgeR.set_modulate(ActiveColor)
			BlockL.set_modulate(ActiveColor)
			BlockR.set_modulate(ActiveColor)
		elif(Enemy.States[Enemy.ActiveState].size() > Enemy.States.activeFrame+4
		 && Enemy.States[Enemy.ActiveState][Enemy.States.activeFrame+4][7]=='Attack'):
			DodgeL.set_modulate(ActiveColor)
			DodgeR.set_modulate(ActiveColor)
			BlockL.set_modulate(ActiveColor)
			BlockR.set_modulate(ActiveColor)
		elif(Enemy.States[Enemy.ActiveState].size() > Enemy.States.activeFrame+5
		 && Enemy.States[Enemy.ActiveState][Enemy.States.activeFrame+5][7]=='Attack'):
			DodgeL.set_modulate(ActiveColor)
			DodgeR.set_modulate(ActiveColor)
			BlockL.set_modulate(ActiveColor)
			BlockR.set_modulate(ActiveColor)
		else:
			DodgeL.set_modulate(InactiveColor)
			DodgeR.set_modulate(InactiveColor)
			BlockL.set_modulate(InactiveColor)
			BlockR.set_modulate(InactiveColor)
		
		if(Enemy.noBlock==true):
			BlockL.set_modulate(InactiveColor)
			BlockR.set_modulate(InactiveColor)
			
		if(EnemyState[7]=='CanBeHighHit' && EnemyState[9]==0 && Enemy.MoveQueue.size()==0):
			HighPunchR.set_modulate(ActiveColor)
			HighPunchL.set_modulate(ActiveColor)
			LowPunchR.set_modulate(InactiveColor)
			LowPunchL.set_modulate(InactiveColor)
		elif(EnemyState[7]=='CanBeLowHit' && EnemyState[9]==0 && Enemy.MoveQueue.size()==0):
			HighPunchR.set_modulate(InactiveColor)
			HighPunchL.set_modulate(InactiveColor)
			LowPunchR.set_modulate(ActiveColor)
			LowPunchL.set_modulate(ActiveColor)	
		elif(EnemyState[7]=='CanBeHit' && EnemyState[9]==0 && Enemy.MoveQueue.size()==0):
			HighPunchR.set_modulate(ActiveColor)
			HighPunchL.set_modulate(ActiveColor)
			LowPunchR.set_modulate(ActiveColor)
			LowPunchL.set_modulate(ActiveColor)
		else:
			HighPunchR.set_modulate(InactiveColor)
			HighPunchL.set_modulate(InactiveColor)
			LowPunchR.set_modulate(InactiveColor)
			LowPunchL.set_modulate(InactiveColor)
	if(EnemyState[9] > 0):
		Flash.visible = true
	if Player.PowerAttacks > 0:
		UpperCut.visible = true
	else:
		UpperCut.visible = false
	
	if PlayerState[7] == 'Down' || EnemyState[7] == 'Down' || EnemyState[7] == 'Walk':
		HighPunchL.visible = false
		HighPunchR.visible = false
		LowPunchL.visible = false
		LowPunchR.visible = false
		UpperCut.visible = false
		DodgeL.visible = false
		DodgeR.visible = false
		BlockL.visible = false
		BlockR.visible = false
	else:
		Player.TimeElapsed+=delta
		DodgeL.visible = true
		DodgeR.visible = true
		if Player.Stamina==0:
			HighPunchL.visible = false
			HighPunchR.visible = false
			LowPunchL.visible = false
			LowPunchR.visible = false
			UpperCut.visible = false
			BlockL.visible = false
			BlockR.visible = false
		else:
			HighPunchL.visible = true
			HighPunchR.visible = true
			LowPunchL.visible = true
			LowPunchR.visible = true
			BlockL.visible = true
			BlockR.visible = true
		
	if(PopupText.visible):
		PopupNode.modulate  = Color(1,1,1,PopUpAlpha)
		PopUpAlpha -= PopUpAlphaDir * (delta*10)
		if(PopUpAlpha < 0.1):
			PopUpAlpha = 0.1;
			PopUpAlphaDir *= -1
		if(PopUpAlpha > 1):
			PopUpAlpha = 1;
			PopUpAlphaDir *= -1
	
	if(PlayerState[7] == 'Down'):
		GetUpButton.visible = true
		PopupText.visible = true
		PopupText.text = "TAP"
	else:
		GetUpButton.visible = false
		PopupText.visible = false
		
	Enemy.OpponentWeak = Player.Stamina==0
	#if(Enemy.Health < 50 && (Enemy.ActiveState=='IDLE' || Enemy.ActiveState=='IDLE_HIGH')):
	#	EnemyState[7]='CantBeHighHit'
	
	if(Player.ActiveState=='KNOCKOUT'):
		if(Enemy.ActiveState != 'IDLE'):
			Enemy.setActiveState('IDLE');
			Enemy.AttackCounter=0
			Enemy.MoveDelta=0

	else:
		if(Enemy.isHit ||
		(EnemyState[7]=='WindUp' && PlayerState[7] != 'SuperAttack') ||
		EnemyState[7]=='Attack' ||
		EnemyState[7]=='BeingHit' ||
		EnemyState[7]=='Blocking' ||
		EnemyState[7]=='Down' ||
		EnemyState[7]=='Walk'): #nothing can stop an attack
			pass
		elif(!Player.wasBlockedOrNot):
			if(PlayerState[7]=='SuperAttack'):
				Enemy.handleHit(Player)
			elif((EnemyState[7]=='CanBeHighHit' || EnemyState[7]=='CanBeHit') && PlayerState[7]=='HighAttack'):
				Enemy.handleHit(Player)
			elif((EnemyState[7]=='CanBeLowHit' || EnemyState[7]=='CanBeHit')  && PlayerState[7]=='LowAttack'):
				Enemy.handleHit(Player)
			elif(PlayerState[7]=='HighAttack' || PlayerState[7]=='LowAttack'):
				Enemy.handleBlock(Player)
			
		if(EnemyState[7]!='Attack'):
			Player.Dodged = false;
			Player.Hit = false;
		
		if(Player.Dodged || Player.Hit):
			pass
		
		elif(EnemyState[7]=='Attack' && PlayerState[7]=='Blocking'):
			Enemy.handlePlayerBlock(Player)
		
		elif(EnemyState[7]=='Attack'  && PlayerState[7]!='CantBeHit'):
			Enemy.handlePlayerHit(Player)
			
		elif(EnemyState[7]=='Attack'  && PlayerState[7]=='CantBeHit'):
			Enemy.PlayerDodgeCount+=1
			Player.handleDodge(Enemy)
		
	Player.process(delta, Enemy)
	Enemy.process(delta, Player)
	FightMusic.set_pitch_scale(0.7)
