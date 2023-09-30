extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (PackedScene) var NextScene
# Called when the node enters the scene tree for the first time.
func _ready():
	#var p = get_node("AnimationPlayer")
	#p.play("CutScene")
	#yield(p, "animation_finished")
	#get_tree().change_scene_to(NextScene)
	
	var p = get_node("VideoPlayer")
	p.play()
	yield(p, "finished")
	get_tree().change_scene_to(NextScene)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
