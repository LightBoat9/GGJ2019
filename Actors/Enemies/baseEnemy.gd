extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

# State
var state

# Graphics
var mySprite
var tex_idle
var tex_dead

# Stats
var health
var maxHealth = 5
var shrimpValue = 1

enum States {basic, dead}

func _ready():
	mySprite = get_node("Sprite")
	
	state = States.basic
	health = maxHealth

func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		_takeDamage(1)

func _updateGraphics():
	var newTex = null
	
	if (state == States.dead):
		print("Switching to Dead Sprite")
		newTex = tex_dead
	
	if (newTex != null):
		mySprite.texture = newTex

#inflicts damage to this enemy
func _takeDamage(var damage):
	if (state == States.dead):
		pass
	else:
		print("Taking "+String(damage)+" damage")
		
		health = max(health - damage, 0)
		
		if (health == 0):
			state = States.dead
			_updateGraphics()

#deletes dead enemy and returns number of shrimp to spawn
func _consume():
	if (state == States.dead):
		queue_free()
		return shrimpValue