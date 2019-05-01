extends Camera2D

var free_camera = false	# триггер свободной камеры

func _input(event):
	if event.is_action_pressed("zoom_in"):
		zoom += Vector2(.25,.25)
	if event.is_action_pressed("zoom_out"):
		if zoom < Vector2(.5, .5):
			zoom = Vector2(.25, .25)
		else:
			zoom -= Vector2(.25,.25)
	if event.is_action_pressed("camera_center"):
#		offset = Vector2()
		$AnimationPlayer.play("Center")
	if event.is_action_pressed("camera_free"):
		free_camera = true		
	if event.is_action_released("camera_free"):
		free_camera = false
	if event is InputEventMouseMotion and free_camera:
		offset -= event.relative * 2 * zoom.length()