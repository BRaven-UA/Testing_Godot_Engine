extends Node2D

export(int) var MIN_LOC_WIDHT; export(int) var MIN_LOC_HEIGHT #минимальные размеры локации
export(int) var MAX_LOC_WIDHT; export(int) var MAX_LOC_HEIGHT #максимальные размеры локации

var loc_width
var loc_height


func _ready():
	randomize()
	loc_width = MAX_LOC_WIDHT # MIN_LOC_WIDHT + randi() % MAX_LOC_WIDHT
	loc_height = MAX_LOC_HEIGHT # MIN_LOC_HEIGHT + randi() % MAX_LOC_HEIGHT
	$Edge/CollisionPolygon2D.polygon = [Vector2(), Vector2(loc_width, 0), Vector2(loc_width, loc_height), Vector2(0, loc_height)]
	$Edge/CollisionPolygon2D/Floor.polygon = $Edge/CollisionPolygon2D.polygon
	$Edge/CollisionPolygon2D/Floor.texture.flags = 6
	$Edge/CollisionPolygon2D/Outside.polygon = $Edge/CollisionPolygon2D.polygon
	$Edge/CollisionPolygon2D/Outside.texture.flags = 6
	$Walls/W1/Polygon2D.polygon = $Walls/W1.polygon
	$Walls/W1/Polygon2D.texture.flags = 6
	$Walls/W2/Polygon2D.polygon = $Walls/W2.polygon
	$Walls/W2/Polygon2D.texture.flags = 6
	$Wall/CollisionPolygon2D/Line2D.texture.flags = 6
#	var loc_square = loc_width * loc_height
#	print("loc_square = ", loc_square)
#	var walls_square = round(loc_square / (2 + randi() % 4))
#	print("walls_square = ", walls_square)
#	var wall = "W1"
#	while walls_square > 100:
#		var cur_wall_square = 100 + randi() % walls_square - 101
#		var cur_wall_widht = 10 + randi() % 59
#		var total_joints = 1 + randi() % (cur_wall_square / cur_wall_widht) / 10 - 1
#		var cur_polygon = PoolVector2Array()
#		cur_polygon.append(Vector2(randi() % loc_width - 1, randi() % loc_height - 1))
#