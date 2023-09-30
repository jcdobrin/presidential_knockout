extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var HighPunchL = get_node("HighPunchL")
onready var LowPunchL = get_node("LowPunchL")
onready var HighPunchR = get_node("HighPunchR")
onready var LowPunchR = get_node("LowPunchR")
onready var UpperCutGroup = get_node("UpperCutGroup")
onready var UpperCutText = get_node("UpperCutGroup/TextContainer/Text")
var PowerColors = [
	[0.5,0.5,1],
	[0.5,1,0.5],
	[1,0.5,0.5],
]
var PCIndex=0
var PCIndexNext=1
var PCTransition=0
var LPLTimer = -1;
var LPRTimer = -1;
var HPRTimer = -1;
var HPLTimer = -1;
var delay = 0.5
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	changeCol(Color(r, g, b, 1.0), UpperCutText)
	
func changeCol(col, node):
	if(node.get_class() == "Label"):
		node.add_color_override("font_color", col)
	else:
		node.set_modulate(col)
