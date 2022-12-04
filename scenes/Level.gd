extends Node2D

signal reset_level
signal level_finished

onready var global = get_node("/root/Global")

var num_bots_initial = 0
var num_bots = 0

var initial_time = Time.get_ticks_msec()
var current_time

var interactive_id_to_scene = {
	0: "res://scenes/objects/EndPad.tscn",
	1: "res://scenes/objects/Switch.tscn",
	2: "res://scenes/objects/Spikes.tscn",
	3: "res://scenes/objects/BlueSwitch.tscn",
	4: "res://scenes/objects/FragileRock.tscn",
	5: "res://scenes/objects/TelepadBlue.tscn",
	6: "res://scenes/objects/TelepadOrange.tscn"
}

func on_bot_reset():
	num_bots = num_bots_initial
	
	$Audio.stream = load("res://assets/audio/fail.ogg")
	$Audio.stream.loop = false
	if not global.mute_sfx:
		$Audio.play()
	emit_signal("reset_level")

func on_bot_finish():
	print("A bot has finished.")
	num_bots -= 1
	if num_bots <= 0:
		global.to_level_select = true
		global.level_just_completed = true
		global.levels_completed[global.level - 1] = true
		
		if current_time < global.level_times[global.level - 1] or global.level_times[global.level - 1] == 0:
			global.level_times[global.level - 1] = current_time
		
		get_tree().change_scene("res://scenes/LevelMenu.tscn")

func load_level(level_data):
	# Place Bots
	for bot_data in level_data.bots:
		var bot_scene = load("res://scenes/objects/Bot.tscn")
		var bot = bot_scene.instance()
		add_child(bot)
		
		bot.position.x = bot_data[0]
		bot.position.y = bot_data[1]
		
		bot.initial_x = bot_data[0]
		bot.initial_y = bot_data[1]
		
		bot.flip = bot_data[2]
		bot.set_flip()
		
		num_bots += 1
		num_bots_initial += 1
		
		bot.connect("reset_bot", self, "on_bot_reset")
		self.connect("reset_level", bot, "reset_bot", [false])
		bot.connect("bot_finished", self, "on_bot_finish")
	
	# Place Interactable Objects
	for interactive_item in level_data.interactives:
		var interactive_scene = load(interactive_id_to_scene[int(interactive_item[0])])
		var interactive = interactive_scene.instance()
		add_child(interactive)
		
		interactive.position.x = interactive_item[1]
		interactive.position.y = interactive_item[2]
		
		self.connect("reset_level", interactive, "on_reset_level")
	
	# Draw Adjustable tile layer
	for tile_area in level_data.adjustable_tiles:
		var tile_id = $Adjustables.get_tileset().find_tile_by_name(tile_area[0])
		for x in range(tile_area[1], tile_area[1] + tile_area[3]):
			for y in range(tile_area[2], tile_area[2] + tile_area[4]):
				$Adjustables.set_cell(x, y, tile_id)
	
	self.connect("reset_level", $Adjustables, "on_reset_level")
	
	# Draw Terrain tile layer
	for tile_area in level_data.terrain:
		var tile_id = $Terrain.get_tileset().find_tile_by_name(tile_area[0])
		for x in range(tile_area[1], tile_area[1] + tile_area[3]):
			for y in range(tile_area[2], tile_area[2] + tile_area[4]):
				$Terrain.set_cell(x, y, tile_id)
	
	# Fix autotiles
	$Terrain.update_bitmask_region()
	
	# Draw Decoration tile layer
	if level_data.has("decoration"):
		for tile_area in level_data.decoration:
			var tile_id = $Decoration.get_tileset().find_tile_by_name(tile_area[0])
			for x in range(tile_area[1], tile_area[1] + tile_area[3]):
				for y in range(tile_area[2], tile_area[2] + tile_area[4]):
					$Decoration.set_cell(x, y, tile_id)
	
	# Get Environmental Data
	if level_data.has("environment"):
		if level_data.environment.has("bg"):
			if global.secret_lightmode:
				$Background.texture = load("res://assets/bg/sky_blue.svg")
			elif global.secret_nightmode:
				$Background.texture = load("res://assets/bg/sky_night.svg")
			else:
				$Background.texture = load("res://assets/bg/" + level_data.environment.bg + ".svg")
			
			$MusicPlayer.stream = load("res://assets/music/" + level_data.environment.bg + ".mp3")
			if level_data.environment.bg == "sky_lava":
				$MusicPlayer.volume_db = -5
			else:
				$MusicPlayer.volume_db = -15
	
	if not global.mute_music:
		$MusicPlayer.play()

func load_level_from_file(level_filename):
	# Read the file to get data
	var level_file = File.new()
	level_file.open(level_filename, File.READ)
	var level_data = JSON.parse(level_file.get_as_text()).result
	level_file.close()
	
	load_level(level_data)



func _on_ReturnButton_pressed():
	global.to_level_select = true
	get_tree().change_scene("res://scenes/LevelMenu.tscn")

func on_toggle_music():
	if $MusicPlayer.playing:
		$MusicPlayer.stop()
	else:
		$MusicPlayer.play()



func _process(delta):
	# Time
	current_time = Time.get_ticks_msec() - initial_time
	var converted_current_time = global.convert_time(current_time)
	$UI/CurrentTime.text = global.format_converted_time(converted_current_time)

func _ready():
	# Load the level with the number that matches the correct file
	print("Loading Level ", global.level)
	$Audio.stream.loop = false
	if not global.mute_sfx:
		$Audio.play()
	
	global.connect("toggle_music", self, "on_toggle_music")
	
	if global.level_times[global.level - 1] > 0:
		var record_time = global.convert_time(global.level_times[global.level - 1])
		$UI/RecordTime.text = global.format_converted_time(record_time)
	
	load_level_from_file("res://levels/level_" + str(global.level) + ".json")
