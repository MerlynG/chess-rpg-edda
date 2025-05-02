extends MarginContainer

func _on_texture_button_button_down() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)
	return
