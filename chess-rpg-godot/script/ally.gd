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

const RB = preload("res://assets/rb.png")
const RK = preload("res://assets/rk.png")
const RN = preload("res://assets/rn.png")
const RP = preload("res://assets/rp.png")
const RQ = preload("res://assets/rq.png")
const RR = preload("res://assets/rr.png")

const GB = preload("res://assets/gb.png")
const GK = preload("res://assets/gk.png")
const GN = preload("res://assets/gn.png")
const GP = preload("res://assets/gp.png")
const GQ = preload("res://assets/gq.png")
const GR = preload("res://assets/gr.png")

const BB = preload("res://assets/bb.png")
const BK = preload("res://assets/bk.png")
const BN = preload("res://assets/bn.png")
const BP = preload("res://assets/bp.png")
const BQ = preload("res://assets/bq.png")
const BR = preload("res://assets/br.png")

const ORB = preload("res://assets/orb.png")
const ORK = preload("res://assets/ork.png")
const ORN = preload("res://assets/orn.png")
const ORP = preload("res://assets/orp.png")
const ORQ = preload("res://assets/orq.png")
const ORR = preload("res://assets/orr.png")

const BATN = preload("res://assets/batn.png")
const BLUP = preload("res://assets/blup.png")
const BROP = preload("res://assets/brop.png")
const CAPB = preload("res://assets/capb.png")
const GREP = preload("res://assets/grep.png")
const HULR = preload("res://assets/hulr.png")
const JADP = preload("res://assets/jadp.png")
const PURP = preload("res://assets/purp.png")
const REDP = preload("res://assets/redp.png")
const SPIK = preload("res://assets/spik.png")
const WHIP = preload("res://assets/whip.png")
const WIDQ = preload("res://assets/widq.png")
const YELP = preload("res://assets/yelp.png")

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
		RB: return "rb"
		RK: return "rk"
		RN: return "rn"
		RP: return "rp"
		RQ: return "rq"
		RR: return "rr"
		GB: return "gb"
		GK: return "gk"
		GN: return "gn"
		GP: return "gp"
		GQ: return "gq"
		GR: return "gr"
		BB: return "bb"
		BK: return "bk"
		BN: return "bn"
		BP: return "bp"
		BQ: return "bq"
		BR: return "br"
		ORB: return "orb"
		ORK: return "ork"
		ORN: return "orn"
		ORP: return "orp"
		ORQ: return "orq"
		ORR: return "orr"
		BATN: return "batn"
		BLUP: return "blup"
		BROP: return "brop"
		CAPB: return "capb"
		GREP: return "grep"
		HULR: return "hulr"
		JADP: return "jadp"
		PURP: return "purp"
		REDP: return "redp"
		SPIK: return "spik"
		WHIP: return "whip"
		WIDQ: return "widq"
		YELP: return "yelp"

func change_texture(texture: String):
	match texture:
		"wb": $Sprite2D.texture = WB
		"wk": $Sprite2D.texture = WK
		"wn": $Sprite2D.texture = WN
		"wp": $Sprite2D.texture = WP
		"wq": $Sprite2D.texture = WQ
		"wr": $Sprite2D.texture = WR
		"blb": $Sprite2D.texture = BLB
		"blk": $Sprite2D.texture = BLK
		"bln": $Sprite2D.texture = BLN
		"blp": $Sprite2D.texture = BLP
		"blq": $Sprite2D.texture = BLQ
		"blr": $Sprite2D.texture = BLR
		"rb": $Sprite2D.texture = RB
		"rk": $Sprite2D.texture = RK
		"rn": $Sprite2D.texture = RN
		"rp": $Sprite2D.texture = RP
		"rq": $Sprite2D.texture = RQ
		"rr": $Sprite2D.texture = RR
		"gb": $Sprite2D.texture = GB
		"gk": $Sprite2D.texture = GK
		"gn": $Sprite2D.texture = GN
		"gp": $Sprite2D.texture = GP
		"gq": $Sprite2D.texture = GQ
		"gr": $Sprite2D.texture = GR
		"bb": $Sprite2D.texture = BB
		"bk": $Sprite2D.texture = BK
		"bn": $Sprite2D.texture = BN
		"bp": $Sprite2D.texture = BP
		"bq": $Sprite2D.texture = BQ
		"br": $Sprite2D.texture = BR
		"orb": $Sprite2D.texture = ORB
		"ork": $Sprite2D.texture = ORK
		"orn": $Sprite2D.texture = ORN
		"orp": $Sprite2D.texture = ORP
		"orq": $Sprite2D.texture = ORQ
		"orr": $Sprite2D.texture = ORR
		"batn": $Sprite2D.texture = BATN
		"blup": $Sprite2D.texture = BLUP
		"brop": $Sprite2D.texture = BROP
		"capb": $Sprite2D.texture = CAPB
		"grep": $Sprite2D.texture = GREP
		"hulr": $Sprite2D.texture = HULR
		"jadp": $Sprite2D.texture = JADP
		"purp": $Sprite2D.texture = PURP
		"redp": $Sprite2D.texture = REDP
		"spik": $Sprite2D.texture = SPIK
		"whip": $Sprite2D.texture = WHIP
		"widq": $Sprite2D.texture = WIDQ
		"yelp": $Sprite2D.texture = YELP
