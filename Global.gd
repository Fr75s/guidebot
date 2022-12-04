extends Node

var mute_music = false
var mute_sfx = false

signal toggle_music

var gravity = 1000
var level = 0
var to_level_select = false
var level_just_completed = false

var levels_completed = []
var level_times = []
var unlock_goals = []

var target_levels = 20
var target_unlocks = 4

var secret_nightmode = false
var secret_lightmode = false

# Saving and Loading

func save_progress():
	print("Saving Progress...")
	var save_file = File.new()
	save_file.open("user://guidebot_save.json", File.WRITE)
	
	var save_data = {
		"completed": levels_completed,
		"times": level_times,
		"unlock_goals": unlock_goals,
		"mute_music": mute_music,
		"mute_sfx": mute_sfx
	}
	
	save_file.store_line(to_json(save_data))
	print("Saved. Closing File...")
	save_file.close()

func load_progress():
	print("Loading Progress...")
	var save_file = File.new()
	save_file.open("user://guidebot_save.json", File.READ)
	
	var save_data = JSON.parse(save_file.get_as_text())
	
	if save_data.error == OK:
		var parsed_data = save_data.result
		levels_completed = parsed_data.completed
		unlock_goals = parsed_data.unlock_goals
		
		# Because JSON stores times as floats, convert to ints to prevent errors
		var raw_level_times = parsed_data.times
		level_times = []
		for time in raw_level_times:
			level_times.append(int(time))
		
		if len(levels_completed) != target_levels:
			while len(levels_completed) < target_levels:
				levels_completed.append(false)
		
		if len(level_times) != target_levels:
			while len(level_times) < target_levels:
				level_times.append(0)
		
		if len(unlock_goals) != target_unlocks:
			while len(unlock_goals) < target_unlocks:
				unlock_goals.append(false)
		
		if "mute_music" in parsed_data:
			mute_music = parsed_data.mute_music
		
		if "mute_sfx" in parsed_data:
			mute_sfx = parsed_data.mute_sfx
		
		print("Data successfully loaded!")
		
	else:
		print("Uh oh, an error was encountered loading the file.")
		
		print("\nLine ", save_data.error_line)
		print("Error: ", save_data.error_string)
		
		clear_save()

func clear_save():
	levels_completed = []
	level_times = []
	unlock_goals = []
	
	for i in range(0, target_levels):
		levels_completed.append(false)
		level_times.append(0)
	
	for i in range(0, target_unlocks):
		unlock_goals.append(false)
	
	save_progress()

func fill_save():
	levels_completed = []
	unlock_goals = []
	
	for i in range(0, target_levels):
		levels_completed.append(true)
	
	for i in range(0, target_unlocks):
		unlock_goals.append(true)
	
	save_progress()

# On Game Startup

func _ready():
	var file_checker = File.new()
	if file_checker.file_exists("user://guidebot_save.json"):
		load_progress()
	else:
		clear_save()



# General Helper Functions

func convert_time(time_ms):
	var seconds = int(floor(time_ms / 1000.0))
	var minutes = int(floor(seconds / 60.0))
	
	minutes = "%02d" % (minutes)
	seconds = "%02d" % (seconds % 60)
	time_ms = "%03d" % (time_ms % 1000)
	
	return [str(minutes), str(seconds), str(time_ms)]

func format_converted_time(time_cv):
	return time_cv[0] + ":" + time_cv[1] + "." + time_cv[2]
