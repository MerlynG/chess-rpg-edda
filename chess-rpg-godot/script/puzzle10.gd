extends TileMapLayer

@onready var allies: Node2D = $"../Allies"
@onready var enemies: Node2D = $"../Enemies"
@onready var area_limit: Area2D = $"../Limits/AreaLimit"
@onready var text_box: MarginContainer = $"../CanvasLayer/TextBox"
@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"
@onready var reset_button: MarginContainer = $"../CanvasLayer/ResetButton"

const VICTORY = preload("res://scene/victory.tscn")
const ENEMY = preload("res://scene/enemy.tscn")
const PLAYER = preload("res://scene/player.tscn")
const ALLY = preload("res://scene/ally.tscn")
const BOMB = preload("res://scene/bomb.tscn")
const BOMB_BUTTON_PRESSED = preload("res://assets/bomb_button_pressed.png")
const BOMB_BUTTON = preload("res://assets/bomb_button.png")
const max_moves = 8
const INSTRUCTIONS = "Tu as trouvé un totem de Black Gammon. Mais attention ! Il est bien protégé.\n\nTrouve un moyen d'actionner ce bouton, je lui ai préparé une surprise"

var turn = true
var possible_2_steps_pos: Array[Vector2]
var pause_process = false
var instructions = true
var button = Sprite2D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	$".".add_child(button)
	button.texture = BOMB_BUTTON
	button.z_index = 1
	button.global_position = uci_to_vect("g8") + Vector2.DOWN * 6
	
	var bishop_skin = "capb" if GameState.puzzle6_success else "wb"
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
	if GameState.puzzle7_success:
		var al = ALLY.instantiate()
		$".".add_child(al)
		al.change_texture("grep")
		al.global_position = uci_to_vect("b9")
	for p in [[["c8","f7","g6","a4"],"gsp",["f3"],"redp"],[["a5"],"gsq",["c1"],"wr"],[[],"",["h1"],bishop_skin]]:
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
	var a = ALLY.instantiate()
	enemies.add_child(a)
	a.change_texture("rr")
	a.global_position = uci_to_vect("h8")
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

				else:
					print(a.get_texture(), " captured by ", e.get_texture())
					allies.remove_child(a)
					reset_button.visible = false
					var victory_screen = VICTORY.instantiate()
					canvas_layer.add_child(victory_screen)
					victory_screen.set_failure()
					victory_screen.set_details("Tu as perdu une pièce")
					pause_process = true
					return

	if !turn:
		pause_process = true
		await get_tree().create_timer(0.2).timeout
		@warning_ignore("unused_variable")
		var last_move = vect_to_uci(GameState.last_white_move[1])
		@warning_ignore("unused_variable")
		var last_move_from = vect_to_uci(GameState.last_white_move[0])

		if vect_to_uci(allies.get_child(1).global_position) == "g8":
			button.texture = BOMB_BUTTON_PRESSED
			var b = BOMB.instantiate()
			$".".add_child(b)
			b.z_index = 3
			b.global_position = uci_to_vect("h8") + Vector2.DOWN * 6
			await get_tree().create_timer(1).timeout
			enemies.get_child(-1)._move_to(uci_to_vect("h8") + Vector2.UP * 100)
			GameState.puzzle10_success = true
			reset_button.visible = false
			var victory_screen = VICTORY.instantiate()
			canvas_layer.add_child(victory_screen)
			victory_screen.set_rewards(Vector2(1, 0) * GameState.tile_size)
			victory_screen.set_victory()
			victory_screen.set_details("Tu as débloqué Bat Knight, tu peux maintenant l'incarner à la place du cavalier blanc")
			if GameState.player_texture == "wn": GameState.player_texture = "batn"
			return
		
		var a_moves = allies.get_children().map(func(x:Player):return temp_get_moves(x, x.get_texture()[-1],Vector2.UP,x.get_texture())).reduce(func(x,y):return x + y) as Array[Vector2]
		a_moves = a_moves.map(func(x):return vect_to_uci(x))
		print(a_moves)
		for e in enemies.get_children():
			for a in allies.get_children():
				var e_moves = ai_get_moves(e, e.get_texture()[-1], Vector2(0, 1))
				e_moves = e_moves.map(func(x):return vect_to_uci(x)).filter(func(x):return x not in a_moves)
				for em in e_moves:
					if vect_to_uci(a.global_position) == em:
						e._move_to(uci_to_vect(em))
						turn = true
						pause_process = false
						return
		
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

#MODIFIÉ POUR LE PUZZLE
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
			#MODIF
			moves = moves.filter(func(x):return vect_to_uci(x) != "g8")
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
			#MODIF
			moves = moves.filter(func(x):return vect_to_uci(x) != "g8")
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
