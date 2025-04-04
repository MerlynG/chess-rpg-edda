extends TileMapLayer

@onready var character_body_2d: CharacterBody2D = $"../Allies/CharacterBody2D"
@onready var allies: Node2D = $"../Allies"
@onready var enemies: Node2D = $"../Enemies"

const ENEMY = preload("res://scene/enemy.tscn")
const PLAYER = preload("res://scene/player.tscn")
const tile_size: Vector2 = Vector2(32, 32)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(8):
		var bp = ENEMY.instantiate()
		enemies.add_child(bp)
		bp.change_sprite("bp")
		bp.global_position = Vector2(i * 32 + 16, 32 + 10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func get_moves(piece: CharacterBody2D, piece_type: String, dir: Vector2):
	var moves: Array[Vector2]
	var imoves: Array[Vector2]
	match piece_type:
		"p":
			var pos = piece.global_position
			var diag_gauche = pos + tile_size * (dir + dir.rotated(-PI/2))
			var diag_droite = pos + tile_size * (dir + dir.rotated(PI/2))
			var is_front_free = true
			for e in enemies.get_children():
				if e.global_position == pos + tile_size * dir:
					is_front_free = false
					continue
				if e.global_position == diag_droite:
					moves.append(diag_droite)
					continue
				if e.global_position == diag_gauche:
					moves.append(diag_gauche)
					continue
			if is_front_free: moves.append(pos + tile_size * dir)
			else: imoves.append(pos + tile_size * dir)
			
			for i in range(moves.size()):
				for a in allies.get_children():
					if moves[i] == a.global_position:
						imoves.append(moves[i])
						moves.remove_at(i)
			
			return [moves, imoves]
	return [[],[]]
