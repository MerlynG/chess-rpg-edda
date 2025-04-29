extends TileMapLayer

@onready var allies: Node2D = $"../Allies"
@onready var enemies: Node2D = $"../Enemies"
@onready var area_limit: Area2D = $"../Limits/AreaLimit"
@onready var external_process_node: Node = $"../ExternalProcessNode"
@onready var text_box: MarginContainer = $"../CanvasLayer/TextBox"

const ENEMY = preload("res://scene/enemy.tscn")
const PLAYER = preload("res://scene/player.tscn")
const ALLY = preload("res://scene/ally.tscn")
const max_moves = 8

var moves = " moves "
var turn = true
var trous: Array
var pause_process = false
var possible_2_steps_pos: Array[Vector2]

var debug = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	for i in range(8):
		possible_2_steps_pos.append(Vector2(i * GameState.tile_size + 16, 6 * GameState.tile_size + 10))
	for p in [[["e8"],"bk",["e1"],"wk"],[["a8","h8"],"br",["a1","h1"],"wr"],[["b8","g8"],"bn",["b1","g1"],"wn"],[["c8","f8"],"bb",["c1","f1"],"wb"],[["d8"],"bq",["d1"],"wq"],[["a7","b7","c7","d7","e7","f7","g7","h7"],"bp",["a2","b2","c2","d2","e2","f2","g2","h2"],"wp"]]:
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
	
	external_process_node.Init()
	external_process_node.SendInput("uci")
	external_process_node.ReadAllAvailableOutput("uciok")
	external_process_node.SendInput("position startpos")
	GameState.roque_left_moved = false
	GameState.roque_right_moved = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if pause_process: return
	for a in allies.get_children():
		for e in enemies.get_children():
			if positions_equal(a.global_position, e.global_position):
				if !turn:
					print(e.get_texture(), " captured by ", a.get_texture())
					enemies.remove_child(e)
				else:
					print(a.get_texture(), " captured by ", e.get_texture())
					allies.remove_child(a)
	if !turn:
		pause_process = true
		
		#ROQUES BLANCS
		if vect_to_uci(GameState.last_white_move[0]) + vect_to_uci(GameState.last_white_move[1]) == "e1g1":
			for a in allies.get_children():
				if positions_equal(a.global_position, uci_to_vect("h1")):
					a._move_to(uci_to_vect("f1"))
		if vect_to_uci(GameState.last_white_move[0]) + vect_to_uci(GameState.last_white_move[1]) == "e1c1":
			for a in allies.get_children():
				if positions_equal(a.global_position, uci_to_vect("a1")):
					a._move_to(uci_to_vect("d1"))
		var promotion = false
		for a in allies.get_children():
			if vect_to_uci(a.global_position) in ["a8","b8","c8","d8","e8","f8","g8","h8"] and a.get_texture()[-1] == "p":
				a.change_texture("wq")
				promotion = true
		
		await get_tree().create_timer(0.2).timeout
		if vect_to_uci(GameState.last_white_move[0]) in ["e1", "a1"]: GameState.roque_left_moved = true
		if vect_to_uci(GameState.last_white_move[0]) in ["e1", "h1"]: GameState.roque_right_moved = true
		
		if promotion: moves += vect_to_uci(GameState.last_white_move[0]) + vect_to_uci(GameState.last_white_move[1]) + "q "
		else: moves += vect_to_uci(GameState.last_white_move[0]) + vect_to_uci(GameState.last_white_move[1]) + " "
		external_process_node.SendInput("position startpos" + moves)
		external_process_node.SendInput("go depth 1")
		var res = external_process_node.ReadAllAvailableOutput("bestmove")
		print(res)
		var e_move = res.split("\n")[-2].split(" ")[1]
		var enemy_to_move_found = false
		print(moves)
		for e in enemies.get_children():
			if positions_equal(e.global_position, uci_to_vect(e_move.left(2))):
				e._move_to(uci_to_vect(e_move.substr(2,2)))
				moves += e_move + " "
				enemy_to_move_found = true
				if e_move.length() == 5:
					e.change_texture("b" + e_move[-1])
		
		#ROQUES NOIRS
		if e_move == "e8g8":
			for e in enemies.get_children():
				if positions_equal(e.global_position, uci_to_vect("h8")):
					e._move_to(uci_to_vect("f8"))
		if e_move == "e8c8":
			for e in enemies.get_children():
				if positions_equal(e.global_position, uci_to_vect("a8")):
					e._move_to(uci_to_vect("d8"))
		
		if !enemy_to_move_found:
			print("No enemy to move found\nMove : " + e_move)
		
		#DETECT CHECKS + MENACE ON ROQUES
		var wking: Player = allies.get_child(0)
		GameState.check = false
		var roque_left_safe = true
		var roque_right_safe = true
		for e in enemies.get_children():
			var e_moves = ai_get_moves(e, e.get_texture()[-1], Vector2.DOWN)
			for em in e_moves:
				if positions_equal(em, wking.global_position):
					wking.change_texture("wck")
					GameState.check = true
					break
				if !GameState.roque_left_moved:
					for i in ["c1", "d1"]:
						if positions_equal(em, uci_to_vect(i)):
							roque_left_safe = false
				if !GameState.roque_right_moved:
					for i in ["f1", "g1"]:
						if positions_equal(em, uci_to_vect(i)):
							roque_right_safe = false
		if !GameState.check: wking.change_texture("wk")
		
		#CHECK IF ROQUES POSSIBLES
		var no_one_on_roque_left = true
		var no_one_on_roque_right = true
		for p in enemies.get_children() + allies.get_children():
			if !GameState.roque_left_moved:
				for i in ["b1","c1","d1"]:
					if positions_equal(p.global_position, uci_to_vect(i)):
						no_one_on_roque_left = false
			if !GameState.roque_right_moved:
				for i in ["f1","g1"]:
					if positions_equal(p.global_position, uci_to_vect(i)):
						no_one_on_roque_right = false
		
		if !GameState.roque_left_moved and no_one_on_roque_left and !GameState.check and roque_left_safe: GameState.roque_left = true
		else: GameState.roque_left = false
		if !GameState.roque_right_moved and no_one_on_roque_right and !GameState.check and roque_right_safe: GameState.roque_right = true
		else: GameState.roque_right = false
		
		external_process_node.SendInput("position startpos" + moves)
		external_process_node.SendInput("go perft 1")
		var legal_moves: Array = external_process_node.ReadAllAvailableOutput("searched").split("\n")
		legal_moves = legal_moves.filter(func(x):return x.length()>0 and x[0] in ["a","b","c","d","e","f","g","h"] and x[1] in ["1","2","3","4","5","6","7","8"]).map(func(x:String):return x.substr(0, 4))
		GameState.legal_piece = legal_moves.map(func(x:String):return x.substr(0, 2))
		GameState.legal_target = legal_moves.map(func(x:String):return x.substr(2, 2))
		
		if GameState.legal_piece == []:
			text_box.visible = true
			if GameState.check: text_box.display_text("Échec et mat")
			else: text_box.display_text("Égalité")
		
		turn = true
		pause_process = false
		
