extends Node

var sprite1 = preload("res://Actors/Enemies/starfish/starfish1.png")
var sprite2 = preload("res://Actors/Enemies/starfish/starfish2.png")

onready var animate_timer = $AnimateTimer
onready var rest_timer = $RestTimer
onready var roam_timer = $RoamTimer

var attack_range = 200
var idle_range = 400

var movespeed = 1
var move_vector = Vector2()

func state_entered():
	animate_timer.start()
	rest_timer.start()
	roam_timer.start()
	move_vector = Vector2(rand_range(0, 1), rand_range(0, 1))
	get_parent().get_parent().set_collision_layer_bit(0, false)
	
func state_exited():
	animate_timer.stop()
	
func state_process(delta):
	if animate_timer.time_left == 0:
		var star_sprite = get_parent().get_parent().get_node('Sprite')
		if star_sprite.texture == sprite1:
			star_sprite.texture = sprite2
		else:
			star_sprite.texture = sprite1
		animate_timer.start()
		
	if roam_timer.time_left == 0:
		move_vector = Vector2(rand_range(0, 1), rand_range(0, 1))
		roam_timer.start()
		
	if rest_timer.time_left == 0:
		for inst in get_tree().get_nodes_in_group('Players'):
			if get_parent().get_parent().global_position.distance_to(inst.global_position) < attack_range:
				get_parent().state = get_parent().States.SPIN
			
func state_physics_process(delta):
	get_parent().get_parent().get_node('Sprite').rotation += 0.05
	var crab = get_tree().get_nodes_in_group('Crab')[0]
	if crab:
		if get_parent().get_parent().global_position.distance_to(crab.global_position) < idle_range:
			get_parent().get_parent().move_and_slide(move_vector * movespeed / delta)