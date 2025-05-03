extends TileMapLayer

@onready var allies: Node2D = $"../Allies"
@onready var enemies: Node2D = $"../Enemies"
@onready var area_limit: Area2D = $"../Limits/AreaLimit"
@onready var wall: Area2D = $"../Limits/Wall"
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var player: CharacterBody2D = $"../Allies/player"
@onready var puzzle_1: Area2D = $"../Triggers/Puzzle1"
@onready var puzzle_2: Area2D = $"../Triggers/Puzzle2"
@onready var puzzle_3: Area2D = $"../Triggers/Puzzle3"
@onready var puzzle_4: Area2D = $"../Triggers/Puzzle4"
@onready var puzzle_5: Area2D = $"../Triggers/Puzzle5"
@onready var puzzle_6: Area2D = $"../Triggers/Puzzle6"
@onready var puzzle_7: Area2D = $"../Triggers/Puzzle7"
@onready var puzzle_8: Area2D = $"../Triggers/Puzzle8"
@onready var puzzle_10: Area2D = $"../Triggers/Puzzle10"
@onready var puzzle_11: Area2D = $"../Triggers/Puzzle11"
@onready var puzzle_13: Area2D = $"../Triggers/Puzzle13"
@onready var puzzle_14: Area2D = $"../Triggers/Puzzle14"
@onready var p_1: Ally = $"../Allies/p1"
@onready var p_2: Ally = $"../Allies/p2"
@onready var p_3: Ally = $"../Allies/p3"
@onready var p_4: Ally = $"../Allies/p4"
@onready var p_5: Ally = $"../Allies/p5"
@onready var p_6: Ally = $"../Allies/p6"
@onready var p_7: Ally = $"../Allies/p7"
@onready var p_8: Ally = $"../Allies/p8"
@onready var p_10: Ally = $"../Allies/p10"
@onready var p_11: Ally = $"../Allies/p11"
@onready var p_13: Ally = $"../Allies/p13"
@onready var p_14: Ally = $"../Allies/p14"
@onready var e_1: Enemy = $"../Enemies/e1"
@onready var e_2: Enemy = $"../Enemies/e2"
@onready var e_3: Enemy = $"../Enemies/e3"
@onready var e_4: Enemy = $"../Enemies/e4"
@onready var e_5: Enemy = $"../Enemies/e5"
@onready var e_6: Enemy = $"../Enemies/e6"
@onready var e_7: Enemy = $"../Enemies/e7"
@onready var e_8: Enemy = $"../Enemies/e8"
@onready var e_10: Enemy = $"../Enemies/e10"
@onready var e_11: Enemy = $"../Enemies/e11"
@onready var e_13: Enemy = $"../Enemies/e13"
@onready var e_14: Enemy = $"../Enemies/e14"
@onready var portal: AnimatedSprite2D = $"../Portal"
@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"
@onready var text_box: MarginContainer = $"../CanvasLayerTextBox/TextBox"
@export var cam_target: Node2D

const ENEMY = preload("res://scene/enemy.tscn")
const PLAYER = preload("res://scene/player.tscn")
const ALLY = preload("res://scene/ally.tscn")
const ICE_TRAP = preload("res://scene/iceTrap.tscn")
const PUZZLE_TRIGGER = preload("res://assets/PuzzleTrigger.png")
const PUZZLE_TRIGGER_DEACTIVATE = preload("res://assets/PuzzleTrigger_deactivate.png")
const PUZZLE_TRIGGER_TP = preload("res://assets/PuzzleTrigger_TP.png")
const max_moves = 8

