extends KinematicBody2D

onready var shrimp_origin = $ShrimpOrigin

var movespeed = 0.75
var maxmovespeed = 5
var velocity = Vector2()

func _draw():
	draw_circle(Vector2(), 64, Color(0, 0, 0, 0.3))
	
func _physics_process(delta):
	handle_movement()
	
func handle_movement():
	var h_in = int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A))
	var v_in = int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W))
	
	if h_in != 0:
		print('test')
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
	
	move_and_collide(velocity)