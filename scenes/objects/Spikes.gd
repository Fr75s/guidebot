extends Area2D

func on_reset_level():
	pass

func _on_Spikes_body_entered(body):
	if "Bot" in body.name:
		body.reset_bot(true)
