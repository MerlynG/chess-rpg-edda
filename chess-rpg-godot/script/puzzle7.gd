extends TileMapLayer

@onready var allies: Node2D = $"../Allies"
@onready var enemies: Node2D = $"../Enemies"
@onready var area_limit: Area2D = $"../Limits/AreaLimit"
@onready var text_box: MarginContainer = $"../CanvasLayer/TextBox"
@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"
@onready var reset_button: MarginContainer = $"../CanvasLayer/ResetButton"
@onready var music_puzzle: AudioStreamPlayer = $"../MusicPuzzle"

const VICTORY = preload("res://scene/victory.tscn")
const ENEMY = preload("res://scene/enemy.tscn")
const PLAYER = preload("res://scene/player.tscn")
const ALLY = preload("res://scene/ally.tscn")
const max_moves = 8
const INSTRUCTIONS = "Ton fou s'est perdu ! Il doit vite repartir d'ici.\n\nTu as 6 coups pour récupérer 6 pions d'or."

var turn = true
var possible_2_steps_pos: Array[Vector2]
var pause_process = false
var instructions = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_puzzle.play(GameState.music_puzzle_time)
	randomize()
	var bishop_skin = "capb" if GameState.puzzle6_success else "wb"
	var al1 = ALLY.instantiate()
	$".".add_child(al1)
	al1.change_texture("redp")
	al1.global_position = uci_to_vect("a0")
	if GameState.puzzle4_success:
		var al = ALLY.instantiate()
		$".".add_child(al)
		al.change_texture("blup")
		al.global_position = uci_to_vect("i6")
	if GameState.puzzle5_success:
		var al = ALLY.instantiate()
		$".".add_child(al)
		al.change_texture("brop")
		al.global_position = uci_to_vect("@5")
	if GameState.puzzle6_success and bishop_skin == "wb":
		var al = ALLY.instantiate()
		$".".add_child(al)
		al.change_texture("capb")
		al.global_position = uci_to_vect("k1")
	if GameState.puzzle10_success:
		var al = ALLY.instantiate()
		$".".add_child(al)
		al.change_texture("batn")
		al.global_position = uci_to_vect("=3")
	for p in [[["a4","b1","b7","c4","c8","f1","g6","h1","h3"],"orp",["e4"],bishop_skin]]:
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
					a.capture.play()
					enemies.remove_child(e)
				else:
					print(a.get_texture(), " captured by ", e.get_texture())
					e.capture.play()
					allies.remove_child(a)
	
	if !turn:
		pause_process = true
		await get_tree().create_timer(0.2).timeout
		@warning_ignore("unused_variable")
		var last_move = vect_to_uci(GameState.last_white_move[1])
		@warning_ignore("unused_variable")
		var last_move_from = vect_to_uci(GameState.last_white_move[0])
		
		GameState.number_of_turn += 1
		print(enemies.get_children().size())
		print(GameState.number_of_turn)
		if GameState.number_of_turn == 6:
			reset_button.visible = false
			var victory_screen = VICTORY.instantiate()
			canvas_layer.add_child(victory_screen)
			if enemies.get_children().size() < 4:
				GameState.puzzle7_success = true
				victory_screen.set_victory()
				return
			else:
				victory_screen.set_failure()
				if enemies.get_children().size() == 9:
					victory_screen.set_details("Tu n'as récupéré aucun pions d'or")
				else:
					victory_screen.set_details("Tu n'as récupéré que " + str(9 - enemies.get_children().size()) + " pions d'or")
				return
		
		turn = true
		pause_process = false

