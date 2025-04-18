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

func _process(_delta: float):
	pawn.visible


func _on_pawn_button_down() -> void:
	player.change_sprite("wp")

func _on_rook_button_down() -> void:
	player.change_sprite("wr")

func _on_knight_button_down() -> void:
	player.change_sprite("wn")

func _on_bishop_button_down() -> void:
	player.change_sprite("wb")

func _on_queen_button_down() -> void:
	player.change_sprite("wq")

func _on_king_button_down() -> void:
	player.change_sprite("wk")
