extends AnimatedSprite

func _on_Flame_animation_finished() -> void:
	queue_free()