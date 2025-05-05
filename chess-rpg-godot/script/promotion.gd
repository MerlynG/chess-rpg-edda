extends Control

@onready var texture_rect_rook: TextureRect = $HBoxContainer/MarginContainer/TextureRect_Rook
@onready var texture_rect_bishop: TextureRect = $HBoxContainer/MarginContainer2/TextureRect_Bishop
@onready var texture_rect_knight: TextureRect = $HBoxContainer/MarginContainer3/TextureRect_Knight
@onready var texture_rect_queen: TextureRect = $HBoxContainer/MarginContainer4/TextureRect_Queen

func _on_rook_promote_mouse_entered() -> void:
	texture_rect_rook.visible = true

func _on_rook_promote_mouse_exited() -> void:
	texture_rect_rook.visible = false

func _on_bishop_promote_mouse_entered() -> void:
	texture_rect_bishop.visible = true

func _on_bishop_promote_mouse_exited() -> void:
	texture_rect_bishop.visible = false

func _on_knight_promote_mouse_entered() -> void:
	texture_rect_knight.visible = true

func _on_knight_promote_mouse_exited() -> void:
	texture_rect_knight.visible = false

func _on_queen_promote_mouse_entered() -> void:
	texture_rect_queen.visible = true

func _on_queen_promote_mouse_exited() -> void:
	texture_rect_queen.visible = false

func _on_rook_promote_button_down() -> void:
	GameState.promotion = "r"
	$".".queue_free()

func _on_bishop_promote_button_down() -> void:
	GameState.promotion = "b"
	$".".queue_free()

func _on_knight_promote_button_down() -> void:
	GameState.promotion = "n"
	$".".queue_free()

func _on_queen_promote_button_down() -> void:
	GameState.promotion = "q"
	$".".queue_free()
