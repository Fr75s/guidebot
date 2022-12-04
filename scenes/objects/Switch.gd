extends Area2D

onready var global = get_node("/root/Global")

var toggled = false

func _ready():
	$SwitchAudio.stream.loop = false

func on_reset_level():
	toggled = false
	$SwitchSprites.frame = 0

func _on_Switch_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton) and (event.pressed) and (event.button_index == BUTTON_LEFT):
		toggled = not toggled
		$SwitchSprites.frame = 1 if toggled else 0
		if not global.mute_sfx:
			$SwitchAudio.play()
		
		get_parent().get_node("Adjustables").on_red_switch_toggle()
