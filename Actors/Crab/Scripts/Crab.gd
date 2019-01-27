extends KinematicBody2D

onready var shrimp_origin = $GUI

var aoi_radius = 64

var movespeed = 0.75
var maxmovespeed = 5
var velocity = Vector2()

onready var gui_draw = $GUI
var health = 5
var maxHealth = 5

enum States { DEFAULT, KNOCKBACK }
var state = States.DEFAULT

var knockback_velocity = Vector2()
onready var knockback_timer = $KnockbackTimer

func _ready():
	add_to_group("Crab")
	add_to_group("Players")

func _process(delta):
	if state == States.KNOCKBACK and knockback_timer.time_left == 0:
		state = States.DEFAULT

#inflicts damage to this crab
func take_damage(var damage):
	if (health <= 0):
		pass
	else:
		print("Taking "+String(damage)+" damage")
		
		health = max(health - damage, 0)
		
		gui_draw.generate_healthCircle()

func _physics_process(delta):
	handle_movement(delta)
	
func knockback(vel, duration):
	if state != States.KNOCKBACK:
		state = States.KNOCKBACK
		knockback_velocity = vel
		knockback_timer.wait_time = duration
		knockback_timer.start()
	
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
	if state == States.DEFAULT:
		move_and_slide(velocity / delta)
	else:
		move_and_slide(knockback_velocity / delta)