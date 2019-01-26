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

func _ready():
	#public relations
	add_to_group("Enemies")
	health = maxHealth
	
	#graphics
	mySprite = get_node("Sprite")
	_loadTextures()

#general function to call when a shrimp interacts with this enemy
func _shrimpInteract(var shrimpPower):
	if (health > 0):
		_takeDamage(shrimpPower)
		return 0
	else:
		return _consume()

#inflicts damage to this enemy
func _takeDamage(var damage):
	if (health <= 0):
		pass
	else:
		print("Taking "+String(damage)+" damage")
		
		health = max(health - damage, 0)
		
		if (health == 0):
			_updateGraphics()

#deletes dead enemy and returns number of shrimp to spawn
func _consume():
	queue_free()
	return shrimpValue

#call when notable changes occur (mainly state changes)
func _updateGraphics():
	var newTex = null
	
	if (health<=0):
		print("Switching to Dead Sprite")
		newTex = tex_dead
	
	if (newTex != null):
		mySprite.texture = newTex

#override this to change what textures get loaded and where, etc.
func _loadTextures():
	tex_idle = load("res://Actors/Enemies/debugEnemy.png")
	tex_dead = load("res://Actors/Enemies/debugEnemy_dead.png")
