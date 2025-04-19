extends Area2D

@export var target: Ally

func _ready():
	var dir = (target.global_position - global_position).normalized()
	$Anchor.rotation = dir.angle() + PI/2
