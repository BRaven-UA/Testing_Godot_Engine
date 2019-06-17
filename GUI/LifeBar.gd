extends Control

onready var progress_bar = $ProgressBar
onready var background_bar = $BackgroundProgressBar
onready var tween = $BackgroundProgressBar/Tween
onready var values = $Values
onready var previous_value = progress_bar.value
var linked_object: Node2D

#func _ready() -> void:
#	progress_bar.max_value = linked_object.max_health
#	progress_bar.value = linked_object.health

func _process(delta):
	# корректируем положение на экране в реальном времени
	# запуском/остановкой процесса управляют события VisibilityNotifier2D у связанного объекта
	if linked_object:
		rect_global_position = linked_object.get_global_transform_with_canvas().origin - Vector2(20, 40)

func set_max_value(value) -> void:
	progress_bar.max_value = value
	background_bar.max_value = value
	set_value()

func set_value(value: int = progress_bar.value) -> void:
	previous_value = progress_bar.value
	progress_bar.value = value
	values.text = str(value) + '/' + str(progress_bar.max_value)
	background_bar.get("custom_styles/fg").bg_color = ColorN("Green") if value > previous_value else ColorN("Red")
	
	tween.stop_all()
	tween.interpolate_property(background_bar, "value", background_bar.value, value, 1.0, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()

func _on_ProgressBar_mouse_entered() -> void:
	values.visible = true

func _on_ProgressBar_mouse_exited() -> void:
	values.visible = false