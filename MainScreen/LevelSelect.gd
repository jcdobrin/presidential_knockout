extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (PackedScene) var FightSelectPage
export (PackedScene) var SupportPage
onready var SupportButton = get_node("SupportButt2")
onready var SupportLabel = get_node("Support2")
# Called when the node enters the scene tree for the first time.
func _ready():
	if global.paymentReady():
		if(!global.EarlyAccessSupport):
			SupportButton.visible = true
			SupportLabel.visible = true
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if(event.is_action_released('gui_game_mode_easy')):
		global.GameMode="Easy"
		get_tree().change_scene_to(FightSelectPage)
	
	if(event.is_action_released('gui_game_mode_normal')):
		global.GameMode="Normal"
		get_tree().change_scene_to(FightSelectPage)
	
	if(event.is_action_released('gui_game_mode_hard')):
		global.GameMode="Hard"
		get_tree().change_scene_to(FightSelectPage)
	
	if(event.is_action_released('gui_support')):
		get_tree().change_scene_to(SupportPage)
	
	if(event.is_action_released('gui_quit')):
		get_tree().quit()
