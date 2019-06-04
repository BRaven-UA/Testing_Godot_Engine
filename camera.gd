extends Camera2D

var free_camera = false	# триггер свободной камеры

func _input(event):
	var handled: = false
	
	if event.is_action_pressed("zoom_in"):
		zoom += Vector2(.25,.25)
		handled = true
	if event.is_action_pressed("zoom_out"):
		if zoom < Vector2(.5, .5):
			zoom = Vector2(.25, .25)
		else:
			zoom -= Vector2(.25,.25)
		handled = true
	
	if event.is_action_pressed("camera_center"):
#		offset = Vector2()
		$TimelessAnimationPlayer.play("Center")
		handled = true
	
	if event.is_action_pressed("camera_free"):
		free_camera = true		
		handled = true
	if event.is_action_released("camera_free"):
		free_camera = false
	
	if event is InputEventMouseMotion and free_camera:
		offset -= event.relative * 2 * zoom.length()
		handled = true
	
	if handled:	# чтобы не писать в каждом условии
		get_tree().set_input_as_handled()