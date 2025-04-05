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
		"bb":$Sprite2D.texture = BB
		"bk":$Sprite2D.texture = BK
		"bn":$Sprite2D.texture = BN
		"bp":$Sprite2D.texture = BP
		"bq":$Sprite2D.texture = BQ
		"br":$Sprite2D.texture = BR
