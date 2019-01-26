extends 'res://delete.gd'

const Shrimp = preload("res://Actors/Shrimp/Shrimp.tscn")

var shrimp_speed = 50

var shrimp = []
var max_shrimp = 5

onready var  TopLevel = get_node('/root').get_child(get_node('/root').get_child_count() - 1)

func  _ready():
	call_deferred('add_shrimp')
	move_shrimp()
	
func _input(event):
	if event is InputEventMouseMotion:
		update_position()

func _process(delta):
	update_position()
	
func update_position():
	# Update shrimp origin position
	var mouse_angle = get_global_mouse_position().angle_to_point(get_parent().global_position)
	var vmouse_angle = Vector2(cos(mouse_angle), sin(mouse_angle))
	position = vmouse_angle * min(64, get_parent().global_position.distance_to(get_global_mouse_position()))

func _physics_process(delta):
	move_shrimp()

func add_shrimp():
	var inst = Shrimp.instance()
	inst.global_position = global_position - Vector2(100, 100)
	shrimp.append(inst)
	TopLevel.add_child(inst)
	
func move_shrimp():
	for sh in shrimp:
		# Loops through all shrimp
		# Make em move :) i cant