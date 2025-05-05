extends Node

const tile_size = 32
var player_pos: Vector2
var camera_pos: Vector2
var player_texture: String
var puzzle1_success = false
var puzzle2_success = false
var puzzle3_success = false
var puzzle4_success = false
var puzzle5_success = false
var puzzle6_success = false
var puzzle7_success = false
var puzzle8_success = false
var puzzle9_success = false
var puzzle10_success = false
var puzzle11_success = false
var puzzle12_success = false
var puzzle13_success = false
var puzzle14_success = false
var puzzle15_success = false
var puzzle16_success = false
var puzzle17_success = false
var island_2_success = false
var island_3_success = false
var island_4_success = false
var on_island_4 = false
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
var promotion = ""
var world_instruction = true
var music_puzzle_time: float = 0
var master_volume = 0

	##Allies... assemble
	#if GameState.island_2_success:
		#var al = ALLY.instantiate()
		#$".".add_child(al)
		#al.change_texture("redp")
		#al.global_position = uci_to_vect("a0")
		#al = ALLY.instantiate()
		#$".".add_child(al)
		#al.change_texture("blup")
		#al.global_position = uci_to_vect("i6")
		#al = ALLY.instantiate()
		#$".".add_child(al)
		#al.change_texture("brop")
		#al.global_position = uci_to_vect("@5")
		#al = ALLY.instantiate()
		#$".".add_child(al)
		#al.change_texture("capb")
		#al.global_position = uci_to_vect("k1")
		#al = ALLY.instantiate()
		#$".".add_child(al)
		#al.change_texture("grep")
		#al.global_position = uci_to_vect("b9")
		#al = ALLY.instantiate()
		#$".".add_child(al)
		#al.change_texture("batn")
		#al.global_position = uci_to_vect("=3")
		#al = ALLY.instantiate()
		#$".".add_child(al)
		#al.change_texture("hulr")
		#al.global_position = uci_to_vect("l5")
		#al = ALLY.instantiate()
		#$".".add_child(al)
		#al.change_texture("widq")
		#al.global_position = uci_to_vect(">0")
		#al = ALLY.instantiate()
		#$".".add_child(al)
		#al.change_texture("masterk")
		#al.global_position = uci_to_vect("m3")
		#al = ALLY.instantiate()
		#$".".add_child(al)
		#al.change_texture("jadp")
		#al.global_position = uci_to_vect("g9")
		#if GameState.puzzle9_success:
			#al = ALLY.instantiate()
			#$".".add_child(al)
			#al.change_texture("purp")
			#al.global_position = uci_to_vect("f0")
		#if GameState.puzzle12_success:
			#al = ALLY.instantiate()
			#$".".add_child(al)
			#al.change_texture("whip")
			#al.global_position = uci_to_vect("i2")
		#if GameState.puzzle15_success:
			#al = ALLY.instantiate()
			#$".".add_child(al)
			#al.change_texture("yelp")
			#al.global_position = uci_to_vect("@7")
		#if GameState.puzzle17_success:
			#al = ALLY.instantiate()
			#$".".add_child(al)
			#al.change_texture("spik")
			#al.global_position = uci_to_vect("?5")
