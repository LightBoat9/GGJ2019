extends KinematicBody2D

onready var shrimp_origin = $ShrimpOrigin

func _draw():
	draw_circle(Vector2(), 64, Color(0, 0, 0, 0.3))

func _input(event):
	if event is InputEventMouseMotion:
		update_shrimp()

func _process(delta):
	update_shrimp()
	
func update_shrimp():
	# Update shrimp origin position
	var mouse_angle = get_global_mouse_position().angle_to_point(global_position)
	var vmouse_angle = Vector2(cos(mouse_angle), sin(mouse_angle))
	shrimp_origin.position = vmouse_angle * min(64, global_position.distance_to(get_global_mouse_position()))