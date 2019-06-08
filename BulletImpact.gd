extends Node2D

var collider: Node2D
var soft_body: bool

func _ready() -> void:
	if collider.collision_layer & 6:	# игрок или NPC
		soft_body = true
	var impact
	impact = $FleshImpact if soft_body else $SolidImpact
	impact.emitting = true
	$Timer.wait_time = max(0.25, impact.lifetime / impact.speed_scale)	# по умолчанию берем продолжительность звука

func _on_Timer_timeout() -> void:
	if soft_body:
		var blood = Preloader.get_resource("BloodSpot").instance()
		blood.position = global_position
		blood.rotation = global_rotation
		get_tree().current_scene.find_node("Floor").add_child(blood, true)
	queue_free()