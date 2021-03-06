extends Node2D

const Shrimp = preload("res://Actors/Shrimp/Shrimp.tscn")

var shrimp_speed = 50

#shrimp tracking
var shrimp = []
var max_shrimp = 25
var shrimp_worldTotal = 0

#shrimp rings
var padding_per_ring = 16
var shrimp_size = 16
var ringCapacity = []
var totalRingCapacity = 0
var shrimp_ring_positions = [] #target positions relative to cursor

#randomizer
onready var rand_timer = $RandomizerTimer

onready var  TopLevel = get_node('/root').get_child(get_node('/root').get_child_count() - 1)
const cursor_tex = preload("res://Actors/Shrimp/Sprite/tempCenter.png")

func  _ready():
	shrimp_worldTotal = get_tree().get_nodes_in_group("Shrimp").size()
	print("Existing shrimp: "+str(shrimp_worldTotal))
	pass

"""
func _draw():
	draw_texture(
		cursor_tex, 
		get_local_mouse_position() - Vector2(cursor_tex.get_width() / 2, 
		cursor_tex.get_height() / 2)
	)
"""

func _input(event):
	update()
	if event is InputEventMouseMotion:
		update_position()
	
	if event is InputEventMouseButton:
		if (event.button_index == BUTTON_LEFT && event.pressed):
			var shrimpIndex = get_outer_shrimp()
			if (shrimpIndex!=-1):
				launch_shrimp(shrimpIndex)
		elif (event.button_index == BUTTON_RIGHT):
			if (event.pressed):
				randomize_shrimp()
				rand_timer.start()
			elif (!event.pressed):
				rand_timer.stop()
			
			update_ring_positions()
			update_shrimp_targets()
	
	if (event.is_action("ui_accept")):
		add_shrimp()
		update_ring_positions()
		update_shrimp_targets()
	
	if (event.is_action("ui_cancel")):
		var shrimpIndex = get_outer_shrimp()
		if (shrimpIndex!=-1):
			var thisShrimp = remove_shrimp(shrimpIndex)
			if (thisShrimp != null):
				thisShrimp.kill_shrimp()

func _process(delta):
	update_position()
	update()

func update_position():
	# Update shrimp origin position
	var mouse_angle = get_global_mouse_position().angle_to_point(get_parent().global_position)
	var vmouse_angle = Vector2(cos(mouse_angle), sin(mouse_angle))
	if rand_timer.is_stopped():
		position = vmouse_angle * min(get_parent().aoi_radius, get_parent().global_position.distance_to(get_global_mouse_position()))
	else:
		global_position = get_global_mouse_position()
	update_shrimp_targets()

func _physics_process(delta):
	pass

func add_shrimp(var pos = global_position):
	print(shrimp_worldTotal)
	
	if (shrimp_worldTotal>=max_shrimp):
		print("Bonus Points")
		get_parent().get_node("GUI").score+=100
		return
	
	var inst = Shrimp.instance()
	inst.global_position = pos
	shrimp.append(inst)
	TopLevel.add_child(inst)
	inst.shrimp_cursor = self
	shrimp_worldTotal+=1
	
	if (!inst.is_connected("ImDead",self,"_shrimpDied")):
		inst.connect("ImDead",self,"_shrimpDied")
	
	if (shrimp.size()>=totalRingCapacity):
		append_ring_capacity()

func add_shrimp_existing(var thisShrimp):
	if (shrimp.size()>=max_shrimp):
		return
	
	if not thisShrimp in shrimp:
		shrimp.append(thisShrimp)
	thisShrimp.shrimp_cursor = self
	
	if (shrimp.size()>=totalRingCapacity):
		append_ring_capacity()
	
	update_ring_positions()
	update_shrimp_targets()
	
	pass

#removes shrimp at index
func remove_shrimp(var index):
	if (shrimp.size()<=0):
		return
	
	#print("Removing shrimp")
	var thisShrimp = shrimp[index]
	shrimp.remove(index)
	
	update_ring_positions()
	update_shrimp_targets()
	
	return thisShrimp

#launches shrimp at index towards cursor
func launch_shrimp(var index):
	#print(index)
	
	if (shrimp.size()<=0):
		return
	
	#print(shrimp.size())
	
	var thisShrimp = remove_shrimp(index)
	thisShrimp.launch(get_global_mouse_position())
	
	update_ring_positions()
	update_shrimp_targets()

#returns index of farthest shrimp from crab position
func get_outer_shrimp():
	var crab = get_parent()
	
	
	var maxCursorDistance = padding_per_ring * ringCapacity.size() + 5
	var bestDistance = 0
	var bestIndex = -1
	
	for i in shrimp.size():
		var thisShrimp = shrimp[i]
		var thisDistance = crab.global_position.distance_to(thisShrimp.global_position)
		var thisCursorDistance = thisShrimp.global_position.distance_to(global_position)
		
		
		if (thisCursorDistance <= maxCursorDistance && thisDistance>bestDistance):
			bestDistance = thisDistance
			bestIndex = i
	
	return bestIndex

#randomizes shrimp indexes for swarming
func randomize_shrimp():
	var doubleShrimp = shrimp.duplicate()
	shrimp.clear()
	
	while !doubleShrimp.empty():
		var randIndex = randi() % doubleShrimp.size()
		var thisShrimp = doubleShrimp[randIndex]
		doubleShrimp.remove(randIndex)
		
		shrimp.push_back(thisShrimp)

#assigns target positions to shrimp based on their indexes
func update_shrimp_targets():
	for i in shrimp.size():
		if (i >= shrimp_ring_positions.size()):
			break
		
		shrimp[i].assign_target(global_position + shrimp_ring_positions[i])
	
	pass

#calculates shrimp positions based on ring capacities
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

#calculates capacity of new outer ring
func append_ring_capacity():
	var newIndex = ringCapacity.size()
	
	ringCapacity.append(floor(calculate_ring_capacity(newIndex)))
	totalRingCapacity += ringCapacity[newIndex]

#calculates number of shrimp that can fit in a given ring
func calculate_ring_capacity(var ringIndex):
	var ringRadius = (ringIndex+1) * padding_per_ring
	var ringCircumference = 2*PI*ringRadius
	
	return (ringCircumference / shrimp_size)

func _shrimpDied(var inst):
	shrimp_worldTotal-=1
	
	if (inst.is_connected("ImDead",self,"_shrimpDied")):
		inst.disconnect("ImDead",self,"_shrimpDied")