func ai_get_moves(piece: CharacterBody2D, piece_type: String, dir: Vector2):
	var moves: Array[Vector2]
	var pos = piece.global_position
	match piece_type:
		"p":
			var diag_gauche = pos + GameState.tile_size * (dir + dir.rotated(-PI/2))
			var diag_droite = pos + GameState.tile_size * (dir + dir.rotated(PI/2))
			var is_front_free = true
			if pos in possible_2_steps_pos: moves.append(pos + GameState.tile_size * dir * 2)
			for e in allies.get_children():
				if positions_equal(e.global_position, pos + GameState.tile_size * dir):
					is_front_free = false
					continue
				if positions_equal(e.global_position, diag_droite):
					moves.append(diag_droite)
					continue
				if positions_equal(e.global_position, diag_gauche):
					moves.append(diag_gauche)
					continue
			if is_front_free: moves.append(pos + GameState.tile_size * dir)
			for i in range(moves.size()):
				if is_off_limit(moves[i], area_limit):
					moves.remove_at(i)
					continue
				for a in enemies.get_children():
					if positions_equal(moves[i], a.global_position):
						moves.remove_at(i)
						break
			return moves
		"r":
			var dirs = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
			var all_pieces = enemies.get_children() + allies.get_children()
			for d in dirs:
				var i = 1
				while i < max_moves:
					var found_piece = false
					var temp = pos + GameState.tile_size * i * d
					if is_off_limit(temp, area_limit): break
					for p in all_pieces:
						if positions_equal(temp, p.global_position):
							found_piece = true
							if p is Player:
								moves.append(temp)
							break
					if found_piece: break
					else: moves.append(temp)
					i += 1
			return moves
		"n":
			var dirs = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
			for d in dirs:
				var t1 = pos + GameState.tile_size * 2 * d + GameState.tile_size * d.rotated(PI/2)
				var t2 = pos + GameState.tile_size * 2 * d + GameState.tile_size * d.rotated(-PI/2)
				if !is_off_limit(t1, area_limit):
					var ally_on_target = false
					for a in enemies.get_children():
						if positions_equal(a.global_position, t1): ally_on_target = true
					if !ally_on_target: moves.append(t1)
				if !is_off_limit(t2, area_limit):
					var ally_on_target = false
					for a in enemies.get_children():
						if positions_equal(a.global_position, t2): ally_on_target = true
					if !ally_on_target: moves.append(t2)
			return moves
		"b":
			var dirs = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1)]
			var all_pieces = enemies.get_children() + allies.get_children()
			for d in dirs:
				var i = 1
				while i < max_moves:
					var found_piece = false
					var temp = pos + GameState.tile_size * i * d
					if is_off_limit(temp, area_limit): break
					for p in all_pieces:
						if positions_equal(temp, p.global_position):
							found_piece = true
							if p is Player:
								moves.append(temp)
							break
					if found_piece: break
					else: moves.append(temp)
					i += 1
			return moves
		"q":
			var dirs = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1), Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
			var all_pieces = enemies.get_children() + allies.get_children()
			for d in dirs:
				var i = 1
				while i < max_moves:
					var found_piece = false
					var temp = pos + GameState.tile_size * i * d
					if is_off_limit(temp, area_limit): break
					for p in all_pieces:
						if positions_equal(temp, p.global_position):
							found_piece = true
							if p is Player:
								moves.append(temp)
							break
					if found_piece: break
					else: moves.append(temp)
					i += 1
			return moves
		"k":
			var dirs = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1), Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
			var all_pieces = enemies.get_children() + allies.get_children()
			for d in dirs:
				var found_piece = false
				var temp = pos + GameState.tile_size * d
				if is_off_limit(temp, area_limit): continue
				for p in all_pieces:
					if positions_equal(temp, p.global_position):
						found_piece = true
						if p is Player:
							moves.append(temp)
						continue
				if found_piece: continue
				else: moves.append(temp)
			return moves
	return []

func get_moves(piece: CharacterBody2D, piece_type: String, dir: Vector2):
	var moves: Array[Vector2]
	var pos = piece.global_position
	match piece_type:
		"p":
			var diag_gauche = pos + GameState.tile_size * (dir + dir.rotated(-PI/2))
			var diag_droite = pos + GameState.tile_size * (dir + dir.rotated(PI/2))
			var is_front_free = true
			if pos in possible_2_steps_pos: moves.append(pos + GameState.tile_size * dir * 2)
			for e in enemies.get_children():
				if positions_equal(e.global_position, pos + GameState.tile_size * dir):
					is_front_free = false
					continue
				if positions_equal(e.global_position, diag_droite):
					moves.append(diag_droite)
					continue
				if positions_equal(e.global_position, diag_gauche):
					moves.append(diag_gauche)
					continue
			if is_front_free: moves.append(pos + GameState.tile_size * dir)
			var x = 0
			while x < moves.size():
				var break_detected = false
				if is_off_limit(moves[x], area_limit):
					moves.remove_at(x)
					continue
				for a in allies.get_children():
					if positions_equal(moves[x], a.global_position):
						moves.remove_at(x)
						break_detected = true
						break
				if !break_detected: x += 1
			return moves
		"r":
			var dirs = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
			var all_pieces = allies.get_children() + enemies.get_children()
			for d in dirs:
				var i = 1
				while i < max_moves:
					var found_piece = false
					var temp = pos + GameState.tile_size * i * d
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
				var t1 = pos + GameState.tile_size * 2 * d + GameState.tile_size * d.rotated(PI/2)
				var t2 = pos + GameState.tile_size * 2 * d + GameState.tile_size * d.rotated(-PI/2)
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
					var temp = pos + GameState.tile_size * i * d
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
					var temp = pos + GameState.tile_size * i * d
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
				var temp = pos + GameState.tile_size * d
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
	return Vector2(x * GameState.tile_size + 16, (8 - int(uci[1])) * GameState.tile_size + 10)

func vect_to_uci(vect: Vector2):
	@warning_ignore("narrowing_conversion")
	return char(97 + ((vect[0] - 16) / GameState.tile_size)) + str(8 - int((vect[1] - 10) / GameState.tile_size))

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

func _exit_tree() -> void:
	GameState.music_puzzle_time = music_puzzle.get_playback_position()
