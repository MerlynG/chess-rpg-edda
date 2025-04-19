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
@onready var p_1: Ally = $"../Allies/p1"
@onready var p_2: Ally = $"../Allies/p2"
@onready var p_3: Ally = $"../Allies/p3"
@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"

@export var cam_target: Node2D

const ENEMY = preload("res://scene/enemy.tscn")
const PLAYER = preload("res://scene/player.tscn")
const ICE_TRAP = preload("res://scene/iceTrap.tscn")
const tile_size = 32
const max_moves = 8

var turn = true
var possible_2_steps_pos: Array[Vector2]
var pause_process = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#player.change_texture("wn")
	canvas_layer.visible = true
	GSload()
	GSsave()
	if cam_target:
		camera_2d.position_smoothing_enabled = false
		camera_2d.global_position = cam_target.global_position
		await get_tree().create_timer(0.1).timeout
		camera_2d.position_smoothing_enabled = true
	if p_1: p_1.change_texture("blr")
	if p_2: p_2.change_texture("blb")
	if p_3: p_3.change_texture("bln")
	if GameState.puzzle1_success:
		p_1.queue_free()
		puzzle_1.visible = false
	if GameState.puzzle2_success:
		p_2.queue_free()
		puzzle_2.visible = false
	if GameState.puzzle3_success:
		p_3.queue_free()
		puzzle_3.visible = false
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if cam_target:
		camera_2d.global_position = cam_target.global_position
	if pause_process: return
	if positions_equal(player.global_position, puzzle_1.global_position) and !GameState.puzzle1_success:
		scene_switch("res://scene/puzzle1.tscn")
		return
	if positions_equal(player.global_position, puzzle_2.global_position) and !GameState.puzzle2_success:
		scene_switch("res://scene/puzzle2.tscn")
		return
	if positions_equal(player.global_position, puzzle_3.global_position) and !GameState.puzzle3_success:
		scene_switch("res://scene/puzzle3.tscn")
		return
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
		#await get_tree().create_timer(0.1).timeout
		turn = true

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
				if is_off_limit(moves[i], area_limit) or is_off_limit(moves[i], wall):
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
				var t1 = pos + tile_size * 2 * d + tile_size * d.rotated(PI/2)
				var t2 = pos + tile_size * 2 * d + tile_size * d.rotated(-PI/2)
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
					var temp = pos + tile_size * i * d
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
					var temp = pos + tile_size * i * d
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
				var temp = pos + tile_size * d
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
