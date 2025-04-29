extends Control

@export var player: CharacterBody2D

@onready var pawn: TextureButton = $VBoxContainer/Control/Pawn
@onready var rook: TextureButton = $VBoxContainer/Control2/Rook
@onready var knight: TextureButton = $VBoxContainer/Control4/Knight
@onready var bishop: TextureButton = $VBoxContainer/Control3/Bishop
@onready var queen: TextureButton = $VBoxContainer/Control5/Queen
@onready var king: TextureButton = $VBoxContainer/Control6/King

@onready var control_pawn: Control = $VBoxContainer/Control
@onready var control_rook: Control = $VBoxContainer/Control2
@onready var control_knight: Control = $VBoxContainer/Control4
@onready var control_bishop: Control = $VBoxContainer/Control3
@onready var control_queen: Control = $VBoxContainer/Control5
@onready var control_king: Control = $VBoxContainer/Control6

@onready var texture_rect_pawn: TextureRect = $VBoxContainer/Control/TextureRect_Pawn
@onready var texture_rect_rook: TextureRect = $VBoxContainer/Control2/TextureRect_Rook
@onready var texture_rect_bishop: TextureRect = $VBoxContainer/Control3/TextureRect_Bishop
@onready var texture_rect_knight: TextureRect = $VBoxContainer/Control4/TextureRect_Knight
@onready var texture_rect_queen: TextureRect = $VBoxContainer/Control5/TextureRect_Queen
@onready var texture_rect_king: TextureRect = $VBoxContainer/Control6/TextureRect_King

var pawn_texture = "redp"
var rook_texture = "wr"
var knight_texture = "wn"
var bishop_texture = "wb"
var queen_texture = "widq"
var king_texture = "wk"

func _ready() -> void:
	if GameState.puzzle8_success: rook_texture = "hulr"
	if GameState.puzzle10_success: knight_texture = "batn"
	if GameState.puzzle6_success: bishop_texture = "capb"
	if GameState.puzzle17_success: king_texture = "spik"
	control_pawn.visible = true
	control_rook.visible = false
	control_knight.visible = false
	control_bishop.visible = false
	control_queen.visible = false
	control_king.visible = false
	match player.get_texture():
		pawn_texture: pawn.button_pressed = true
		rook_texture: rook.button_pressed = true
		knight_texture: knight.button_pressed = true
		bishop_texture: bishop.button_pressed = true
		queen_texture: queen.button_pressed = true
		king_texture: king.button_pressed = true

func _process(_delta: float):
	match player.get_texture():
		pawn_texture: 
			pawn.disabled = true
			rook.disabled = false
			knight.disabled = false
			bishop.disabled = false
			queen.disabled = false
			king.disabled = false
		rook_texture: 
			pawn.disabled = false
			rook.disabled = true
			knight.disabled = false
			bishop.disabled = false
			queen.disabled = false
			king.disabled = false
		knight_texture: 
			pawn.disabled = false
			rook.disabled = false
			knight.disabled = true
			bishop.disabled = false
			queen.disabled = false
			king.disabled = false
		bishop_texture: 
			pawn.disabled = false
			rook.disabled = false
			knight.disabled = false
			bishop.disabled = true
			queen.disabled = false
			king.disabled = false
		queen_texture: 
			pawn.disabled = false
			rook.disabled = false
			knight.disabled = false
			bishop.disabled = false
			queen.disabled = true
			king.disabled = false
		king_texture:
			pawn.disabled = false
			rook.disabled = false
			knight.disabled = false
			bishop.disabled = false
			queen.disabled = false
			king.disabled = true
	if GameState.puzzle1_success: control_rook.visible = true
	if GameState.puzzle2_success: control_bishop.visible = true
	if GameState.puzzle3_success: control_knight.visible = true

func _on_pawn_button_down() -> void:
	player.change_texture(pawn_texture)
	rook.button_pressed = false
	knight.button_pressed = false
	bishop.button_pressed = false
	queen.button_pressed = false
	king.button_pressed = false

func _on_rook_button_down() -> void:
	player.change_texture(rook_texture)
	pawn.button_pressed = false
	knight.button_pressed = false
	bishop.button_pressed = false
	queen.button_pressed = false
	king.button_pressed = false

func _on_knight_button_down() -> void:
	player.change_texture(knight_texture)
	pawn.button_pressed = false
	rook.button_pressed = false
	bishop.button_pressed = false
	queen.button_pressed = false
	king.button_pressed = false

func _on_bishop_button_down() -> void:
	player.change_texture(bishop_texture)
	pawn.button_pressed = false
	rook.button_pressed = false
	knight.button_pressed = false
	queen.button_pressed = false
	king.button_pressed = false

func _on_queen_button_down() -> void:
	player.change_texture(queen_texture)
	pawn.button_pressed = false
	rook.button_pressed = false
	knight.button_pressed = false
	bishop.button_pressed = false
	king.button_pressed = false

func _on_king_button_down() -> void:
	player.change_texture(king_texture)
	pawn.button_pressed = false
	rook.button_pressed = false
	knight.button_pressed = false
	bishop.button_pressed = false
	queen.button_pressed = false


func _on_pawn_mouse_entered() -> void:
	texture_rect_pawn.visible = true

func _on_pawn_mouse_exited() -> void:
	texture_rect_pawn.visible = false

func _on_rook_mouse_entered() -> void:
	texture_rect_rook.visible = true

func _on_rook_mouse_exited() -> void:
	texture_rect_rook.visible = false

func _on_bishop_mouse_entered() -> void:
	texture_rect_bishop.visible = true

func _on_bishop_mouse_exited() -> void:
	texture_rect_bishop.visible = false

func _on_knight_mouse_entered() -> void:
	texture_rect_knight.visible = true

func _on_knight_mouse_exited() -> void:
	texture_rect_knight.visible = false

func _on_queen_mouse_entered() -> void:
	texture_rect_queen.visible = true

func _on_queen_mouse_exited() -> void:
	texture_rect_queen.visible = false

func _on_king_mouse_entered() -> void:
	texture_rect_king.visible = true

func _on_king_mouse_exited() -> void:
	texture_rect_king.visible = false
