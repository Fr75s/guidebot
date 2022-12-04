extends Control

onready var global = get_node("/root/Global")
var tween

var currently_focused_set = 1
var unlocked_sets = 1
var num_sets = 4 # Change as needed

var game_just_completed = false

var show_set_arrows = false

# Called when the node enters the scene tree for the first time.
func _ready():
	tween = $Tween
	$ButtonAudio.stream.loop = false
	
	# Play Music
	if not global.mute_music:
		$MusicPlayer.play()
	
	global.connect("toggle_music", self, "on_toggle_music")
	
	# Load Save Data
	
	global.save_progress()
	
	# Progress Checks
	var completion_index = 1
	var completed_levels = 0
	for completion_status in global.levels_completed:
		#print("Level ", completion_index, " Completed? ", completion_status)
		
		# Get Level Buttons to draw checkmarks
		var level_set = floor((completion_index - 1) / 5.0) + 1
		var level_button = get_node("LevelSelect/Set" + str(level_set) + "/Level" + str(completion_index))
		
		level_button.connect("pressed", self, "on_level_button_pressed", [completion_index])
		
		if completion_status:
			completed_levels += 1
			draw_completion_checkmark(level_button)
		
		# Progression
		if completed_levels >= 5:
			unlocked_sets = 2
			show_set_arrows = true

			if not(global.unlock_goals[0]):
				$LevelSelect/NewLevelIndicator.visible = true
				global.unlock_goals[0] = true
	
		if completed_levels >= 10:
			unlocked_sets = 3

			if not(global.unlock_goals[1]):
				$LevelSelect/NewLevelIndicator.visible = true
				global.unlock_goals[1] = true
		
		if completed_levels >= 15:
			unlocked_sets = 4

			if not(global.unlock_goals[2]):
				$LevelSelect/NewLevelIndicator.visible = true
				global.unlock_goals[2] = true
		
		if completed_levels >= 20 and not(global.unlock_goals[3]):
			global.unlock_goals[3] = true
			game_just_completed = true
		
		# Show secret sum of best
		if completed_levels == len(global.levels_completed):
			$LevelSelect/Options.show_sumofbest()
		
		completion_index += 1
	
	if game_just_completed:
		$GameCompletionScreen.rect_position = Vector2(0, 0)
		$TitleScreen.rect_position = Vector2(0, 720)
		game_just_completed = false
	
	elif global.to_level_select:
		$TitleScreen.rect_position = Vector2(0, -720)
		$LevelSelect.rect_position = Vector2(0, 0)
		
		# Go to the page with the level you left from
		var level_page = floor((global.level - 1) / 5.0)
		currently_focused_set = level_page + 1
		for set in range(0, num_sets):
			var this_set_node = get_node("LevelSelect/Set" + str(set + 1))
			this_set_node.rect_position = Vector2(this_set_node.rect_position.x - 1280 * level_page, 0)
		
		
	
	# Show arrows
	if show_set_arrows:
		if currently_focused_set < unlocked_sets:
			$LevelSelect/NextSet.visible = true
		if currently_focused_set > 1:
			$LevelSelect/PrevSet.visible = true
	
	if global.level_just_completed:
		global.level_just_completed = false
	else:
		if global.to_level_select:
			if not global.mute_sfx:
				$ButtonAudio.play()

func on_toggle_music():
	if $MusicPlayer.playing:
		$MusicPlayer.stop()
	else:
		$MusicPlayer.play()

func _on_PlayButton_pressed():
	$TitleScreen/PlayButton.disabled = true
	if not global.mute_sfx:
		$ButtonAudio.play()
	tween.interpolate_property($TitleScreen, "rect_position", Vector2(0, 0), Vector2(0, -720), 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property($LevelSelect, "rect_position", Vector2(0, 720), Vector2(0, 0), 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()

func _on_CompletionProceed_pressed():
	$GameCompletionScreen/CompletionProceed.disabled = true
	if not global.mute_sfx:
		$ButtonAudio.play()
	tween.interpolate_property($GameCompletionScreen, "rect_position", Vector2(0, 0), Vector2(0, -720), 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property($TitleScreen, "rect_position", Vector2(0, 720), Vector2(0, 0), 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()


func draw_completion_checkmark(parent):
	var check_scene = load("res://scenes/interface/CompletionCheck.tscn")
	var check = check_scene.instance()
	parent.add_child(check)

func switch_to_level(level):
	global.level = level
	get_tree().change_scene("res://scenes/Level.tscn")


func _on_NextSet_pressed():
	if not global.mute_sfx:
		$ButtonAudio.play()
	if not tween.is_active():
		currently_focused_set += 1
		if currently_focused_set > unlocked_sets:
			currently_focused_set = unlocked_sets
		else:
			for set in range(0, num_sets):
				var this_set_node = get_node("LevelSelect/Set" + str(set + 1))
				tween.interpolate_property(this_set_node, "rect_position", Vector2(this_set_node.rect_position.x, 0), Vector2(this_set_node.rect_position.x - 1280, 0), 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)

		tween.start()
		
		$LevelSelect/PrevSet.visible = true
		if currently_focused_set == unlocked_sets:
			$LevelSelect/NextSet.visible = false

func _on_PrevSet_pressed():
	if not global.mute_sfx:
		$ButtonAudio.play()
	if not tween.is_active():
		currently_focused_set -= 1
		if currently_focused_set < 1:
			currently_focused_set = 1
		else:
			for set in range(0, num_sets):
				var this_set_node = get_node("LevelSelect/Set" + str(set + 1))
				tween.interpolate_property(this_set_node, "rect_position", Vector2(this_set_node.rect_position.x, 0), Vector2(this_set_node.rect_position.x + 1280, 0), 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)

		tween.start()
		
		$LevelSelect/NextSet.visible = true
		if currently_focused_set == 1:
			$LevelSelect/PrevSet.visible = false


func on_level_button_pressed(level):
	switch_to_level(level)
