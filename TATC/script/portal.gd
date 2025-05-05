extends Node2D

@onready var on: AudioStreamPlayer2D = $ON
@onready var tp: AudioStreamPlayer = $TP

func activate():
	$Portal.animation = "activate"

func portal_on():
	on.play()

func portal_tp():
	tp.play()
