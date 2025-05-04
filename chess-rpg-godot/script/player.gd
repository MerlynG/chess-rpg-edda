class_name Player
extends CharacterBody2D
@onready var character_body_2d: CharacterBody2D = $"."
@onready var map: TileMapLayer = $"../../Map"
@onready var movesNode: Node2D = $Moves
@onready var move: AudioStreamPlayer = $Move
@onready var capture: AudioStreamPlayer = $Capture

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
const WCK = preload("res://assets/wck.png")

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

const MOVE_HANDLER = preload("res://scene/move_handler.tscn")
const MOVE_POSSIBLE = preload("res://assets/MovePossible.png")
const MOVE_IMPOSSIBLE = preload("res://assets/MoveImpossible.png")

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
const SPICK = preload("res://assets/spick.png")
const WHIP = preload("res://assets/whip.png")
const WIDQ = preload("res://assets/widq.png")
const YELP = preload("res://assets/yelp.png")
const MASTERK = preload("res://assets/masterk.png")
const MASTERCK = preload("res://assets/masterck.png")

func _ready() -> void:
	set_process_input(true)

func _on_clic_detector_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and !is_selected and map.turn:
		if GameState.check == true and vect_to_uci(character_body_2d.global_position) not in GameState.legal_piece:
			return
		is_selected = true
		$Sprite2D.global_position.y -= select_height
		
		var moves = map.get_moves(character_body_2d, get_texture()[-1], general_dir)
		for i in moves:
			var handler = MOVE_HANDLER.instantiate()
			movesNode.add_child(handler)
			handler.texture = MOVE_POSSIBLE
			handler.global_position = Vector2(i.x, i.y + select_height)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and is_selected:
		$Sprite2D.global_position.y += select_height
		
		var temp_move = character_body_2d.global_position
		
		var mouse_pos = get_global_mouse_position()
		var target = mouse_pos.snapped(Vector2.ONE * GameState.tile_size)
		
		if target.x <= mouse_pos.x: target.x += GameState.tile_size/2
		else: target.x -= GameState.tile_size/2
		if target.y <= mouse_pos.y: target.y += GameState.tile_size/2 - select_height
		else: target.y -= GameState.tile_size/2 + select_height
		
		var allow_move = false
		for i in movesNode.get_children():
			if positions_equal(i.global_position, target + Vector2(0, select_height)) and i.texture == MOVE_POSSIBLE:
				allow_move = true
			movesNode.remove_child(i)
		
		is_selected = false
		if !allow_move: return
		GameState.last_white_move = [temp_move, target, get_texture()]
		await get_tree().create_timer(0.1).timeout
		_move_to(target)
		map.turn = false

func _move_to(target: Vector2):
	var temp_sprite_pos = $Sprite2D.global_position
	global_position = target
	$Sprite2D.global_position = temp_sprite_pos
	
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($Sprite2D, "global_position", global_position, 0.185).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(0.01).timeout
	if !capture.playing: move.play()

func get_texture():
	match $Sprite2D.texture:
		WB: return "wb"
		WK: return "wk"
		WN: return "wn"
		WP: return "wp"
		WQ: return "wq"
		WR: return "wr"
		WCK: return "wck"
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
		SPICK: return "spick"
		WHIP: return "whip"
		WIDQ: return "widq"
		YELP: return "yelp"
		MASTERK: return "masterk"
		MASTERCK: return "masterck"

