extends TileMapLayer

@onready var character_body_2d: CharacterBody2D = $"../Allies/CharacterBody2D"
@onready var allies: Node2D = $"../Allies"
@onready var enemies: Node2D = $"../Enemies"

const ENEMY = preload("res://scene/enemy.tscn")
const PLAYER = preload("res://scene/player.tscn")
const tile_size = Vector2(32, 32)
const max_moves = 8

var turn = true
var possible_2_steps_pos: Array[Vector2]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(8):
		possible_2_steps_pos.append(Vector2(i * 32 + 16, 6 * 32 + 10))
	for i in range(8):
		var bp = ENEMY.instantiate()
		enemies.add_child(bp)
		bp.change_sprite("bp")
		bp.global_position = Vector2(i * 32 + 16, 32 + 10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for a in allies.get_children():
		for e in enemies.get_children():
			if a.global_position == e.global_position:
				if !turn:
					print(e.get_texture(), " captured by ", a.get_texture())
					enemies.remove_child(e)
				else:
					print(a.get_texture(), " captured by ", e.get_texture())
					allies.remove_child(a)
	if !turn:
		#For now it works like this but that shit need a fix because wtf
		turn = true
		await get_tree().create_timer(0.5).timeout
		var e = enemies.get_child(-1)
		e._move_to(Vector2(e.global_position.x, e.global_position.y+32))

func is_allie(piece: CharacterBody2D):
	var texture = piece.get_texture()
	return texture.begins_with("w")

func get_moves(piece: CharacterBody2D, piece_type: String, dir: Vector2):
	var moves: Array[Vector2]
	var pos = piece.global_position
	match piece_type:
		"p":
			var diag_gauche = pos + tile_size * (dir + dir.rotated(-PI/2))
			var diag_droite = pos + tile_size * (dir + dir.rotated(PI/2))
			var is_front_free = true
			if pos in possible_2_steps_pos: moves.append(pos + tile_size * dir * 2)
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
			for i in range(moves.size()):
				for a in allies.get_children():
					if moves[i] == a.global_position:
						moves.remove_at(i)
						break
			return moves
		"r":
			var i = 1
			var next_pos: Vector2
			var all_pieces = allies.get_children() + enemies.get_children()
			#while i < max_moves:
				
			
	return []
