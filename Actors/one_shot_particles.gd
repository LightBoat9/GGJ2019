extends Particles2D

var finished = false

var timer = Timer.new()

func _ready():
	add_child(timer)
	timer.wait_time = lifetime
	one_shot = true
	emitting = true

func _process(delta):
	if not emitting and not finished:
		finished = true
		timer.start()

func delete():
	queue_free()