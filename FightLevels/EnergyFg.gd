extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var currentAttackPower=100
var Player = null
export (NodePath) var PlayerPath

# Called when the node enters the scene tree for the first time.
func _ready():
	Player = get_node(PlayerPath).get_node("AnimatedSprite")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var Stamina = Player.Stamina
	var AttackPowerDiff = currentAttackPower - Stamina;
	if(currentAttackPower > Stamina):
		currentAttackPower -= delta*50
	elif(currentAttackPower < Stamina):
		currentAttackPower += delta*50
	else:
		currentAttackPower = Stamina
	self.rect_scale = Vector2(currentAttackPower/100, 1)
	pass
