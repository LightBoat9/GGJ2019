extends Node2D

onready var healthCircle = PoolVector2Array()
var healthCircle_sections = 30
var healthCircle_radius = 32
var healthCircle_padding = 8
var healthCircle_offset = Vector2(
		1024/2 - healthCircle_radius - healthCircle_padding, 
		600/2 - (healthCircle_radius + healthCircle_padding)
	)
	
var score = 0 setget set_score

onready var crab = get_parent()

func _ready():
	generate_healthCircle()

func set_score(var val):
	score = val
	update()

func _draw():
	draw_circle(healthCircle_offset,healthCircle_radius+1,Color(0,0,0))
	if (healthCircle.size()>=3):
		draw_colored_polygon(healthCircle, Color(0,0.4,1))
		
	draw_string(load("res://Fonts/font.tres"), Vector2(-1024/2 + 8, 600/2 - 8), str(score))
	
func generate_healthCircle():
	var offset = healthCircle_offset
	var radius = healthCircle_radius
	#empty healthCircle
	healthCircle.resize(0)
	
	#center vertex
	healthCircle.append(offset)
	
	var angleIter = 360/healthCircle_sections
	var partialSections = (float(crab.health)/float(crab.maxHealth)) * healthCircle_sections
	
	for i in range(partialSections+1):
		var radian = deg2rad(90+i*angleIter)
		healthCircle.append(offset+Vector2(cos(radian),-sin(radian))*radius)
	update()