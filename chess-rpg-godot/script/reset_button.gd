extends MarginContainer

@onready var reset_button: MarginContainer = $"."
@onready var v_slider: HSlider = $"../VBoxContainer/Slider/Control/VSlider"

func _ready() -> void:
	if get_tree().current_scene.name == "World":
		reset_button.visible = false
	if $"..".is_visible_in_tree():
		v_slider.value = GameState.master_volume

func _on_texture_button_button_down() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)
	return

func _on_texture_button_toggled(toggled_on: bool) -> void:
	if toggled_on: v_slider.visible = true
	else: v_slider.visible = false

func _on_v_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)
	GameState.master_volume = value
