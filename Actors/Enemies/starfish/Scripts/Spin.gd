extends Node

var movespeed = 5

var spin_angle = Vector2()
onready var spin_timer = $SpinTimer

func state_entered():
	var closest_inst = get_tree().get_nodes_in_group('Players')[0]
	for inst in get_tree().get_nodes_in_group('Players'):
		if get_parent().get_parent().global_position.distance_to(inst.global_position) < get_parent().get_parent().global_position.distance_to(closest_inst.global_position):
			closest_inst = inst
			
	var angle = closest_inst.global_position.angle_to_point(get_parent().get_parent().global_position)
	spin_angle = Vector2(cos(angle), sin(angle))
	get_parent().get_parent().set_collision_layer_bit(0, true)
	
	spin_timer.start()

func state_process(delta):
	if spin_timer.time_left == 0:
		get_parent().state = get_parent().States.FLOAT

func state_physics_process(delta):
	get_parent().get_parent().get_node('Sprite').rotation += 0.25
	get_parent().get_parent().move_and_slide(spin_angle * movespeed / delta)
	
	if get_parent().get_parent().get_slide_count() > 0:
		var col = get_parent().get_parent().get_slide_collision(get_parent().get_parent().get_slide_count() - 1)
	
		if col.collider.is_in_group('Players'):
			
			if (col.collider.is_in_group("Shrimp")):
				col.collider.kockback(col.normal * -10, 0.5, 2)
			
			if col.collider.is_in_group("Crab"):
				col.collider.take_damage(1)
				var angle = col.collider.global_position.angle_to_point(get_parent().get_parent().global_position)
				var vangle = Vector2(cos(angle), sin(angle))
				col.collider.knockback(vangle * 10, 0.2)
				get_parent().state = get_parent().States.FLOAT