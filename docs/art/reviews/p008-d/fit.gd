extends SceneTree
func _init() -> void:
	var token: CreatureToken = CreatureToken.new()
	var records: Array[Dictionary] = []
	for value: int in [0,1,2,3,6,8,10,12,14,99,100]:
		var fit: Vector3 = token.get_primary_fit(value)
		records.append({"value":value,"fitted_points":fit.x,"horizontal_scale":fit.y,"bounding_radius_including_margin":fit.z,"physical_points_720p":fit.x*154.0/1536.0*2.0/3.0})
	var file: FileAccess = FileAccess.open("res://docs/art/reviews/p008-d/font_fit.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(records,"  "))
	token.free()
	quit()
