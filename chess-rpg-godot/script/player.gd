extends CharacterBody2D
@onready var character_body_2d: CharacterBody2D = $"."
@onready var map: TileMapLayer = $"../../Map"
@onready var movesNode: Node2D = $Moves

const tile_size: Vector2 = Vector2(32, 32)
const select_height = 6
var sprite_node_pos_tween: Tween
var is_selected: bool = false
var general_dir = Vector2(0, -1)

const WB = preload("res://assets/wb.png")
const WK = preload("res://assets/wk.png")
const WN = preload("res://assets/wn.png")
const WP = preload("res://assets/wp.png")
const WQ = preload("res://assets/wq.png")
const WR = preload("res://assets/wr.png")
const MOVE_HANDLER = preload("res://scene/move_handler.tscn")
const MOVE_POSSIBLE = preload("res://assets/MovePossible.png")
const MOVE_IMPOSSIBLE = preload("res://assets/MoveImpossible.png")

func _ready() -> void:
	set_process_input(true)

func _on_clic_detector_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and !is_selected:
		is_selected = true
		$Sprite2D.global_position.y -= select_height
		
		var moves = map.get_moves(character_body_2d, "p", general_dir)
		var pmoves = moves[0]
		var imoves = moves[1]
		for i in pmoves:
			var handler = MOVE_HANDLER.instantiate()
			movesNode.add_child(handler)
			handler.texture = MOVE_POSSIBLE
			handler.global_position = Vector2(i.x, i.y + select_height)
		for i in imoves:
			var handler = MOVE_HANDLER.instantiate()
			movesNode.add_child(handler)
			handler.texture = MOVE_IMPOSSIBLE
			handler.global_position = Vector2(i.x, i.y + select_height)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and is_selected:
		$Sprite2D.global_position.y += select_height
		
		var mouse_pos = get_global_mouse_position()
		var target = mouse_pos.snapped(tile_size)
		
		if target.x <= mouse_pos.x: target.x += tile_size.x/2
		else: target.x -= tile_size.x/2
		if target.y <= mouse_pos.y: target.y += tile_size.y/2 - select_height
		else: target.y -= tile_size.y/2 + select_height
		
		var allow_move = false
		for i in movesNode.get_children():
			if i.global_position == target + Vector2(0, select_height) and i.texture == MOVE_POSSIBLE:
				allow_move = true
			movesNode.remove_child(i)
		
		is_selected = false
		if !allow_move: return
		await get_tree().create_timer(0.1).timeout
		_move_to(target)

func _move_to(target: Vector2):
	var temp_sprite_pos = $Sprite2D.global_position
	global_position = target
	$Sprite2D.global_position = temp_sprite_pos
	
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($Sprite2D, "global_position", global_position, 0.185).set_trans(Tween.TRANS_SINE)

func change_sprite(texture: String):
	match texture:
		"wb":$Sprite2D.texture = WB
		"wk":$Sprite2D.texture = WK
		"wn":$Sprite2D.texture = WN
		"wp":$Sprite2D.texture = WP
		"wq":$Sprite2D.texture = WQ
		"wr":$Sprite2D.texture = WR
