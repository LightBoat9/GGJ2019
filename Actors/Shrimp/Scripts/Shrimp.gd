extends KinematicBody2D

signal ImDead

const DeathParticles = preload('res://Actors/Shrimp/DeathParticles.tscn')

var target_position = null
var velocity = Vector2()
var knockback_velocity = Vector2()

var acceleration = 2
var maxSpeed = 8
var launchSpeed = 12
var minSpin = 0.05
var maxSpin = 0.25

var swarmDamage = 0.1
var launchDamage = 0.25

var enemy_touching
var shrimp_cursor = null

enum States { DEFAULT, LAUNCHING, KNOCKBACK } 
var state = States.DEFAULT

onready var area = $Area2D
onready var attack_timer = $AttackTimer
onready var knockback_timer = $KnockbackTimer
onready var launch_timer = $LaunchTimer

var launch_passed = false

func _ready():
	add_to_group("Players")
	add_to_group("Shrimp")
	
	if not area.is_connected('body_entered', self, '_body_entered'):
		area.connect('body_entered', self, '_body_entered')
		
	if not area.is_connected('body_exited', self, '_body_exited'):
		area.connect('body_exited', self, '_body_exited')
	target_position = Vector2()
	minSpin += rand_range(-0.01,0.02)
	maxSpin += rand_range(-0.05,0.05)

func _process(delta):
	if enemy_touching and attack_timer.time_left == 0 and Input.is_mouse_button_pressed(BUTTON_RIGHT):
		var spawn = enemy_touching.shrimpInteract(swarmDamage)
		if (spawn>0):
			_spawn_shrimp(spawn)
		
		attack_timer.start()
		
	if state == States.KNOCKBACK and knockback_timer.time_left == 0:
		state = States.LAUNCHING
		_return_to_cursor()

func _physics_process(delta):
	if (state == States.LAUNCHING):
		_launch_update()
	else:
		velocity = velocity_to_target()
		velocity = velocity.clamped(maxSpeed)
	
	var velocityMag = velocity.distance_to(Vector2())
	
	rotation += lerp(minSpin, maxSpin, velocityMag/maxSpeed)
	
	if state != States.KNOCKBACK:
		move_and_slide(velocity/delta)
	else:
		move_and_slide(knockback_velocity / delta)
	
	if (state == States.LAUNCHING && get_slide_count()>0):
		var slideCollide = get_slide_collision(get_slide_count()-1)
		
		if (slideCollide != null):
			var collider = slideCollide.collider
			
			if collider.get_collision_layer_bit(0):
				kockback(slideCollide.normal * 5, 0.2)
				launch_timer.stop()
				_return_to_cursor()
	
	
	pass

func assign_target(var targ):
	target_position = targ
	update()
	
func kockback(velocity, duration):
	if state != States.KNOCKBACK:
		state = States.KNOCKBACK
		knockback_velocity = velocity
		knockback_timer.wait_time = duration
		knockback_timer.start()
		
		if (!launch_timer.is_stopped()):
			launch_timer.stop()

func kill_shrimp(anglev=Vector2()):
	var inst = DeathParticles.instance()
	inst.global_position = global_position
	inst.rotation = anglev.angle()
	get_parent().add_child(inst)
	
	emit_signal("ImDead")
	emit_signal("ImDead", self)
	
	if self in shrimp_cursor.shrimp:
		shrimp_cursor.remove_shrimp(shrimp_cursor.shrimp.find(self))
		
	shrimp_cursor = null
		
	queue_free()

func velocity_to_target():
	if (state == States.LAUNCHING):
		return velocity
	
	var local_target = target_position - global_position
	var moveVect = local_target.normalized()
	
	var final = velocity + moveVect * acceleration
	
	var distanceMag = local_target.distance_to(Vector2())
	var projection = 0 if (distanceMag == 0) else final.dot(local_target)/distanceMag
	var finalClamp = min(projection,distanceMag)
	
	return final.clamped(0 if (finalClamp < 0.01) else finalClamp)

func launch(var to):
	var launchDirection = to - global_position
	velocity = launchDirection.normalized() * launchSpeed
	target_position = to
	state = States.LAUNCHING
	launch_passed = false
	launch_timer.start()

func _launch_update():
	var to_target = target_position - global_position
	var targetMag = to_target.distance_to(Vector2())
	
	var targetProjection = 0 if (targetMag == 0) else velocity.dot(to_target)/targetMag
	
	if (targetProjection<=0):
		launch_passed = true
		if launch_timer.is_stopped():
			_return_to_cursor()

func _launch_timer_up():
	if launch_passed:
		_return_to_cursor()

func _return_to_cursor():
	if (shrimp_cursor != null and state == States.LAUNCHING):
		shrimp_cursor.add_shrimp_existing(self)
		state = States.DEFAULT

func _body_entered(body):
	if body.is_in_group('Enemies'):
		enemy_touching = body
		
		if (state == States.LAUNCHING):
			var spawn = enemy_touching.shrimpInteract(launchDamage)
			
			if (spawn>0):
				_spawn_shrimp(spawn)
			
			launch_timer.stop()
			
			_return_to_cursor()

func _body_exited(body):
	if body.is_in_group('Enemies'):
		enemy_touching = null

func _spawn_shrimp(var n):
	if shrimp_cursor != null:
		for i in n:
			shrimp_cursor.add_shrimp(global_position)