# Проигрыватель, который не зависит от значения time_scale
# Принцип работы: так как time_scale (в отличие от paused) не влияет на работу методов, а лишь изменяет внутренние часы, то эмулировать нормальное течение времени можно с помощью встроенного таймера get_ticks_msec()
# Реализован только метод play(), остальные можно добавить самостоятельно по его шаблону
extends AnimationPlayer

class_name TimelessAnimationPlayer

var last_time: int

func _ready() -> void:
	playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_MANUAL	# ручное управление воспроизведением
	set_process(false)

# в данном случае эта функция эмулирует внутренние часы во время воспроизведения анимации
func _process(delta: float) -> void:
	if not is_playing():	# если никакая анимация не проигрывается
		set_process(false)	# для экономии ресурсов
	var current_time = OS.get_ticks_msec()
	.advance((current_time - last_time) / 1000.0)	# проигрывание анимации прошедшего отрезка времени
	last_time = current_time

func play(name: String = "", custom_blend: float = -1, custom_speed: float = 1.0, from_end: bool = false) -> void:
	last_time = OS.get_ticks_msec()
	.play(name, custom_blend, custom_speed, from_end)
	set_process(true)	# запускаем эмуляцию внутренних часов