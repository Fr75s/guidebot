extends Area2D

onready var global = get_node("/root/Global")
var other_portal

var disable_portal = false

var initial_owner_check = false
var check_for_other_portal = true
var portal_blue

func on_reset_level():
	disable_portal = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if "Blue" in name:
		portal_blue = true
		$TelepadAudio.stream.loop = false

	if "Orange" in name:
		portal_blue = false
	
	self.connect("body_entered", self, "on_body_entered")
	self.connect("body_exited", self, "on_body_exited")

func on_body_entered(body):
	if "Bot" in body.name and not disable_portal:
		var diff_x = position.x - body.position.x
		var diff_y = position.y - body.position.y
		
		body.position.y = other_portal.position.y - diff_y
		body.position.x = other_portal.position.x
		
		if not global.mute_sfx:
			if portal_blue:
				$TelepadAudio.play()
			else:
				other_portal.get_node("TelepadAudio").play()
		
		other_portal.disable_portal = true

func on_body_exited(body):
	print(body)
	if "Bot" in body.name:
		disable_portal = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if check_for_other_portal:
		var level_nodes = get_node("/root/Level").get_children()
		
		for node in level_nodes:
			if portal_blue:
				if "TelepadOrange" in node.name:
					other_portal = node
					break
			if not portal_blue:
				if "TelepadBlue" in node.name:
					other_portal = node
					break
		
		#print(str(other_portal))
		
		check_for_other_portal = false
