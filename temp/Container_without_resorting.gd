extends HBoxContainer

func _notification(what: int) -> void:
	if (what==NOTIFICATION_SORT_CHILDREN):
		print("попытка сортировки")
		return