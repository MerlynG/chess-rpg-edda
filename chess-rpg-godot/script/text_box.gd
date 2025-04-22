extends MarginContainer

@onready var label: Label = $HBoxContainer/MarginContainer/Label
@onready var timer: Timer = $Timer

var text = ""
var letter_index = 0
var time = 0.01

func _ready() -> void:
	#display_text("Ceci est un texte d'exemple parce que rien ne marche correctement bordel")
	pass

func display_text(text_to_display: String):
	$".".visible = true
	text = text_to_display
	label.text = text_to_display
	
	await resized
	await resized
	custom_minimum_size.y = size.y
	
	label.text = ""
	display_letter()

func display_letter():
	label.text += text[letter_index]
	letter_index += 1
	
	if letter_index >= text.length():
		return
	
	timer.start(time)

func _on_timer_timeout() -> void:
	display_letter()


func _on_texture_button_button_up() -> void:
	$".".queue_free()
