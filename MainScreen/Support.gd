extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (String, FILE) var BackPage
export (String, FILE) var SupportPage
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if(event.is_action_released('gui_game_mode')):
		get_tree().change_scene_to(load(BackPage))
	
	if(event.is_action_released('gui_support')):
		global.payment.purchase("early_access_support")
