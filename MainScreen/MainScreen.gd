extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (PackedScene) var StartScene
onready var CLICK = get_node("Click")

# Called when the node enters the scene tree for the first time.
func _ready():
	global.checkPurchases()
	global.MenuMusic.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	
#	pass

func _input(event):
	if(event.is_action_released('gui_start_game')):
		CLICK.play()
		get_tree().change_scene_to(StartScene)
		
