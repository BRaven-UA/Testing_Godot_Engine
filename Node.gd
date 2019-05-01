extends Node

#var ts = load("res://tileset/my_tileset.tres")
var ts = TileSet.new()

func _ready():
	ts.create_tile(0)
	ts.tile_set_texture(0, load("res://tiles/cem_g01brick01.png"))
	ts.create_tile(1)
	ts.tile_set_texture(1, load("res://tiles/mtl_g01basemetal03.png"))
	ts.create_tile(2)
	ts.tile_set_texture(2, load("res://tiles/rck_g01rockfloor01.png"))
	$Sprite1.texture = ts.tile_get_texture(0)
	$Sprite2.texture = ts.tile_get_texture(1)
	$Sprite3.texture = ts.tile_get_texture(2)