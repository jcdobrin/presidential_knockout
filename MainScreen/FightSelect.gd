extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (String, FILE) var Fight1Page
export (String, FILE) var Fight2Page
export (String, FILE) var Fight3Page
export (String, FILE) var SupportPage
export (String, FILE) var GameModePage
onready var SupportButton = get_node("SupportButt2")
onready var SupportLabel = get_node("Support2")
# Called when the node enters the scene tree for the first time.
func _ready():
	if global.paymentReady():
		if(!global.EarlyAccessSupport):
			SupportButton.visible = true
			SupportLabel.visible = true
		pass
	if(!global.MenuMusic.is_playing()):
		global.MenuMusic.play()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	var scene = null
	if(event.is_action_released('gui_fight1')):
		global.MenuMusic.stop()
		scene = load(Fight1Page)
		global.FightLevel='Level 1'

	if(event.is_action_released('gui_fight2')):
		global.MenuMusic.stop()
		scene = load(Fight2Page)
		global.FightLevel='Level 2'
		
	if(event.is_action_released('gui_fight3')):
		global.MenuMusic.stop()
		scene = load(Fight3Page)
		global.FightLevel='Level 3'
		
	if(event.is_action_released('gui_support')):
		scene = load(SupportPage)
		
	if(event.is_action_released('gui_game_mode')):
		scene = load(GameModePage)

	if(scene):
		#var scene_instance = scene.instance()
		get_tree().change_scene_to(scene)
