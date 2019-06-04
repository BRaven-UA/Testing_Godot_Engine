extends CanvasLayer

onready var main_node = get_tree().current_scene
onready var selection = main_node.find_node("Player")

#func _ready():
#	$Grid.visible = true

func _process(delta):
	if !selection:
		selection = main_node.find_node("Player")
	if Input.is_action_just_pressed("pause"):
		$Grid/CheckButton.emit_signal("toggled", false)
	if Input.is_action_just_released("pause"):
		$Grid/CheckButton.emit_signal("toggled", true)
	$Grid/Label.text = "Mouse global pos: " + str(main_node.get_global_mouse_position().floor())
	$Grid/Label2.text = selection.name + " mouse local pos: " + str(selection.get_local_mouse_position().floor())

func _input(event):
	if event is InputEventKey:
		if event.scancode == 96 and event.pressed:
			$Grid.visible = !$Grid.visible
			get_tree().set_input_as_handled()
	if event.is_action_pressed("ui_cancel") and $Load_dialog.visible:
		$Load_dialog.visible = false
		get_tree().set_input_as_handled()
	if event.is_action_pressed("debug_add_npc"):
		var npc = Preloader.get_resource("NPC").instance()
		npc.position = main_node.get_global_mouse_position()
		main_node.add_child_below_node(main_node.get_node("Player"), npc, true)
		get_tree().set_input_as_handled()
	
#	if event.is_action_pressed("test"):
#		var vs = VisualServer.directional_light_create()
#		print(vs.get_id())

func _on_CheckButton_toggled(button_pressed):
	if button_pressed:
		get_tree().paused = true
	else:
		get_tree().paused = false

func selection_changed(object):
	selection = object

func _on_Time_scale_value_changed(value):
	Global.time_scale = value
#	AudioServer.get_bus_effect(0, 0).pitch_scale = value	# заменить хардкод на поиск эффекта
#	$Grid/Time_scale/Label.text = "\nСкорость времени: " + str(floor($Grid/Time_scale.value * 100)) + "%"
	$Grid/Time_scale/Label.text = "\nСкорость времени: " + str(floor(value * 100)) + "%"

func _on_Save_game_pressed():
	Global.save_game()

func _on_Loading_List_item_selected(index):
	var filename = Global.save_dir + "/" + find_node("Loading_List").get_item_text(index) + ".png"
	find_node("Loading_Preview").texture = null
	if File.new().file_exists(filename):
		var image = Image.new()
		image.load(filename)
		var ratio = min(640.0 / image.get_width(), 480.0 / image.get_height())
		image.resize(image.get_width() * ratio, image.get_height() * ratio)
		var texture = ImageTexture.new()
		texture.create_from_image(image, 0)
		find_node("Loading_Preview").texture = texture

func _on_Load_game_pressed():
	var list = find_node("Loading_List")
	var preview = find_node("Loading_Preview")
	var dir = Directory.new()
	if !dir.change_dir(Global.save_dir):
		list.clear()
		preview.texture = null
		dir.list_dir_begin(true, true)
		var filename = dir.get_next()
		while filename:
			if filename.ends_with(".json"): list.add_item(filename.left(filename.length() - 5))
#			var file = File.new()
#			var error = file.open(save_dir + "/" + filename, file.READ)
#			if error: prints("ERROR loading file %s: " % filename, error)
#			else: game_data = JSON.parse(file.get_as_text()).result
#			file.close()
			filename = dir.get_next()
		find_node("Load_dialog").visible = true

func _on_Button_Cancel_pressed():
	find_node("Load_dialog").visible = false

func _on_Button_Load_pressed():
	if !Global.load_game(find_node("Loading_List").get_item_text(find_node("Loading_List").get_selected_items()[0]) + ".json"):
		find_node("Load_dialog").visible = false

func _on_Debug_mode_toggled(button_pressed: bool) -> void:
	Global.debug_mode = button_pressed

func _on_AlwaysOnTop_toggled(button_pressed: bool) -> void:
	OS.set_window_always_on_top(button_pressed)

func _on_Freeze_NPC_toggled(button_pressed: bool) -> void:
	for npc in get_tree().get_nodes_in_group("NPC"):
		npc.set_process(!button_pressed)
