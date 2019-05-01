tool
extends EditorScript

func _run():
	var t = load("res://tileset/Splatter_textures2.tres")
#	o.polygon = PoolVector2Array()
#	var nm = load("res://tileset/Tex_0002_Frame_000.PNG")
	for i in 2336:#t.get_tiles_ids():
#		t.tile_set_normal_map(i, nm)
#		print (i)
#		print(t.tile_get_normal_map(i))
	#	var i = t.find_tile_by_name("crate_1")
	#	print(i)
		var s = t.tile_get_shape(i, 0)
	#	print(s)
		if s:
			if s is ConvexPolygonShape2D:
				var o = OccluderPolygon2D.new()
				o.polygon = s.points
		#		print(s.points)
				t.tile_set_light_occluder(i, o)
	print("Done")