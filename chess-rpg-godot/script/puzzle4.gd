extends TileMapLayer

@onready var allies: Node2D = $"../Allies"
@onready var enemies: Node2D = $"../Enemies"
@onready var area_limit: Area2D = $"../Limits/AreaLimit"
@onready var text_box: MarginContainer = $"../CanvasLayer/TextBox"

const ENEMY = preload("res://scene/enemy.tscn")
const PLAYER = preload("res://scene/player.tscn")
const ALLY = preload("res://scene/ally.tscn")
const TROU = preload("res://assets/trou.png")
const TROU_CLOSED = preload("res://assets/trou_closed.png")
const tile_size = 32
const max_moves = 8
const INSTRUCTIONS = "Les pièces bleues sont tes amis pris au piège. Il ne t'attaqueront pas mais ne peuvent pas t'aider.\n\nFait attention où tu met les pieds et essaye de récupérer les 3 pions d'or."

var turn = true
var possible_2_steps_pos: Array[Vector2]
var pause_process = false
var trous: Array
var instructions = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in ["a1","a2","a3","a4","a5","a6","a7","a8","b1","b2","b3","b4","b6","b8","c1","c2","c4","c6","c7","c8","d1","d2","d3","d4","d5","d7","d8","e1","e2","e3","e6","e7","f3","f5","f7","g1","g2","g3","g4","g5","g6","g8","h1","h3","h5","h7","h8"]:
		var t = Sprite2D.new()
		t.texture = TROU_CLOSED
		$".".add_child(t)
		t.z_index = 1
		t.global_position = uci_to_vect(i) + Vector2(0, 6)
		trous.append([t, i])
	
	if GameState.puzzle1_success:
		var al1 = ALLY.instantiate()
		allies.add_child(al1)
		al1.change_texture("wp")
		al1.global_position = uci_to_vect("a0")
	if GameState.puzzle2_success:
		var al2 = ALLY.instantiate()
		allies.add_child(al2)
		al2.change_texture("wb")
		al2.global_position = uci_to_vect("i6")
	for p in [[["d4","d7","g5"],"orp",["b1"],"wn",["b7","b5","c5","c3","d6","e8","e5","e4","f8","f6","f4","f2","f1","g7","h6","h4","h2"],"blp"]]:
		for i in p[0]:
			var e = ENEMY.instantiate()
			enemies.add_child(e)
			e.change_texture(p[1])
			e.global_position = uci_to_vect(i)
		for i in p[2]:
			var a = PLAYER.instantiate()
			allies.add_child(a)
			a.change_texture(p[3])
			a.global_position = uci_to_vect(i)
		for i in p[4]:
			var a = ALLY.instantiate()
			allies.add_child(a)
			a.change_texture(p[5])
			a.global_position = uci_to_vect(i)
	GameState.number_of_turn = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if instructions:
		instructions = false
		text_box.display_text(INSTRUCTIONS)
	if pause_process: return
	for a in allies.get_children():
		for e in enemies.get_children():
			if positions_equal(a.global_position, e.global_position):
				if !turn:
					print(e.get_texture(), " captured by ", a.get_texture())
					enemies.remove_child(e)
					print(GameState.number_of_turn)
					if GameState.number_of_turn == 2:
						GameState.puzzle4_success = true
						GameState.player_pos += Vector2(1, 0) * tile_size
						GameState.player_texture = "wn"
						scene_switch("res://scene/world.tscn")
						return
				else:
					print(a.get_texture(), " captured by ", e.get_texture())
					allies.remove_child(a)
					scene_switch("res://scene/puzzle4.tscn")
					return

	if !turn:
		pause_process = true
		await get_tree().create_timer(0.2).timeout
		var last_move = vect_to_uci(GameState.last_white_move[1])
		var last_move_from = vect_to_uci(GameState.last_white_move[0])
		for i in trous:
			if i[1] == last_move_from: i[0].texture = TROU
			if i[1] == last_move and i[0].texture == TROU:
				allies.get_child(0)._move_to(allies.get_child(0).global_position + Vector2.DOWN * tile_size)
				await get_tree().create_timer(0.05).timeout
				allies.get_child(0).visible = false
				scene_switch("res://scene/puzzle4.tscn")
				return
		if last_move in ["d4","d7","g5"]:
			GameState.number_of_turn += 1
		turn = true
		pause_process = false

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
				if positions_equal(e.global_position, pos + tile_size * dir):
					is_front_free = false
					continue
				if positions_equal(e.global_position, diag_droite):
					moves.append(diag_droite)
					continue
				if positions_equal(e.global_position, diag_gauche):
					moves.append(diag_gauche)
					continue
			if is_front_free: moves.append(pos + tile_size * dir)
			for i in range(moves.size()):
				if is_off_limit(moves[i], area_limit):
					moves.remove_at(i)
					continue
				for a in allies.get_children():
					if positions_equal(moves[i], a.global_position):
						moves.remove_at(i)
						break
			return moves
		"r":
			var dirs = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
			var all_pieces = allies.get_children() + enemies.get_children()
			for d in dirs:
				var i = 1
				while i < max_moves:
					var found_piece = false
					var temp = pos + tile_size * i * d
					if is_off_limit(temp, area_limit): break
					for p in all_pieces:
						if positions_equal(temp, p.global_position):
							found_piece = true
							if p is Enemy:
								moves.append(temp)
							break
					if found_piece: break
					else: moves.append(temp)
					i += 1
			return moves
		"n":
			var dirs = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
			for d in dirs:
				var t1 = pos + tile_size * 2 * d + tile_size * d.rotated(PI/2)
				var t2 = pos + tile_size * 2 * d + tile_size * d.rotated(-PI/2)
				if !is_off_limit(t1, area_limit):
					var ally_on_target = false
					for a in allies.get_children():
						if positions_equal(a.global_position, t1): ally_on_target = true
					if !ally_on_target: moves.append(t1)
				if !is_off_limit(t2, area_limit):
					var ally_on_target = false
					for a in allies.get_children():
						if positions_equal(a.global_position, t2): ally_on_target = true
					if !ally_on_target: moves.append(t2)
			return moves
		"b":
			var dirs = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1)]
			var all_pieces = allies.get_children() + enemies.get_children()
			for d in dirs:
				var i = 1
				while i < max_moves:
					var found_piece = false
					var temp = pos + tile_size * i * d
					if is_off_limit(temp, area_limit): break
					for p in all_pieces:
						if positions_equal(temp, p.global_position):
							found_piece = true
							if p is Enemy:
								moves.append(temp)
							break
					if found_piece: break
					else: moves.append(temp)
					i += 1
			return moves
		"q":
			var dirs = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1), Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
			var all_pieces = allies.get_children() + enemies.get_children()
			for d in dirs:
				var i = 1
				while i < max_moves:
					var found_piece = false
					var temp = pos + tile_size * i * d
					if is_off_limit(temp, area_limit): break
					for p in all_pieces:
						if positions_equal(temp, p.global_position):
							found_piece = true
							if p is Enemy:
								moves.append(temp)
							break
					if found_piece: break
					else: moves.append(temp)
					i += 1
			return moves
		"k":
			var dirs = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1), Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
			var all_pieces = allies.get_children() + enemies.get_children()
			for d in dirs:
				var found_piece = false
				var temp = pos + tile_size * d
				if is_off_limit(temp, area_limit): continue
				for p in all_pieces:
					if positions_equal(temp, p.global_position):
						found_piece = true
						if p is Enemy:
							moves.append(temp)
						continue
				if found_piece: continue
				else: moves.append(temp)
			return moves
	return []

func uci_to_vect(uci: String):
	var x = uci[0].to_upper().unicode_at(0) - 'A'.unicode_at(0)
	return Vector2(x * tile_size + 16, (8 - int(uci[1])) * tile_size + 10)

func vect_to_uci(vect: Vector2):
	@warning_ignore("narrowing_conversion")
	return char(97 + ((vect[0] - 16) / tile_size)) + str(8 - int((vect[1] - 10) / tile_size))

func is_off_limit(point: Vector2, area: Area2D) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = point
	query.collide_with_areas = true
	var result = space_state.intersect_point(query)
	
	for item in result:
		if item.collider == area:
			return true
	return false

func scene_switch(target_scene: String):
	pause_process = true
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(target_scene)
	pause_process = false
	return

func positions_equal(a: Vector2, b: Vector2, epsilon := 0.01) -> bool:
	return a.distance_to(b) < epsilon
