extends TileMapLayer

@onready var character_body_2d: CharacterBody2D = $"../CharacterBody2D"
@onready var world: Node2D = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if character_body_2d.global_position.y <= 16:
		character_body_2d.change_sprite("wq")

func get_moves(piece: CharacterBody2D, piece_type: String):
	match piece_type:
		"p":
			var pos = piece.global_position
			print(pos)
