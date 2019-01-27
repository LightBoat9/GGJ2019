extends "res://Actors/Enemies/baseEnemy.gd"

func _ready():
	maxHealth = 2
	health = 2
	shrimpValue = 2
	
	tex_idle = load("res://Actors/Enemies/anememone.png")
	tex_dead = load("res://Actors/Enemies/anememone_2.png")
	generate_healthCircle(healthCircle_offset,healthCircle_radius)
	update()

func _die():
	mySprite.texture = tex_dead