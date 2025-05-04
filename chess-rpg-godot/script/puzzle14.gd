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
const TROU = preload("res://assets/trou.png")
const TROU_CLOSED = preload("res://assets/trou_closed.png")
const max_moves = 8
const INSTRUCTIONS = "Le sol s'écroule derrière toi, capture autant de pions d'or que possibles."

var turn = true
var possible_2_steps_pos: Array[Vector2]
var pause_process = false
var trous: Array
var instructions = true
var pions_or: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_puzzle.play(GameState.music_puzzle_time)
	for i in ["a","b","c","d","e","f","g","h"]:
		for j in ["1","2","3","4","5","6","7"]:
			var t = Sprite2D.new()
			t.texture = TROU_CLOSED
			$".".add_child(t)
			t.z_index = 1
			t.global_position = uci_to_vect(i+j) + Vector2(0, 6)
			trous.append([t, i+j])
	
	#Allies... assemble
	if GameState.island_2_success:
		var al = ALLY.instantiate()
		$".".add_child(al)
		al.change_texture("redp")
		al.global_position = uci_to_vect("a0")
		al = ALLY.instantiate()
		$".".add_child(al)
		al.change_texture("blup")
		al.global_position = uci_to_vect("i6")
		al = ALLY.instantiate()
		$".".add_child(al)
		al.change_texture("brop")
		al.global_position = uci_to_vect("@5")
		al = ALLY.instantiate()
		$".".add_child(al)
		al.change_texture("capb")
		al.global_position = uci_to_vect("k1")
		al = ALLY.instantiate()
		$".".add_child(al)
		al.change_texture("grep")
		al.global_position = uci_to_vect("b9")
		if GameState.puzzle8_success:
			al = ALLY.instantiate()
			$".".add_child(al)
			al.change_texture("hulr")
			al.global_position = uci_to_vect("l5")
		if GameState.puzzle11_success:
			al = ALLY.instantiate()
			$".".add_child(al)
			al.change_texture("widq")
			al.global_position = uci_to_vect(">0")
		if GameState.puzzle13_success:
			al = ALLY.instantiate()
			$".".add_child(al)
			al.change_texture("masterk")
			al.global_position = uci_to_vect("m3")
	
	for p in [[["a7","a4","b2","b6","c8","c6","d7","e5","e3","g8","g4","h6"],"orp",["d1"],"batn"]]:
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
					pions_or += 1
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
		var last_move = vect_to_uci(GameState.last_white_move[1])
		var last_move_from = vect_to_uci(GameState.last_white_move[0])
		
		for i in trous:
			if int(i[1][1]) < int(last_move[1]): i[0].texture = TROU
			if i[1] == last_move and i[0].texture == TROU:
				allies.get_child(0)._move_to(allies.get_child(0).global_position + Vector2.DOWN * GameState.tile_size)
				await get_tree().create_timer(0.05).timeout
				allies.get_child(0).visible = false
				reset_button.visible = false
				var victory_screen = VICTORY.instantiate()
				canvas_layer.add_child(victory_screen)
				victory_screen.set_failure()
				victory_screen.set_details("Tu es tombé dans un trou, fait attention où tu met les pieds")
				return
		var enemies_to_fall = enemies.get_children().filter(func(x):return int(vect_to_uci(x.global_position)[1]) < int(last_move[1]))
		for e in enemies_to_fall:
			e._move_to(e.global_position + Vector2.DOWN * GameState.tile_size)
		await get_tree().create_timer(0.05).timeout
		for e in enemies_to_fall:
			e.visible = false
		enemies_to_fall.map(func(x):x.queue_free())
		GameState.number_of_turn += 1
		
		if vect_to_uci(allies.get_child(0).global_position)[1] == "8":
			if GameState.number_of_turn == 6 and pions_or == 6:
				GameState.puzzle14_success = true
				reset_button.visible = false
				var victory_screen = VICTORY.instantiate()
				canvas_layer.add_child(victory_screen)
				victory_screen.set_rewards(Vector2(1, 0) * GameState.tile_size)
				victory_screen.set_victory()
				return
			else:
				reset_button.visible = false
				var victory_screen = VICTORY.instantiate()
				canvas_layer.add_child(victory_screen)
				victory_screen.set_failure()
				victory_screen.set_details("Tu peux récupérer plus de pions d'or")
				return
		
		turn = true
		pause_process = false

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
