extends AnimatedSprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $"."

func _ready():
	randomize()
	var frame_count = animated_sprite_2d.sprite_frames.get_frame_count(animated_sprite_2d.animation)
	animated_sprite_2d.frame = randi() % frame_count
