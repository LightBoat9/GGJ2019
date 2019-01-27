extends Node

enum States { FLOAT, SPIN }
var state = States.FLOAT setget set_state

onready var state_nodes = [
	$Float,
	$Spin
	]
	
func _ready():
	set_state(States.SPIN)
	
func set_state(value):
	if state_nodes[state].has_method('state_exited'):
		state_nodes[state].state_exited()
	state = value
	if state_nodes[state].has_method('state_entered'):
		state_nodes[state].state_entered()
		
func _process(delta):
	if state_nodes[state].has_method('state_process'):
		state_nodes[state].state_process(delta)
		
func _physics_process(delta):
	if state_nodes[state].has_method('state_physics_process'):
		state_nodes[state].state_physics_process(delta)