func temp_get_moves(piece: CharacterBody2D, piece_type: String, dir: Vector2, self_str: String):
	var moves: Array[Vector2]
	var pos = piece.global_position
	match piece_type:
		"p":
			var diag_gauche = pos + GameState.tile_size * (dir + dir.rotated(-PI/2))
			var diag_droite = pos + GameState.tile_size * (dir + dir.rotated(PI/2))
			var is_front_free = true
			if pos in possible_2_steps_pos: moves.append(pos + GameState.tile_size * dir * 2)
			for e in enemies.get_children() + allies.get_children():
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
						if positions_equal(temp, p.global_position) and p.get_texture() != self_str:
							found_piece = true
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
					moves.append(t1)
				if !is_off_limit(t2, area_limit):
					moves.append(t2)
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
						if positions_equal(temp, p.global_position) and p.get_texture() != self_str:
							found_piece = true
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
						if positions_equal(temp, p.global_position) and p.get_texture() != self_str:
							found_piece = true
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
					if positions_equal(temp, p.global_position) and p.get_texture() != self_str:
						found_piece = true
						moves.append(temp)
						continue
				if found_piece: continue
				else: moves.append(temp)
			return moves
	return []

func ai_get_moves(piece: CharacterBody2D, piece_type: String, dir: Vector2):
	var moves: Array[Vector2]
	var pos = piece.global_position
	match piece_type:
		"p":
			var diag_gauche = pos + GameState.tile_size * (dir + dir.rotated(-PI/2))
			var diag_droite = pos + GameState.tile_size * (dir + dir.rotated(PI/2))
			moves.append(diag_droite)
			moves.append(diag_gauche)
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
					moves.append(t1)
				if !is_off_limit(t2, area_limit):
					moves.append(t2)
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
			for i in range(moves.size()):
				if is_off_limit(moves[i], area_limit):
					moves.remove_at(i)
					continue
				for a in allies.get_children():
					if positions_equal(moves[i], a.global_position):
						moves.remove_at(i)
						break
			if GameState.check: moves = moves.filter(func(x):return vect_to_uci(x) in GameState.legal_target)
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
			if GameState.check: moves = moves.filter(func(x):return vect_to_uci(x) in GameState.legal_target)
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
			if GameState.check: moves = moves.filter(func(x):return vect_to_uci(x) in GameState.legal_target)
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
			if GameState.check: moves = moves.filter(func(x):return vect_to_uci(x) in GameState.legal_target)
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
			if GameState.check: moves = moves.filter(func(x):return vect_to_uci(x) in GameState.legal_target)
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
			if GameState.roque_left: moves.append(pos + GameState.tile_size * 2 * Vector2.LEFT)
			if GameState.roque_right: moves.append(pos + GameState.tile_size * 2 * Vector2.RIGHT)
			for p in enemies.get_children():
				var e_moves = ai_get_moves(p, p.get_texture()[-1], Vector2.DOWN)
				var i = 0
				while i < moves.size():
					var no_danger = true
					for em in e_moves:
						if positions_equal(em, moves[i]):
							moves.remove_at(i)
							no_danger = false
							break
					if no_danger: i += 1
			if GameState.check: moves = moves.filter(func(x):return vect_to_uci(x) in GameState.legal_target)
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
