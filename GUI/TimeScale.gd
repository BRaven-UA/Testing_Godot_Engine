extends NinePatchRect

onready var slider = $MarginContainer/VSlider
onready var label = $MarginContainer/VSlider/Label
var scale = 1

func _ready():
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