var turn = true
var possible_2_steps_pos: Array[Vector2]
var pause_process = false
var cam_movement = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#debug
	if true:
		GameState.puzzle1_success = true
		GameState.puzzle2_success = true
		GameState.puzzle3_success = true
		GameState.puzzle4_success = true
		GameState.puzzle5_success = true
		GameState.puzzle6_success = true
		GameState.puzzle7_success = true
		GameState.puzzle10_success = true
		GameState.island_2_success = true
	
	player.change_texture("wq")
	canvas_layer.visible = true
	GSload()
	GSsave()
	if cam_target:
		camera_2d.position_smoothing_enabled = false
		camera_2d.global_position = cam_target.global_position
		await get_tree().create_timer(0.1).timeout
		camera_2d.position_smoothing_enabled = true
	
	#Island 2 checks setup
	var coord = [Vector2(112,-144),Vector2(176,-144),Vector2(112,-208),Vector2(176,-208),Vector2(144,-208)]
	var island_2_checks = []
	for i in range(5):
		var s = Sprite2D.new()
		s.texture = PUZZLE_TRIGGER_DEACTIVATE
		$".".add_child(s)
		s.z_index = 1
		s.global_position = coord[i]
		island_2_checks.append(s)
	
	#On map piece texture change
	if true:
		if p_1: p_1.change_texture("wr")
		if e_1: e_1.change_texture("gp")
		if p_2: p_2.change_texture("wb")
		if e_2: e_2.change_texture("gb")
		if p_3: p_3.change_texture("wn")
		if e_3: e_3.change_texture("gp")
		if p_4: p_4.change_texture("blup")
		if e_4: e_4.change_texture("gp")
		if p_5: p_5.change_texture("brop")
		if e_5: e_5.change_texture("gb")
		if p_6: p_6.change_texture("capb")
		if e_6: e_6.change_texture("gq")
		if p_7: p_7.change_texture("grep")
		if e_7: e_7.change_texture("gp")
		if p_8: p_8.change_texture("hulr")
		if e_8: e_8.change_texture("gk")
		if p_10: p_10.change_texture("batn")
		if e_10: e_10.change_texture("gq")
		if p_11: p_11.change_texture("widq")
		if e_11: e_11.change_texture("gb")
		if p_13: p_13.change_texture("masterk")
		if e_13: e_13.change_texture("gk")
		if p_14: p_14.change_texture("jadp")
		if e_14: e_14.change_texture("gp")
	
	#Enemies delete after puzzle completion
	if true:
		if GameState.puzzle1_success:
			p_1.queue_free()
			e_1.queue_free()
			puzzle_1.visible = false
		if GameState.puzzle2_success:
			p_2.queue_free()
			e_2.queue_free()
			puzzle_2.visible = false
		if GameState.puzzle3_success:
			p_3.queue_free()
			e_3.queue_free()
			puzzle_3.visible = false
		if GameState.puzzle4_success:
			island_2_checks[0].texture = PUZZLE_TRIGGER
			p_4.queue_free()
			e_4.queue_free()
			puzzle_4.visible = false
		if GameState.puzzle5_success:
			island_2_checks[1].texture = PUZZLE_TRIGGER
			p_5.queue_free()
			e_5.queue_free()
			puzzle_5.visible = false
		if GameState.puzzle6_success:
			island_2_checks[2].texture = PUZZLE_TRIGGER
			p_6.queue_free()
			e_6.queue_free()
			puzzle_6.visible = false
		if GameState.puzzle7_success:
			island_2_checks[3].texture = PUZZLE_TRIGGER
			p_7.queue_free()
			e_7.queue_free()
			puzzle_7.visible = false
		if GameState.puzzle8_success:
			p_8.queue_free()
			e_8.queue_free()
			puzzle_8.visible = false
		if GameState.puzzle10_success:
			island_2_checks[4].texture = PUZZLE_TRIGGER
			p_10.queue_free()
			e_10.queue_free()
			puzzle_10.visible = false
		if GameState.puzzle11_success:
			p_11.queue_free()
			e_11.queue_free()
			puzzle_11.visible = false
		if GameState.puzzle13_success:
			p_13.queue_free()
			e_13.queue_free()
			puzzle_13.visible = false
		if GameState.puzzle14_success:
			p_14.queue_free()
			e_14.queue_free()
			puzzle_14.visible = false
	
	if GameState.puzzle4_success and GameState.puzzle5_success and GameState.puzzle6_success and GameState.puzzle7_success and GameState.puzzle10_success:
		portal.activate()
		GameState.island_2_success = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if pause_process: return
	if cam_target and !cam_movement:
		camera_2d.global_position = cam_target.global_position
	if GameState.world_instruction:
		GameState.world_instruction = false
		text_box.display_text("Bienvenue, tes amis ont été capturés par les sbires de Black Gammon.\n\nTu peux déplacer ton pion en cliquant dessus, essaye de libérer ton ami la tour de l'emprise de ce pion.")
	
	for a in allies.get_children():
		for e in enemies.get_children():
			if positions_equal(a.global_position, e.global_position):
				if !turn:
					a.capture.play()
					print(e.get_texture(), " captured by ", a.get_texture())
					enemies.remove_child(e)
				else:
					e.capture.play()
					print(a.get_texture(), " captured by ", e.get_texture())
					allies.remove_child(a)
	
	#Puzzle Teleport
	if true:
		if positions_equal(player.global_position, puzzle_1.global_position) and !GameState.puzzle1_success:
			scene_switch("res://scene/puzzle1.tscn")
			return
		if positions_equal(player.global_position, puzzle_2.global_position) and !GameState.puzzle2_success:
			scene_switch("res://scene/puzzle2.tscn")
			return
		if positions_equal(player.global_position, puzzle_3.global_position) and !GameState.puzzle3_success:
			scene_switch("res://scene/puzzle3.tscn")
			return
		if positions_equal(player.global_position, puzzle_4.global_position) and !GameState.puzzle4_success:
			scene_switch("res://scene/puzzle4.tscn")
			return
		if positions_equal(player.global_position, puzzle_5.global_position) and !GameState.puzzle5_success:
			scene_switch("res://scene/puzzle5.tscn")
			return
		if positions_equal(player.global_position, puzzle_6.global_position) and !GameState.puzzle6_success:
			scene_switch("res://scene/puzzle6.tscn")
			return
		if positions_equal(player.global_position, puzzle_7.global_position) and !GameState.puzzle7_success:
			scene_switch("res://scene/puzzle7.tscn")
			return
		if positions_equal(player.global_position, puzzle_8.global_position) and !GameState.puzzle8_success:
			scene_switch("res://scene/puzzle8.tscn")
			return
		if positions_equal(player.global_position, puzzle_10.global_position) and !GameState.puzzle10_success:
			scene_switch("res://scene/puzzle10.tscn")
			return
		if positions_equal(player.global_position, puzzle_11.global_position) and !GameState.puzzle11_success:
			scene_switch("res://scene/puzzle11.tscn")
			return
		if positions_equal(player.global_position, puzzle_13.global_position) and !GameState.puzzle13_success:
			scene_switch("res://scene/puzzle13.tscn")
			return
		if positions_equal(player.global_position, puzzle_14.global_position) and !GameState.puzzle14_success:
			scene_switch("res://scene/puzzle14.tscn")
			return
	
	if positions_equal(player.global_position, Vector2(144,-182)) and GameState.island_2_success:
		pause_process = true
		player.visible = false
		player._move_to(Vector2(1488,-758))
		await get_tree().create_timer(0.5).timeout
		player.visible = true
		pause_process = false
	
	if !turn: turn = true

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
				if is_off_limit(moves[i], area_limit) or is_off_limit(moves[i], wall):
					moves.remove_at(i)
					continue
				for a in allies.get_children():
					if positions_equal(moves[i], a.global_position):
						moves.remove_at(i)
						break
			if !GameState.puzzle1_success: moves = moves.filter(func(x):return !positions_equal(x,Vector2(848,554)))
			return moves
		"r":
			var dirs = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
			var all_pieces = allies.get_children() + enemies.get_children()
			for d in dirs:
				var i = 1
				while i < max_moves:
					var found_piece = false
					var temp = pos + GameState.tile_size * i * d
					if is_off_limit(temp, area_limit) or is_off_limit(temp, wall): break
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
				if !is_off_limit(t1, area_limit) and !is_off_limit(t1, wall):
					var ally_on_target = false
					for a in allies.get_children():
						if positions_equal(a.global_position, t1): ally_on_target = true
					if !ally_on_target: moves.append(t1)
				if !is_off_limit(t2, area_limit) and !is_off_limit(t2, wall):
					var ally_on_target = false
					for a in allies.get_children():
						if positions_equal(a.global_position, t2): ally_on_target = true
					if !ally_on_target: moves.append(t2)
			var i = 0
			while i < moves.size():
				if is_off_limit((moves[i]+pos)/2, wall):
					moves.remove_at(i)
				else:
					i += 1
			return moves
		"b":
			var dirs = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1)]
			var all_pieces = allies.get_children() + enemies.get_children()
			for d in dirs:
				var i = 1
				while i < max_moves:
					var found_piece = false
					var temp = pos + GameState.tile_size * i * d
					if is_off_limit(temp, area_limit) or is_off_limit(temp, wall): break
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
					if is_off_limit(temp, area_limit) or is_off_limit(temp, wall): break
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
				if is_off_limit(temp, area_limit) or is_off_limit(temp, wall): continue
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

func positions_equal(a: Vector2, b: Vector2, epsilon := 0.01) -> bool:
	return a.distance_to(b) < epsilon

func scene_switch(target_scene: String):
	pause_process = true
	GSsave()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(target_scene)
	pause_process = false
	return

func GSsave():
	GameState.player_pos = player.global_position
	GameState.player_texture = player.get_texture()
	GameState.turn = turn
	
func GSload():
	if GameState.player_pos:
		player.global_position = GameState.player_pos
		player.change_texture(GameState.player_texture)
		turn = GameState.turn
