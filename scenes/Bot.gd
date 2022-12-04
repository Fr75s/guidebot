extends KinematicBody2D

export var run_speed = 6000
export var jump_height = 450
export var flip = false

signal reset_bot
signal bot_finished

onready var global = get_node("/root/Global")
var velocity = Vector2()

var initial_x
var initial_y

var finished = false
var finished_alpha_time = 30
var finished_alpha_elapsed = 0
var finished_alpha = false

var x_flip = false
var moving = false
var disable_physics = false

var consecutive_wall_flips = 0

var screen_size

func _ready():
	$BotSprites.flip_h = flip
	screen_size = get_viewport_rect().size
	x_flip = flip
	
	initial_x = position.x
	initial_y = position.y

func _on_Bot_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton) and (event.pressed) and (event.button_index == BUTTON_LEFT):
		if not moving:
			$BotSprites.animation = "walking"
			$BotAudio.stream = load("res://assets/audio/bot_startup.ogg")
			$BotAudio.stream.loop = false
			if not global.mute_sfx:
				$BotAudio.play()
			moving = true

func set_flip():
	$BotSprites.flip_h = flip
	x_flip = flip
	

func reset_bot(emit):
	position.x = initial_x
	position.y = initial_y
	
	velocity = Vector2.ZERO
	
	set_flip()
	
	$BotSprites.animation = "stationary"
	moving = false
	
	finished = false
	finished_alpha = false
	finished_alpha_elapsed = 0
	$BotSprites.playing = true
	modulate.a = 1
	
	if emit:
		emit_signal("reset_bot")

func set_physics(disable):
	disable_physics = disable
	$BotCollision.disabled = disable
	$BotCenter/BotCenterCollision.disabled = disable

func bot_finished():
	$BotSprites.playing = false
	$BotSprites.frame = 0
	
	$BotAudio.stream = load("res://assets/audio/bot_finish.ogg")
	$BotAudio.stream.loop = false
	if not global.mute_sfx:
		$BotAudio.play()
	
	moving = false
	finished = true

func _process(delta):
	$BotSprites.flip_h = x_flip
	
	if finished and not finished_alpha:
		set_physics(true)
		modulate.a = ((finished_alpha_time - finished_alpha_elapsed) * 1.0 / finished_alpha_time)
		finished_alpha_elapsed += 1
		if finished_alpha_elapsed > finished_alpha_time:
			finished_alpha = true
			emit_signal("bot_finished")
			#queue_free()
	elif (not finished) and (not finished_alpha):
		set_physics(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Gravity
	velocity.y += global.gravity * delta
	if velocity.y > 30000 * delta:
		velocity.y = 30000 * delta
	
	# Walk
	if moving:
		velocity.x = (run_speed * -1 * delta) if x_flip else (run_speed * delta)
	else:
		velocity.x = 0
	
	# Move
	if not disable_physics:
		velocity = move_and_slide(velocity, Vector2(0, -1))
	
	# Jump if one-tile wall ahead
	if is_on_floor():
		var wall_hop_check_ahead = 24
		var wall_check = move_and_collide(Vector2(-wall_hop_check_ahead if x_flip else wall_hop_check_ahead, -2), true, true, true)
		if wall_check and wall_check.collider.name in ["Terrain", "Adjustables"]:
			var short_wall = move_and_collide(Vector2(-wall_hop_check_ahead if x_flip else wall_hop_check_ahead, -72), true, true, true)
			if wall_check and (not short_wall or short_wall.collider.name == "Decoration"):
				# Do a little hop
				$BotAudio.stream = load("res://assets/audio/bot_jump.ogg")
				$BotAudio.stream.loop = false
				if not global.mute_sfx:
					$BotAudio.play()
				velocity.y = -jump_height
	
	# Move other way on wall collision
	if is_on_wall() or (position.x < 0 or position.x > screen_size.x):
		if consecutive_wall_flips < 1:
			x_flip = not x_flip
		consecutive_wall_flips += 1
	else:
		consecutive_wall_flips = 0
	
	if consecutive_wall_flips > 2:
		# Die, because you're stuck in a wall
		reset_bot(true)
	
	if position.y > screen_size.y + 100:
		reset_bot(true)
