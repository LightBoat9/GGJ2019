extends KinematicBody2D

onready var shrimp_origin = $ShrimpOrigin

var aoi_radius = 64

var movespeed = 0.75
var maxmovespeed = 5
var velocity = Vector2()

func _draw():
	draw_circle(Vector2(), aoi_radius, Color(0, 0, 0, 0.3))
	
func _physics_process(delta):
	handle_movement(delta)
	
func handle_movement(delta):
	var h_in = int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A))
	var v_in = int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W))
	
	if h_in != 0:
		velocity.x += h_in * movespeed
	else:
		velocity.x -= sign(velocity.x) * movespeed
		if abs(velocity.x) < movespeed:
			velocity.x = 0 
	
	if v_in != 0:
		velocity.y += v_in * movespeed
	else:
		velocity.y -= sign(velocity.y) * movespeed
		if abs(velocity.y) < movespeed:
			velocity.y = 0 
		
	velocity = velocity.clamped(maxmovespeed)
	
	var temp = position.x
	move_and_slide(velocity / delta)