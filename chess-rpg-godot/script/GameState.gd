extends Node

const tile_size = 32
var player_pos: Vector2
var player_texture: String
var puzzle1_success = true
var puzzle2_success = true
var puzzle3_success = true
var puzzle4_success = true
var puzzle5_success = true
var puzzle6_success = true
var puzzle7_success = true
var puzzle8_success = true
var puzzle9_success = true
var puzzle10_success = true
var puzzle11_success = true
var puzzle12_success = true
var puzzle13_success = true
var puzzle14_success = true
var puzzle15_success = true
var puzzle16_success = true
var puzzle17_success = true
var turn: bool
var last_white_move: Array
var number_of_turn = 0
var check = false
var check_mate = false
var draw = false
var roque_left_moved = true
var roque_right_moved = true
var roque_left = false
var roque_right = false
var legal_piece: Array
var legal_target: Array
var world_instruction = true

	#var al1 = ALLY.instantiate()
	#allies.add_child(al1)
	#al1.change_texture("redp")
	#al1.global_position = uci_to_vect("a0")
	#if GameState.puzzle4_success:
		#var al = ALLY.instantiate()
		#allies.add_child(al)
		#al.change_texture("blup")
		#al.global_position = uci_to_vect("i6")
	#if GameState.puzzle5_success:
		#var al = ALLY.instantiate()
		#allies.add_child(al)
		#al.change_texture("brop")
		#al.global_position = uci_to_vect("@5")
	#if GameState.puzzle6_success:
		#var al = ALLY.instantiate()
		#allies.add_child(al)
		#al.change_texture("capb")
		#al.global_position = uci_to_vect("k1")
	#if GameState.puzzle7_success:
		#var al = ALLY.instantiate()
		#allies.add_child(al)
		#al.change_texture("grep")
		#al.global_position = uci_to_vect("b9")
	#if GameState.puzzle10_success:
		#var al = ALLY.instantiate()
		#allies.add_child(al)
		#al.change_texture("batn")
		#al.global_position = uci_to_vect("=3")
