extends CharacterBody2D
@onready var character_body_2d: CharacterBody2D = $"."
@onready var map: TileMapLayer = $"../Map"

const tile_size: Vector2 = Vector2(32, 32)
var sprite_node_pos_tween: Tween
var is_selected: bool = false

const WB = preload("res://assets/wb.png")
const WK = preload("res://assets/wk.png")
const WN = preload("res://assets/wn.png")
const WP = preload("res://assets/wp.png")
const WQ = preload("res://assets/wq.png")
const WR = preload("res://assets/wr.png")

func _ready() -> void:
	set_process_input(true)

func _on_clic_detector_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and !is_selected:
		is_selected = true
		map.get_moves(character_body_2d, "p")
		$Sprite2D.global_position.y -= 6
		

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and is_selected:
		$Sprite2D.global_position.y += 6
		var mouse_pos = get_global_mouse_position()
		var target = mouse_pos.snapped(tile_size)
		
		if target.x <= mouse_pos.x: target.x += 16
		else: target.x -= 16
		if target.y <= mouse_pos.y: target.y += 10
		else: target.y -= 22
		
		is_selected = false
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
