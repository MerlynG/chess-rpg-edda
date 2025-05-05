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
@onready var puzzle_9: Area2D = $"../Triggers/Puzzle9"
@onready var puzzle_10: Area2D = $"../Triggers/Puzzle10"
@onready var puzzle_11: Area2D = $"../Triggers/Puzzle11"
@onready var puzzle_12: Area2D = $"../Triggers/Puzzle12"
@onready var puzzle_13: Area2D = $"../Triggers/Puzzle13"
@onready var puzzle_14: Area2D = $"../Triggers/Puzzle14"
@onready var puzzle_15: Area2D = $"../Triggers/Puzzle15"
@onready var puzzle_17: Area2D = $"../Triggers/Puzzle17"
@onready var p_1: Ally = $"../Allies/p1"
@onready var p_2: Ally = $"../Allies/p2"
@onready var p_3: Ally = $"../Allies/p3"
@onready var p_4: Ally = $"../Allies/p4"
@onready var p_5: Ally = $"../Allies/p5"
@onready var p_6: Ally = $"../Allies/p6"
@onready var p_7: Ally = $"../Allies/p7"
@onready var p_8: Ally = $"../Allies/p8"
@onready var p_9: Ally = $"../Allies/p9"
@onready var p_10: Ally = $"../Allies/p10"
@onready var p_11: Ally = $"../Allies/p11"
@onready var p_12: Ally = $"../Allies/p12"
@onready var p_13: Ally = $"../Allies/p13"
@onready var p_14: Ally = $"../Allies/p14"
@onready var p_15: Ally = $"../Allies/p15"
@onready var p_17: Ally = $"../Allies/p17"
@onready var e_1: Enemy = $"../Enemies/e1"
@onready var e_2: Enemy = $"../Enemies/e2"
@onready var e_3: Enemy = $"../Enemies/e3"
@onready var e_4: Enemy = $"../Enemies/e4"
@onready var e_5: Enemy = $"../Enemies/e5"
@onready var e_6: Enemy = $"../Enemies/e6"
@onready var e_7: Enemy = $"../Enemies/e7"
@onready var e_8: Enemy = $"../Enemies/e8"
@onready var e_9: Enemy = $"../Enemies/e9"
@onready var e_10: Enemy = $"../Enemies/e10"
@onready var e_11: Enemy = $"../Enemies/e11"
@onready var e_12: Enemy = $"../Enemies/e12"
@onready var e_13: Enemy = $"../Enemies/e13"
@onready var e_14: Enemy = $"../Enemies/e14"
@onready var e_15: Enemy = $"../Enemies/e15"
@onready var e_17: Enemy = $"../Enemies/e17"
@onready var calice_22: AnimatedSprite2D = $"../Items/Calice22"
@onready var calice_23: AnimatedSprite2D = $"../Items/Calice23"
@onready var calice_24: AnimatedSprite2D = $"../Items/Calice24"
@onready var calice_25: AnimatedSprite2D = $"../Items/Calice25"
@onready var calice_26: AnimatedSprite2D = $"../Items/Calice26"
@onready var calice_27: AnimatedSprite2D = $"../Items/Calice27"
@onready var calice_28: AnimatedSprite2D = $"../Items/Calice28"
@onready var calice_29: AnimatedSprite2D = $"../Items/Calice29"
@onready var calice_30: AnimatedSprite2D = $"../Items/Calice30"
@onready var calice_31: AnimatedSprite2D = $"../Items/Calice31"
@onready var calice_32: AnimatedSprite2D = $"../Items/Calice32"
@onready var calice_33: AnimatedSprite2D = $"../Items/Calice33"
@onready var calice_34: AnimatedSprite2D = $"../Items/Calice34"
@onready var calice_35: AnimatedSprite2D = $"../Items/Calice35"
@onready var portal: Node2D = $"../Portal"
@onready var portal_2: Node2D = $"../Portal2"
@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"
@onready var text_box: MarginContainer = $"../CanvasLayerTextBox/TextBox"
@onready var beach: AudioStreamPlayer = $"../Beach"
@onready var background_music: AudioStreamPlayer = $"../BackgroundMusic"
@onready var explosion: AudioStreamPlayer = $"../Explosion"
@export var cam_target: Node2D

const ENEMY = preload("res://scene/enemy.tscn")
const PLAYER = preload("res://scene/player.tscn")
const ALLY = preload("res://scene/ally.tscn")
const ICE_TRAP = preload("res://scene/iceTrap.tscn")
const PUZZLE_TRIGGER = preload("res://assets/PuzzleTrigger.png")
const PUZZLE_TRIGGER_DEACTIVATE = preload("res://assets/PuzzleTrigger_deactivate.png")
const max_moves = 8

