extends Control

@export var player: CharacterBody2D

@onready var pawn: TextureButton = $VBoxContainer/Pawn
@onready var rook: TextureButton = $VBoxContainer/Rook
@onready var knight: TextureButton = $VBoxContainer/Knight
@onready var bishop: TextureButton = $VBoxContainer/Bishop
@onready var queen: TextureButton = $VBoxContainer/Queen
@onready var king: TextureButton = $VBoxContainer/King

func _ready() -> void:
	pawn.visible = true
	rook.visible = false
	knight.visible = false
	bishop.visible = false
	queen.visible = false
	king.visible = false
	match player.get_texture():
		"wp": pawn.button_pressed = true
		"wr": rook.button_pressed = true
		"wn": knight.button_pressed = true
		"wb": bishop.button_pressed = true
		"wq": queen.button_pressed = true
		"wk": king.button_pressed = true

func _process(_delta: float):
	if GameState.puzzle1_success: rook.visible = true
	if GameState.puzzle2_success: bishop.visible = true
	if GameState.puzzle3_success: knight.visible = true

func _on_pawn_button_down() -> void:
	player.change_sprite("wp")
	rook.button_pressed = false
	knight.button_pressed = false
	bishop.button_pressed = false
	queen.button_pressed = false
	king.button_pressed = false

func _on_rook_button_down() -> void:
	player.change_sprite("wr")
	pawn.button_pressed = false
	knight.button_pressed = false
	bishop.button_pressed = false
	queen.button_pressed = false
	king.button_pressed = false

func _on_knight_button_down() -> void:
	player.change_sprite("wn")
	pawn.button_pressed = false
	rook.button_pressed = false
	bishop.button_pressed = false
	queen.button_pressed = false
	king.button_pressed = false

func _on_bishop_button_down() -> void:
	player.change_sprite("wb")
	pawn.button_pressed = false
	rook.button_pressed = false
	knight.button_pressed = false
	queen.button_pressed = false
	king.button_pressed = false

func _on_queen_button_down() -> void:
	player.change_sprite("wq")
	pawn.button_pressed = false
	rook.button_pressed = false
	knight.button_pressed = false
	bishop.button_pressed = false
	king.button_pressed = false

func _on_king_button_down() -> void:
	player.change_sprite("wk")
	pawn.button_pressed = false
	rook.button_pressed = false
	knight.button_pressed = false
	bishop.button_pressed = false
	queen.button_pressed = false
