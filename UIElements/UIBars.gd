extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (NodePath) var PlayerPath
export (NodePath) var EnemyPath
var Player = null
var Enemy = null
var currentPlayerHealth=100
var currentEnemyHealth=100
var currentStamina=100
var threshold=1
var final_score =0
var scores = [
	['Flawless',10000],
	['Perfect',5000],
	['Time',1039],
	['Time Bonus',1000],
	['Power Attack Bonus',500],
]
var score_delay=1
onready var PlayerHealthBar = self.get_node("PlayerLifeFg")
onready var PlayerStaminaBar = self.get_node("PlayerStaminaFg")
onready var Fade = self.get_node("FadeOut/Black")
onready var TimeNode = self.get_node("TimeLabel")
onready var EnemyHealthBar = self.get_node("EnemyLifeFg")

onready var PauseMenu = get_node("PauseMenu")

onready var ScorePopup = self.get_node("ScorePopup")
onready var ScoreNames = self.get_node("ScorePopup/ScoreNames")
onready var ScorePoints = self.get_node("ScorePopup/ScorePoints")
onready var FinalScoreContainer =  self.get_node("ScorePopup/FinalScore")
onready var FinalScore = self.get_node("ScorePopup/FinalScore/Score")
onready var NewRecord = self.get_node("ScorePopup/NewRecord")
onready var Click = self.get_node("Click")
onready var Heavy = self.get_node("Heavy")
onready var Winning = self.get_node("Win")

var PowerColors = [
	[0.5,0.5,1],
	[0.5,1,0.5],
	[1,0.5,0.5],
]
var PCIndex=0
var PCIndexNext=1
var PCTransition=0

# Called when the node enters the scene tree for the first time.
func _ready():
	Player = get_node(PlayerPath).get_node('AnimatedSprite')
	Enemy = get_node(EnemyPath).get_node("AnimatedSprite")
	ScoreNames.text = ""
	ScorePoints.text = ""
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var time = Player.TimeElapsed
	var mins = int(time / 60)
	var secs = int(time - mins*60)
	
	if(mins < 10):
		mins = '0'+str(mins)
	else:
		mins = str(mins)
	if(secs < 10):
		secs = '0'+str(secs)
	else:
		secs = str(secs)
	TimeNode.text = mins+':'+secs
	
	Fade.color =  Color(0,0,0, Player.DownTime/10.0)
	var playerHealth = Player.Health
	var HealthDiff = currentPlayerHealth - playerHealth;
	if(currentPlayerHealth > playerHealth+threshold):
		currentPlayerHealth -= delta*50
	elif(currentPlayerHealth < playerHealth-threshold):
		currentPlayerHealth += delta*50
	else:
		currentPlayerHealth = playerHealth
	PlayerHealthBar.rect_scale = Vector2(float(currentPlayerHealth)/100.0, 1)
	
	var Stamina = Player.Stamina
	var AttackPowerDiff = currentStamina - Stamina;
	if(currentStamina > Stamina+threshold):
		currentStamina -= delta*50
	elif(currentStamina < Stamina-threshold):
		currentStamina += delta*50
	else:
		currentStamina = Stamina
	PlayerStaminaBar.rect_scale = Vector2(float(currentStamina)/100.0, 1)
	
	var enemyHealth = Enemy.Health
	HealthDiff = currentEnemyHealth - enemyHealth;
	if(currentEnemyHealth > enemyHealth+threshold):
		currentEnemyHealth -= delta*10
	elif(currentEnemyHealth < enemyHealth-threshold):
		currentEnemyHealth += delta*10
	else:
		currentEnemyHealth = enemyHealth
	EnemyHealthBar.rect_scale = Vector2(float(currentEnemyHealth)/100.0, 1)
	
	pass

func drawScores(delta):
	PCTransition += delta*2;
	while(PCTransition > 1):
		PCTransition -= 1
		PCIndex += 1
	
	
	if(PCIndex >= PowerColors.size()):
			PCIndex = 0
	PCIndexNext = PCIndex + 1
	if(PCIndexNext >= PowerColors.size()):
		PCIndexNext = 0
	
	
	var r = lerp(PowerColors[PCIndex][0], PowerColors[PCIndexNext][0], PCTransition)
	var g = lerp(PowerColors[PCIndex][1], PowerColors[PCIndexNext][1], PCTransition)
	var b = lerp(PowerColors[PCIndex][2], PowerColors[PCIndexNext][2], PCTransition)
	NewRecord.add_color_override("font_color", Color(r,g,b,1))
	ScorePopup.visible=true
	score_delay-= delta
	if(score_delay < 0 && scores.size() > 0):
		score_delay=1
		var s = scores.pop_front()
		ScoreNames.text += "\n"+s[0]
		ScorePoints.text+= "\n"+str(s[1])
		final_score+=s[1]
		Click.play()
	if(scores.size()==0 && score_delay < 0 && !FinalScoreContainer.visible):
		FinalScore.text = str(final_score)
		FinalScoreContainer.visible = true
		score_delay = 2 
		Heavy.play()
	
	if(global.Records[global.GameMode][global.FightLevel]['HIGHSCORE']<final_score):
		if(Winning.is_playing() && FinalScoreContainer.visible && score_delay < 0):
			NewRecord.visible=true
			global.writeScore(final_score)
	
		if(!NewRecord.visible && FinalScoreContainer.visible && score_delay < 0):
			Winning.play()
			score_delay = 0.15
