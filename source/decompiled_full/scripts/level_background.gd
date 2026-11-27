class_name LevelBackground
extends Node2D

const FAR: = preload("res://assets/sprites/bg_far.png")
const MID: = preload("res://assets/sprites/bg_mid.png")

const CITY_DIR: = "res://assets/sprites/free-city-backgrounds-pixel-art/city %d/%d.png"
const CITY_LAYERS: = {
	1: [1, 2, 3, 4, 5], 2: [1, 2, 3, 4, 5, 6], 3: [1, 2, 3, 4, 5], 4: [1, 2, 3, 4, 5, 7], 
	5: [1, 2, 3, 4, 5], 6: [1, 2, 3, 4, 5, 6], 7: [1, 2, 3, 4, 5], 8: [1, 2, 3, 4, 5], 
}
const CITY_SIZE: = Vector2(576, 324)

const SKY_SCROLL: = 0.04
const NEAR_SCROLL: = 0.5
const CITY_TINT: = Color(0.45, 0.45, 0.55)

@export var autoscroll_speed: = 0.0


static func has_city(city: int) -> bool:
	return CITY_LAYERS.has(city)


static func get_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
	return null


func setup_random(level_size: Vector2, seed_num: int = -1) -> void :
	for c in get_children():
		remove_child(c)
		c.queue_free()
	
	var choice: int
	if seed_num >= 0:
		choice = seed_num % 4
	else:
		choice = randi() % 4
	
	match choice:
		0:
			setup_stringstar(level_size)
		1:
			setup_dawn(level_size)
		2:
			setup_space(level_size)
		3:
			var city_id: = 1 + (randi() % 8)
			setup_city(city_id, level_size)


func setup_stringstar(level_size: Vector2) -> void :
	modulate = Color.WHITE
	for i in 3:
		var par: = Parallax2D.new()
		var t: = float(i) / 2.0
		par.scroll_scale = Vector2(lerpf(0.04, 0.45, t), 1.0)
		par.repeat_size = Vector2(288, 0)
		par.repeat_times = 4
		par.autoscroll = Vector2(-autoscroll_speed * (0.2 + 0.3 * t), 0)
		var spr: = Sprite2D.new()
		spr.texture = get_tex("res://assets/sprites/backgrounds/stringstar/background_%d.png" % i)
		if spr.texture:
			spr.centered = false
			spr.position = Vector2(0, level_size.y - 180.0)
			par.add_child(spr)
			add_child(par)


func setup_dawn(level_size: Vector2) -> void :
	modulate = Color.WHITE
	var s: = 180.0 / 1080.0
	for i in range(1, 9):
		var par: = Parallax2D.new()
		var t: = float(i - 1) / 7.0
		par.scroll_scale = Vector2(lerpf(0.02, 0.42, t), 1.0)
		par.repeat_size = Vector2(330, 0)
		par.repeat_times = 4
		par.autoscroll = Vector2(-autoscroll_speed * (0.1 + 0.3 * t), 0)
		var spr: = Sprite2D.new()
		spr.texture = get_tex("res://assets/sprites/backgrounds/The Dawn/Layers/%d.png" % i)
		if spr.texture:
			spr.centered = false
			spr.scale = Vector2(s, s)
			spr.position = Vector2(0, level_size.y - 180.0)
			par.add_child(spr)
			add_child(par)


func setup_space(level_size: Vector2) -> void :
	modulate = Color(0.85, 0.9, 1.0)
	var par: = Parallax2D.new()
	par.scroll_scale = Vector2(0.06, 0.06)
	par.repeat_size = Vector2(200, 200)
	par.repeat_times = 6
	par.autoscroll = Vector2(-4.0, -1.5)
	var spr: = Sprite2D.new()
	spr.texture = get_tex("res://assets/sprites/backgrounds/space.png")
	if spr.texture:
		spr.centered = false
		par.add_child(spr)
		add_child(par)


func setup_city(city: int, level_size: Vector2) -> void :
	var layers: Array = CITY_LAYERS[city]
	modulate = CITY_TINT
	for i in layers.size():
		var par: = Parallax2D.new()
		var t: = float(i) / maxf(layers.size() - 1, 1.0)
		par.scroll_scale = Vector2(lerpf(SKY_SCROLL, NEAR_SCROLL, t), 1.0)
		par.repeat_size = Vector2(CITY_SIZE.x, 0)
		par.repeat_times = 3
		par.autoscroll = Vector2(-autoscroll_speed * t, 0)
		var spr: = Sprite2D.new()
		spr.texture = get_tex(CITY_DIR % [city, layers[i]])
		if spr.texture:
			spr.centered = false
			spr.position = Vector2(0, level_size.y - CITY_SIZE.y)
			par.add_child(spr)
			add_child(par)


func setup(level_size: Vector2) -> void :
	setup_random(level_size)