var turn = true
var possible_2_steps_pos: Array[Vector2]
var pause_process = false
var cam_movement = false
var debug = false
var portal_1_activation_check = false
var portal_2_activation_check = false
var portal_3_activation_check = false
var portal_3 = ALLY.instantiate()
var save_data = {}
var save_path = "./sauvegarde.save"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#debug
	if debug:
		GameState.puzzle1_success = true
		GameState.puzzle2_success = true
		GameState.puzzle3_success = true
		GameState.puzzle4_success = true
		GameState.puzzle5_success = true
		GameState.puzzle6_success = true
		GameState.puzzle7_success = true
		GameState.puzzle8_success = true
		GameState.puzzle9_success = true
		GameState.puzzle10_success = true
		GameState.puzzle11_success = true
		GameState.puzzle12_success = true
		GameState.puzzle13_success = true
		GameState.puzzle14_success = true
		GameState.puzzle15_success = true
		GameState.puzzle17_success = true
		GameState.island_2_success = true
		GameState.island_3_success = true
		GameState.on_island_4 = true
		GameState.world_instruction = false
		player.global_position = Vector2(3952,-566)
		player.change_texture("wq")
	else:
		player.global_position = Vector2(848,618)
		player.change_texture("redp")
	
	canvas_layer.visible = true
	GSload()
	GSsave()
	
	#Island 2 checks setup
	var coord_2 = [Vector2(112,-144),Vector2(176,-144),Vector2(112,-208),Vector2(176,-208),Vector2(144,-208)]
	var island_2_checks = []
	for i in range(coord_2.size()):
		var s = Sprite2D.new()
		s.texture = PUZZLE_TRIGGER_DEACTIVATE
		$".".add_child(s)
		s.z_index = 1
		s.global_position = coord_2[i]
		island_2_checks.append(s)
	
	#Island 3 checks setup
	var coord_3 = [Vector2(2224,-208),Vector2(2288,-208),Vector2(2224,-272),Vector2(2288,-272)]
	var island_3_checks = []
	for i in range(coord_3.size()):
		var s = Sprite2D.new()
		s.texture = PUZZLE_TRIGGER_DEACTIVATE
		$".".add_child(s)
		s.z_index = 1
		s.global_position = coord_3[i]
		island_3_checks.append(s)
	
	#Island 4 checks setup
	var coord_4 = [Vector2(3856,-784),Vector2(3888,-784),Vector2(4016,-784),Vector2(4048,-784)]
	var island_4_checks = []
	for i in range(coord_4.size()):
		var s = Sprite2D.new()
		s.texture = PUZZLE_TRIGGER_DEACTIVATE
		$".".add_child(s)
		s.z_index = 1
		s.global_position = coord_4[i]
		island_4_checks.append(s)
	
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
		if p_9: p_9.change_texture("purp")
		if e_9: e_9.change_texture("gk")
		if p_10: p_10.change_texture("batn")
		if e_10: e_10.change_texture("gq")
		if p_11: p_11.change_texture("widq")
		if e_11: e_11.change_texture("gb")
		if p_12: p_12.change_texture("whip")
		if e_12: e_12.change_texture("gr")
		if p_13: p_13.change_texture("masterk")
		if e_13: e_13.change_texture("gk")
		if p_14: p_14.change_texture("jadp")
		if e_14: e_14.change_texture("gp")
		if p_15: p_15.change_texture("yelp")
		if e_15: e_15.change_texture("gq")
		if p_17: p_17.change_texture("spik")
		if e_17: e_17.change_texture("gk")
	
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
			island_3_checks[0].texture = PUZZLE_TRIGGER
			p_8.queue_free()
			e_8.queue_free()
			puzzle_8.visible = false
		if GameState.puzzle9_success:
			island_4_checks[0].texture = PUZZLE_TRIGGER
			p_9.queue_free()
			e_9.queue_free()
			puzzle_9.visible = false
		if GameState.puzzle10_success:
			island_2_checks[4].texture = PUZZLE_TRIGGER
			p_10.queue_free()
			e_10.queue_free()
			puzzle_10.visible = false
		if GameState.puzzle11_success:
			island_3_checks[1].texture = PUZZLE_TRIGGER
			p_11.queue_free()
			e_11.queue_free()
			puzzle_11.visible = false
		if GameState.puzzle12_success:
			island_4_checks[1].texture = PUZZLE_TRIGGER
			p_12.queue_free()
			e_12.queue_free()
			puzzle_12.visible = false
		if GameState.puzzle13_success:
			island_3_checks[2].texture = PUZZLE_TRIGGER
			p_13.queue_free()
			e_13.queue_free()
			puzzle_13.visible = false
		if GameState.puzzle14_success:
			island_3_checks[3].texture = PUZZLE_TRIGGER
			p_14.queue_free()
			e_14.queue_free()
			puzzle_14.visible = false
		if GameState.puzzle15_success:
			island_4_checks[2].texture = PUZZLE_TRIGGER
			p_15.queue_free()
			e_15.queue_free()
			puzzle_15.visible = false
		if GameState.puzzle17_success:
			island_4_checks[3].texture = PUZZLE_TRIGGER
			p_17.queue_free()
			e_17.queue_free()
			puzzle_17.visible = false
	
	#Final enemies in hall setup
	if true:
		var t = ["gk","gq","gb","gn","gr","gp"]
		for i in range(6):
			for j in range(2):
				var al = ALLY.instantiate()
				allies.add_child(al)
				al.change_texture(t[i])
				al.global_position = Vector2(3856 + GameState.tile_size * 6 * j, -1270 + GameState.tile_size * 2 * i)
		allies.add_child(portal_3)
		portal_3.change_texture("rb")
		portal_3.global_position = Vector2(3952, -822)
	
	if cam_target:
		camera_2d.position_smoothing_enabled = false
		camera_2d.global_position = cam_target.global_position
		await get_tree().create_timer(0.5).timeout
		camera_2d.position_smoothing_enabled = true
	
	beach.play()
	background_music.play()
	GameState.music_puzzle_time = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if pause_process: return
	if cam_target and !cam_movement:
		camera_2d.global_position = cam_target.global_position

	if GameState.world_instruction:
		GameState.world_instruction = false
		text_box.display_text("Oh non ! Tes amis ont été capturés par les sbires de Black Gammon.\n\nTu peux déplacer ton pion en cliquant dessus, essaye de libérer ton ami la tour de l'emprise de ce pion.")
	
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
	
	#Final Camera setup
	if GameState.on_island_4:
		if player.global_position.y > -848:
			camera_2d.zoom = Vector2(2.3,2.3)
			camera_2d.limit_top = -864
			camera_2d.limit_bottom = 10000000
			camera_2d.limit_right = 10000000
			camera_2d.limit_left = -10000000
		else:
			camera_2d.zoom = Vector2(3,3)
			camera_2d.limit_top = -1425
			camera_2d.limit_bottom = -816
			camera_2d.limit_right = 4272
			camera_2d.limit_left = 3632
			for i in [calice_22,calice_23,calice_24,calice_25,calice_26,calice_27,calice_28,calice_29,calice_30,calice_31,calice_32,calice_33,calice_34,calice_35]:
				i.adjust_volume(-40)
	
	if GameState.puzzle4_success and GameState.puzzle5_success and GameState.puzzle6_success and GameState.puzzle7_success and GameState.puzzle10_success and !portal_1_activation_check:
		portal_1_activation_check = true
		portal.activate()
		GameState.island_2_success = true
	
	if GameState.island_2_success and GameState.puzzle8_success and GameState.puzzle11_success and GameState.puzzle13_success and GameState.puzzle14_success and !portal_2_activation_check:
		portal_2_activation_check = true
		portal_2.activate()
		GameState.island_3_success = true
	
	if GameState.island_2_success and GameState.island_3_success and GameState.puzzle9_success and GameState.puzzle12_success and GameState.puzzle15_success and GameState.puzzle17_success and !portal_3_activation_check:
		portal_3_activation_check = true
		explosion.play()
		portal_3.queue_free()
		GameState.island_4_success = true
	
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
		if positions_equal(player.global_position, puzzle_9.global_position) and !GameState.puzzle9_success:
			scene_switch("res://scene/puzzle9.tscn")
			return
		if positions_equal(player.global_position, puzzle_10.global_position) and !GameState.puzzle10_success:
			scene_switch("res://scene/puzzle10.tscn")
			return
		if positions_equal(player.global_position, puzzle_11.global_position) and !GameState.puzzle11_success:
			scene_switch("res://scene/puzzle11.tscn")
			return
		if positions_equal(player.global_position, puzzle_12.global_position) and !GameState.puzzle12_success:
			scene_switch("res://scene/puzzle12.tscn")
			return
		if positions_equal(player.global_position, puzzle_13.global_position) and !GameState.puzzle13_success:
			scene_switch("res://scene/puzzle13.tscn")
			return
		if positions_equal(player.global_position, puzzle_14.global_position) and !GameState.puzzle14_success:
			scene_switch("res://scene/puzzle14.tscn")
			return
		if positions_equal(player.global_position, puzzle_15.global_position) and !GameState.puzzle15_success:
			scene_switch("res://scene/puzzle15.tscn")
			return
		if positions_equal(player.global_position, puzzle_17.global_position) and !GameState.puzzle17_success:
			scene_switch("res://scene/puzzle17.tscn")
			return
		if positions_equal(player.global_position, Vector2(3952,-1270)) and GameState.island_4_success:
			scene_switch("res://scene/baseArena.tscn")
			return
	if positions_equal(player.global_position, Vector2(144,-182)) and GameState.island_2_success:
		pause_process = true
		player.visible = false
		player._move_to(Vector2(1488,-758))
		await get_tree().create_timer(0.5).timeout
		player.visible = true
		pause_process = false
	if positions_equal(player.global_position, Vector2(2256,-246)) and GameState.island_3_success:
		pause_process = true
		player.visible = false
		player._move_to(Vector2(3952,-566))
		await get_tree().create_timer(0.5).timeout
		GameState.on_island_4 = true
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
	save_data = {
		"player_pos": GameState.player_pos,
		"camera_pos": GameState.camera_pos,
		"player_texture": GameState.player_texture,
		"puzzle1_success": GameState.puzzle1_success,
		"puzzle2_success": GameState.puzzle2_success,
		"puzzle3_success": GameState.puzzle3_success,
		"puzzle4_success": GameState.puzzle4_success,
		"puzzle5_success": GameState.puzzle5_success,
		"puzzle6_success": GameState.puzzle6_success,
		"puzzle7_success": GameState.puzzle7_success,
		"puzzle8_success": GameState.puzzle8_success,
		"puzzle9_success": GameState.puzzle9_success,
		"puzzle10_success": GameState.puzzle10_success,
		"puzzle11_success": GameState.puzzle11_success,
		"puzzle12_success": GameState.puzzle12_success,
		"puzzle13_success": GameState.puzzle13_success,
		"puzzle14_success": GameState.puzzle14_success,
		"puzzle15_success": GameState.puzzle15_success,
		"puzzle16_success": GameState.puzzle16_success,
		"puzzle17_success": GameState.puzzle17_success,
		"island_2_success": GameState.island_2_success,
		"island_3_success": GameState.island_3_success,
		"island_4_success": GameState.island_4_success,
		"on_island_4": GameState.on_island_4,
		"world_instruction": GameState.world_instruction,
		"master_volume": GameState.master_volume
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	var json_data = JSON.stringify(save_data)
	file.store_line(json_data)
	file.close()
	GameState.first_launch = false
	print("Jeu sauvegardé")
	
func GSload():
	if GameState.first_launch:
		if not FileAccess.file_exists(save_path):
			print("Aucun fichier de sauvegarde trouvé")
			return
		
		var file = FileAccess.open(save_path, FileAccess.READ)
		var line = file.get_line()
		var data = JSON.parse_string(line)
		file.close()
		
		if typeof(data) == TYPE_DICTIONARY:
			save_data = data
			var p_pos = save_data["player_pos"].replace("(", "").replace(")", "").split(", ")
			var c_pos = save_data["camera_pos"].replace("(", "").replace(")", "").split(", ")
			GameState.player_pos = Vector2(int(p_pos[0]),int(p_pos[1]))
			GameState.camera_pos = Vector2(int(c_pos[0]),int(c_pos[1]))
			GameState.player_texture = save_data["player_texture"]
			GameState.puzzle1_success = save_data["puzzle1_success"]
			GameState.puzzle2_success = save_data["puzzle2_success"]
			GameState.puzzle3_success = save_data["puzzle3_success"]
			GameState.puzzle4_success = save_data["puzzle4_success"]
			GameState.puzzle5_success = save_data["puzzle5_success"]
			GameState.puzzle6_success = save_data["puzzle6_success"]
			GameState.puzzle7_success = save_data["puzzle7_success"]
			GameState.puzzle8_success = save_data["puzzle8_success"]
			GameState.puzzle9_success = save_data["puzzle9_success"]
			GameState.puzzle10_success = save_data["puzzle10_success"]
			GameState.puzzle11_success = save_data["puzzle11_success"]
			GameState.puzzle12_success = save_data["puzzle12_success"]
			GameState.puzzle13_success = save_data["puzzle13_success"]
			GameState.puzzle14_success = save_data["puzzle14_success"]
			GameState.puzzle15_success = save_data["puzzle15_success"]
			GameState.puzzle16_success = save_data["puzzle16_success"]
			GameState.puzzle17_success = save_data["puzzle17_success"]
			GameState.island_2_success = save_data["island_2_success"]
			GameState.island_3_success = save_data["island_3_success"]
			GameState.island_4_success = save_data["island_4_success"]
			GameState.on_island_4 = save_data["on_island_4"]
			GameState.world_instruction = save_data["world_instruction"]
			GameState.master_volume = save_data["master_volume"]
			print("Sauvegarde chargée")
	
	if GameState.player_pos:
		player.global_position = GameState.player_pos
		player.change_texture(GameState.player_texture)
		turn = GameState.turn
