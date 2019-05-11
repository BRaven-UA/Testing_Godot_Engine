extends NinePatchRect

onready var main_node = get_tree().current_scene
onready var user_layer = main_node.find_node("UserLayer")
onready var button	# ссылка на основную кнопку, которая показывает/скрывает этот узел
onready var slider = $MarginContainer/VSlider
onready var label = $MarginContainer/VSlider/Label
var scale = 1

func _ready():
	user_layer.call_deferred("create_button", self, Preloader.get_resource("timer icon") \
			, "", Vector2(0, get_viewport_rect().size.y - user_layer.default_size))
	refresh()

func _on_VSlider_value_changed(value):
	match value:
		15.0: scale = 100.0
		14.0: scale = 10.0
		13.0: scale = 5.0
		12.0: scale = 3.0
		11.0: scale = 1.5
		_: scale = value / 10.0
	refresh()

func refresh():
	Engine.time_scale = scale
	if scale:	# нулевое значение вызывает ошибку
		AudioServer.get_bus_effect(0, 0).pitch_scale = scale	# заменить хардкод на поиск эффекта
	label.text = "x" + str(scale)

func toggle() -> void:
	visible = !visible
	if visible:
		rect_position = button.rect_position + Vector2((button.rect_size.x - rect_size.x) / 2, 2 - rect_size.y)

func pause() -> bool:	# триггерит режим паузы игры, возвращает текущее состояние паузы
	var state = !get_tree().paused
	get_tree().paused = state
	return state