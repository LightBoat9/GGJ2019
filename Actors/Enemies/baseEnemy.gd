extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

# State
var state

# Graphics
var mySprite
onready var tex_idle = load("res://Actors/Enemies/debugEnemy.png")
onready var tex_dead = load("res://Actors/Enemies/debugEnemy_dead.png")

# Stats
var shrimpValue = 2
onready var healthCircle = PoolVector2Array()
var health
var maxHealth = 5
var healthCircle_sections = 30
var healthCircle_radius = 16
var healthCircle_offset = Vector2(0,-48)

func _ready():
	
	#public relations
	add_to_group("Enemies")
	health = maxHealth
	
	#graphics
	mySprite = get_node("Sprite")
	generate_healthCircle(healthCircle_offset,healthCircle_radius)

#general function to call when a shrimp interacts with this enemy
func shrimpInteract(var shrimpPower):
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
		
		generate_healthCircle(healthCircle_offset,healthCircle_radius)
		update()
		
		if (health == 0):
			_die()

func _die():
	mySprite.texture = tex_dead

#deletes dead enemy and returns number of shrimp to spawn
func _consume():
	queue_free()
	return shrimpValue

func generate_healthCircle(var offset, var radius):
	#empty healthCircle
	healthCircle.resize(0)
	
	#center vertex
	healthCircle.append(offset)
	
	var angleIter = 360/healthCircle_sections
	var partialSections = (float(health)/float(maxHealth)) * healthCircle_sections
	
	for i in range(partialSections+1):
		var radian = deg2rad(90+i*angleIter)
		healthCircle.append(offset+Vector2(cos(radian),-sin(radian))*radius)

func _draw():
	if (health>0 && health<maxHealth):
		draw_circle(healthCircle_offset,healthCircle_radius+1,Color(0,0,0))
		if (healthCircle.size()>=3):
			draw_colored_polygon(healthCircle, Color(0,1,0))
