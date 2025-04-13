extends CharacterBody2D
@onready var character_body_2d: CharacterBody2D = $"."
@onready var map: TileMapLayer = $"../../Map"

var sprite_node_pos_tween: Tween

const BB = preload("res://assets/bb.png")
const BK = preload("res://assets/bk.png")
const BN = preload("res://assets/bn.png")
const BP = preload("res://assets/bp.png")
const BQ = preload("res://assets/bq.png")
const BR = preload("res://assets/br.png")
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
		BB: return "bb"
		BK: return "bk"
		BN: return "bn"
		BP: return "bp"
		BQ: return "bq"
		BR: return "br"
		BLB: return "blb"
		BLK: return "blk"
		BLN: return "bln"
		BLP: return "blp"
		BLQ: return "blq"
		BLR: return "blr"

func change_sprite(texture: String):
	match texture:
		"bb":$Sprite2D.texture = BB
		"bk":$Sprite2D.texture = BK
		"bn":$Sprite2D.texture = BN
		"bp":$Sprite2D.texture = BP
		"bq":$Sprite2D.texture = BQ
		"br":$Sprite2D.texture = BR
		"blb":$Sprite2D.texture = BLB
		"blk":$Sprite2D.texture = BLK
		"bln":$Sprite2D.texture = BLN
		"blp":$Sprite2D.texture = BLP
		"blq":$Sprite2D.texture = BLQ
		"blr":$Sprite2D.texture = BLR