func change_texture(texture: String):
	match texture:
		"wb":
			$Sprite2D.texture = WB
			$Sprite2D/Ghost.texture = WB
		"wk":
			$Sprite2D.texture = WK
			$Sprite2D/Ghost.texture = WK
		"wn":
			$Sprite2D.texture = WN
			$Sprite2D/Ghost.texture = WN
		"wp":
			$Sprite2D.texture = WP
			$Sprite2D/Ghost.texture = WP
		"wq":
			$Sprite2D.texture = WQ
			$Sprite2D/Ghost.texture = WQ
		"wr":
			$Sprite2D.texture = WR
			$Sprite2D/Ghost.texture = WR
		"wck":
			$Sprite2D.texture = WCK
			$Sprite2D/Ghost.texture = WCK
		"blb":
			$Sprite2D.texture = BLB
			$Sprite2D/Ghost.texture = BLB
		"blk":
			$Sprite2D.texture = BLK
			$Sprite2D/Ghost.texture = BLK
		"bln":
			$Sprite2D.texture = BLN
			$Sprite2D/Ghost.texture = BLN
		"blp":
			$Sprite2D.texture = BLP
			$Sprite2D/Ghost.texture = BLP
		"blq":
			$Sprite2D.texture = BLQ
			$Sprite2D/Ghost.texture = BLQ
		"blr":
			$Sprite2D.texture = BLR
			$Sprite2D/Ghost.texture = BLR
		"rb":
			$Sprite2D.texture = RB
			$Sprite2D/Ghost.texture = RB
		"rk":
			$Sprite2D.texture = RK
			$Sprite2D/Ghost.texture = RK
		"rn":
			$Sprite2D.texture = RN
			$Sprite2D/Ghost.texture = RN
		"rp":
			$Sprite2D.texture = RP
			$Sprite2D/Ghost.texture = RP
		"rq":
			$Sprite2D.texture = RQ
			$Sprite2D/Ghost.texture = RQ
		"rr":
			$Sprite2D.texture = RR
			$Sprite2D/Ghost.texture = RR
		"gb":
			$Sprite2D.texture = GB
			$Sprite2D/Ghost.texture = GB
		"gk":
			$Sprite2D.texture = GK
			$Sprite2D/Ghost.texture = GK
		"gn":
			$Sprite2D.texture = GN
			$Sprite2D/Ghost.texture = GN
		"gp":
			$Sprite2D.texture = GP
			$Sprite2D/Ghost.texture = GP
		"gq":
			$Sprite2D.texture = GQ
			$Sprite2D/Ghost.texture = GQ
		"gr":
			$Sprite2D.texture = GR
			$Sprite2D/Ghost.texture = GR
		"bb":
			$Sprite2D.texture = BB
			$Sprite2D/Ghost.texture = BB
		"bk":
			$Sprite2D.texture = BK
			$Sprite2D/Ghost.texture = BK
		"bn":
			$Sprite2D.texture = BN
			$Sprite2D/Ghost.texture = BN
		"bp":
			$Sprite2D.texture = BP
			$Sprite2D/Ghost.texture = BP
		"bq":
			$Sprite2D.texture = BQ
			$Sprite2D/Ghost.texture = BQ
		"br":
			$Sprite2D.texture = BR
			$Sprite2D/Ghost.texture = BR
		"orb":
			$Sprite2D.texture = ORB
			$Sprite2D/Ghost.texture = ORB
		"ork":
			$Sprite2D.texture = ORK
			$Sprite2D/Ghost.texture = ORK
		"orn":
			$Sprite2D.texture = ORN
			$Sprite2D/Ghost.texture = ORN
		"orp":
			$Sprite2D.texture = ORP
			$Sprite2D/Ghost.texture = ORP
		"orq":
			$Sprite2D.texture = ORQ
			$Sprite2D/Ghost.texture = ORQ
		"orr":
			$Sprite2D.texture = ORR
			$Sprite2D/Ghost.texture = ORR
		"batn":
			$Sprite2D.texture = BATN
			$Sprite2D/Ghost.texture = BATN
		"blup":
			$Sprite2D.texture = BLUP
			$Sprite2D/Ghost.texture = BLUP
		"brop":
			$Sprite2D.texture = BROP
			$Sprite2D/Ghost.texture = BROP
		"capb":
			$Sprite2D.texture = CAPB
			$Sprite2D/Ghost.texture = CAPB
		"grep":
			$Sprite2D.texture = GREP
			$Sprite2D/Ghost.texture = GREP
		"hulr":
			$Sprite2D.texture = HULR
			$Sprite2D/Ghost.texture = HULR
		"jadp":
			$Sprite2D.texture = JADP
			$Sprite2D/Ghost.texture = JADP
		"purp":
			$Sprite2D.texture = PURP
			$Sprite2D/Ghost.texture = PURP
		"redp":
			$Sprite2D.texture = REDP
			$Sprite2D/Ghost.texture = REDP
		"spik":
			$Sprite2D.texture = SPIK
			$Sprite2D/Ghost.texture = SPIK
		"spick":
			$Sprite2D.texture = SPICK
			$Sprite2D/Ghost.texture = SPICK
		"whip":
			$Sprite2D.texture = WHIP
			$Sprite2D/Ghost.texture = WHIP
		"widq":
			$Sprite2D.texture = WIDQ
			$Sprite2D/Ghost.texture = WIDQ
		"yelp":
			$Sprite2D.texture = YELP
			$Sprite2D/Ghost.texture = YELP
		"masterk":
			$Sprite2D.texture = MASTERK
			$Sprite2D/Ghost.texture = MASTERK
		"masterck":
			$Sprite2D.texture = MASTERCK
			$Sprite2D/Ghost.texture = MASTERCK

func positions_equal(a: Vector2, b: Vector2, epsilon := 0.01) -> bool:
	return a.distance_to(b) < epsilon

func uci_to_vect(uci: String):
	var x = uci[0].to_upper().unicode_at(0) - 'A'.unicode_at(0)
	return Vector2(x * GameState.tile_size + 16, (8 - int(uci[1])) * GameState.tile_size + 10)

func vect_to_uci(vect: Vector2):
	@warning_ignore("narrowing_conversion")
	return char(97 + ((vect[0] - 16) / GameState.tile_size)) + str(8 - int((vect[1] - 10) / GameState.tile_size))
