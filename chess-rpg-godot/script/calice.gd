extends AnimatedSprite2D

func adjust_volume(db: float):
	$AudioStreamPlayer2D.volume_db = db
