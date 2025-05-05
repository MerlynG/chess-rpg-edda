extends Control

class_name VictoryScreen

@onready var texture_rect: TextureRect = $TextureRect
@onready var victory_text: Label = $VBoxContainer/MarginContainer/VictoryText
@onready var details: Label = $VBoxContainer/MarginContainer2/Details
@onready var timer: Timer = $Timer
@onready var play_button: MarginContainer = $VBoxContainer/HBoxContainer/PlayButton
@onready var success: AudioStreamPlayer = $Success
@onready var failure: AudioStreamPlayer = $Failure

const GREEN = Color("56ab00")
const RED = Color("cb1d00")
const GRAY = Color("4d4d4d")

var text = ""
var letter_index = 0
var time = 0.0005
var time_before_screen_fail = 0.5
var time_before_screen_vict = 0.2

var reward_player_pos: Vector2

func _ready() -> void:
	texture_rect.texture = get_viewport().get_texture()

func set_echec(equality: bool = false):
	await get_tree().create_timer(time_before_screen_fail).timeout
	$".".visible = true
	if equality:
		victory_text.text = "DRAW"
		victory_text.add_theme_color_override("font_color", GRAY)
	else:
		victory_text.text = "ECHEC ET MAT"
		victory_text.add_theme_color_override("font_color", RED)
	await get_tree().create_timer(0.2).timeout
	failure.play()

func set_victory():
	await get_tree().create_timer(time_before_screen_vict).timeout
	$".".visible = true
	victory_text.text = "VICTOIRE"
	victory_text.add_theme_color_override("font_color", GREEN)
	play_button.visible = true
	await get_tree().create_timer(0.2).timeout
	success.play()

func set_failure():
	await get_tree().create_timer(time_before_screen_fail).timeout
	$".".visible = true
	victory_text.text = "PERDU"
	victory_text.add_theme_color_override("font_color", RED)
	await get_tree().create_timer(0.2).timeout
	failure.play()

func set_details(details_text: String):
	text = details_text
	details.text = details_text

	await details.resized
	await details.resized
	await details.resized
	details.custom_minimum_size.y = details.size.y
	
	details.text = ""
	display_letter()

func display_letter():
	details.text += text[letter_index]
	letter_index += 1
	
	if letter_index >= text.length():
		return
	
	timer.start(time)

func set_rewards(player_pos: Vector2):
	reward_player_pos = player_pos

func _on_timer_timeout() -> void:
	display_letter()

func _on_texture_button_button_down() -> void:
	GameState.player_pos += reward_player_pos
	scene_switch("res://scene/world.tscn")
	return

func scene_switch(target_scene: String):
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(target_scene)
	return
