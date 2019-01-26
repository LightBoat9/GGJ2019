extends KinematicBody2D

onready var shrimp_origin = $ShrimpOrigin

func _draw():
	draw_circle(Vector2(), 64, Color(0, 0, 0, 0.3))