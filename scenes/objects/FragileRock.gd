extends StaticBody2D

onready var global = get_node("/root/Global")

var rock_gone = false
var rock_needs_reforming = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$RockAudio.stream.loop = false

func _process(delta):
	if rock_needs_reforming:
		print("Reforming...")
		$RockSprites.animation = "normal"
		$RockSprites.playing = false
		$RockCollision.disabled = false
		rock_gone = false
		rock_needs_reforming = false

func on_reset_level():
	rock_needs_reforming = true

func _on_RockCheck_body_entered(body):
	if "Bot" in body.name and not rock_gone:
		$RockSprites.playing = true
		$RockSprites.animation = "break"
		if not global.mute_sfx:
			$RockAudio.play()

func _on_RockSprites_animation_finished():
	$RockSprites.playing = false
	rock_gone = true
	$RockCollision.disabled = true
	$RockSprites.animation = "gone"
