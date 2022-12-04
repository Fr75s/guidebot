extends Control

onready var global = get_node("/root/Global")

var tween
var options_up = false

func _ready():
	tween = $OptionsTween
	$OptionsAudio.stream.loop = false
	
	if OS.get_name() in ["X11", "Windows", "OSX", "UWP"]:
		$OptionsPanel/ExitButton.visible = true
	
	if global.mute_music:
		$OptionsPanel/MuteMusic.pressed = true
	
	if global.mute_sfx:
		$OptionsPanel/MuteSFX.pressed = true

func show_sumofbest():
	# Show sum of best
	$OptionsPanel/SumOfBestLabel.visible = true
	
	# Calculate Sum of Best
	var total_time = 0
	for time in global.level_times:
		total_time += time
	
	if total_time > 0:
		var converted_sum = global.convert_time(total_time)
		$OptionsPanel/SumOfBestLabel.text = "Sum of Best: " + global.format_converted_time(converted_sum)
	else:
		$OptionsPanel/SumOfBestLabel.visible = false

func _on_OptionsButton_pressed():
	if not global.mute_sfx:
		$OptionsAudio.play()
	
	if not tween.is_active():
		var destination = Vector2(64, 64)
		if options_up:
			destination = Vector2(64, 784)
		
		options_up = not options_up
		
		tween.interpolate_property($OptionsPanel, "rect_position", $OptionsPanel.rect_position, destination, 0.75, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		tween.start()

# Buttons
func _on_FullScreenButton_pressed():
	print("Going Fullscreen")
	if not global.mute_sfx:
		$OptionsAudio.play()
	OS.window_fullscreen = not OS.window_fullscreen

func _on_ExitButton_pressed():
	print("Exiting")
	if not global.mute_sfx:
		$OptionsAudio.play()
	get_tree().quit()


# Option Toggles
func _on_MuteMusic_pressed():
	if not global.mute_sfx:
		$OptionsAudio.play()
	print("Toggling Music")
	
	global.mute_music = not global.mute_music
	global.emit_signal("toggle_music")
	global.save_progress()

func _on_MuteSFX_pressed():
	print("Toggling SFX")
	global.mute_sfx = not global.mute_sfx
	global.save_progress()
	
	if not global.mute_sfx:
		$OptionsAudio.play()

# Secrets
func _on_SecretInput_text_entered(new_text):
	var parse_text = new_text.to_lower().replace(" ", "").replace("-", "")
	
	if parse_text in ["deletealldatapls", "deletemydatapls"]:
		global.clear_save()
		$OptionsPanel/SecretInput.text = "Ok, you asked."
	
	if parse_text in ["quirrel", "gr18", "levelhead"]:
		global.fill_save()
		$OptionsPanel/SecretInput.text = "ULTRA HECK YEAH!"
	
	if parse_text in ["bugfables", "vi", "kabbu", "leif", "hollowknight", "geometrydash"]:
		$OptionsPanel/SecretInput.text = "Heck Yeah!"
	
	if parse_text in ["mariomaker", "supermariomaker"]:
		global.clear_save()
		$OptionsPanel/SecretInput.text = "Now your save's gone"
	
	if parse_text == "secret?":
		$OptionsPanel/SecretInput.text = "Yes."
		
	if parse_text == "really?":
		$OptionsPanel/SecretInput.text = "Indeed."
	
	if parse_text == "quite.":
		$OptionsPanel/SecretInput.text = "Quite. Yes."
	
	if parse_text == ":(":
		$OptionsPanel/SecretInput.text = "I'm not a therapist."
	
	if parse_text == ":)":
		$OptionsPanel/SecretInput.text = "All is well then."
	
	if parse_text == ">:(":
		$OptionsPanel/SecretInput.text = "Sorry?"
	
	if parse_text == "devilvortexsaws":
		$OptionsPanel/SecretInput.text = ":("
	
	if parse_text == "nightmode":
		if not global.secret_lightmode:
			global.secret_nightmode = true
			$OptionsPanel/SecretInput.text = "Your eyes are safe."
		else:
			global.secret_nightmode = false
			global.secret_lightmode = false
			get_tree().reload_current_scene()
	
	if parse_text == "lightmode":
		if not global.secret_nightmode:
			global.secret_lightmode = true
			$OptionsPanel/SecretInput.text = "Your eyes burn."
		else:
			global.secret_nightmode = false
			global.secret_lightmode = false
			get_tree().reload_current_scene()
