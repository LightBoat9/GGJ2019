extends 'res://delete.gd'

const Shrimp = preload("res://Actors/Shrimp/Shrimp.tscn")

var shrimp_speed = 50

#shrimp tracking
var shrimp = []
var max_shrimp = 5

#shrimp rings
var padding_per_ring = 16
var shrimp_size = 16
var ringCapacity = []
var totalRingCapacity = 0
var shrimp_ring_positions = []

onready var  TopLevel = get_node('/root').get_child(get_node('/root').get_child_count() - 1)

func  _ready():
	for i in range(25):
		add_shrimp()
	
	update_ring_positions()
	
	print("Total capacity: "+String(totalRingCapacity))

func _draw():
	for pos in shrimp_ring_positions:
		draw_circle(pos,shrimp_size/2,Color(0,1,0,0.3))

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
	
	
	if (shrimp.size()>=totalRingCapacity):
		append_ring_capacity()

func update_ring_positions():
	shrimp_ring_positions.clear()
	
	var ringShrimpTotal = 0
	
	for c in ringCapacity.size():
		var cap = min(ringCapacity[c], shrimp.size()-ringShrimpTotal)
		
		if (cap<=0):
			break
		
		ringShrimpTotal += cap
		var radius = (c+1) * padding_per_ring
		var radianIter = deg2rad(360/float(cap))
		
		for i in range(cap):
			var pos = Vector2(radius*cos(radianIter*i),radius*sin(radianIter*i))
			shrimp_ring_positions.append(pos)

func append_ring_capacity():
	var newIndex = ringCapacity.size()
	
	ringCapacity.append(floor(calculate_ring_capacity(newIndex)))
	totalRingCapacity += ringCapacity[newIndex]

#calculates number of shrimp that can fit in a given ring
func calculate_ring_capacity(var ringIndex):
	var ringRadius = (ringIndex+1) * padding_per_ring
	var ringCircumference = 2*PI*ringRadius
	
	return (ringCircumference / shrimp_size)

func move_shrimp():
	for sh in shrimp:
		# Loops through all shrimp
		# Make em move :) i cant