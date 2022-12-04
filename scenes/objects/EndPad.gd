extends Area2D

func on_reset_level():
	pass

func _on_EndPad_area_entered(area):
	#print(area.name)
	if area.name == "BotCenter":
		area.owner.bot_finished()
