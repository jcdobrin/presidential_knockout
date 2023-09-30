extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
export (PackedScene) var NextScene
var time = 0
onready var LabelText = get_node("ColorRect/Label")

# Called when the node enters the scene tree for the first time.
func _ready():
	NextScene = load("res://MainScreen/MainScreen.tscn")	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if(time > 2.5 && global.GameMode == 'Easy'):
		LabelText.text = "Try\nHard\nMode"
	if(time > 5):
		get_tree().change_scene_to(NextScene)
	pass
