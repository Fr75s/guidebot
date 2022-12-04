extends Area2D

onready var global = get_node("/root/Global")

var toggled = false

func _ready():
	$SwitchAudio.stream.loop = false

func on_reset_level():
	toggled = false
	$SwitchSprites.frame = 0

func _on_BlueSwitch_body_entered(body):
	if "Bot" in body.name:
		toggled = not toggled
		$SwitchSprites.frame = 1 if toggled else 0
		if not global.mute_sfx:
			$SwitchAudio.play()
		
		get_parent().get_node("Adjustables").on_blue_switch_toggle()
