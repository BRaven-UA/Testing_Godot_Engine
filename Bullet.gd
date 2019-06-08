extends KinematicBody2D

onready var main_node = get_tree().current_scene
var damage
var start_point = Vector2()

func _ready():
	start_point = global_position

func _physics_process(delta):
	var result = move_and_collide(Vector2(0, 2000).rotated(rotation) * delta)
	
	if result:	# было столкновение
		var collider = result.collider
		var impact = Preloader.get_resource("BulletImpact").instance()	# анимация и звук попадания
		impact.collider = collider
		impact.global_position = result.position
		impact.rotation = result.travel.bounce(result.normal).angle()	# направление берем как отскок от поверхности
		main_node.add_child(impact, true)
		if collider.has_method("taking_damage"):
			collider.taking_damage(damage, result.travel)
		queue_free()
	
	if (global_position - start_point).length() > 10000:	# чтобы не летала бесконечно
		queue_free()