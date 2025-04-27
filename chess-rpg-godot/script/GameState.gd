extends Node

var player_pos: Vector2
var player_texture: String
var puzzle1_success = false
var puzzle2_success = false
var puzzle3_success = false
var puzzle4_success = false
var puzzle6_success = false
var puzzle7_success = false
var puzzle8_success = false
var puzzle11_success = false
var puzzle12_success = false
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
