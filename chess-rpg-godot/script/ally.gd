class_name Ally
extends CharacterBody2D
@onready var character_body_2d: CharacterBody2D = $"."
@onready var map: TileMapLayer = $"../../Map"

var sprite_node_pos_tween: Tween

const WB = preload("res://assets/wb.png")
const WK = preload("res://assets/wk.png")
const WN = preload("res://assets/wn.png")
const WP = preload("res://assets/wp.png")
const WQ = preload("res://assets/wq.png")
const WR = preload("res://assets/wr.png")
const BLB = preload("res://assets/blb.png")
const BLK = preload("res://assets/blk.png")
const BLN = preload("res://assets/bln.png")
const BLP = preload("res://assets/blp.png")
const BLQ = preload("res://assets/blq.png")
const BLR = preload("res://assets/blr.png")

func _move_to(target: Vector2):
	var temp_sprite_pos = $Sprite2D.global_position
	global_position = target
	$Sprite2D.global_position = temp_sprite_pos
	
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($Sprite2D, "global_position", global_position, 0.185).set_trans(Tween.TRANS_SINE)

func get_texture():
	match $Sprite2D.texture:
		WB: return "wb"
		WK: return "wk"
		WN: return "wn"
		WP: return "wp"
		WQ: return "wq"
		WR: return "wr"
		BLB: return "blb"
		BLK: return "blk"
		BLN: return "bln"
		BLP: return "blp"
		BLQ: return "blq"
		BLR: return "blr"

func change_sprite(texture: String):
	match texture:
		"wb":$Sprite2D.texture = WB
		"wk":$Sprite2D.texture = WK
		"wn":$Sprite2D.texture = WN
		"wp":$Sprite2D.texture = WP
		"wq":$Sprite2D.texture = WQ
		"wr":$Sprite2D.texture = WR
		"blb":$Sprite2D.texture = BLB
		"blk":$Sprite2D.texture = BLK
		"bln":$Sprite2D.texture = BLN
		"blp":$Sprite2D.texture = BLP
		"blq":$Sprite2D.texture = BLQ
		"blr":$Sprite2D.texture = BLR
