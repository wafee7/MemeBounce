class_name TileLayer
extends Node2D





const TILE: = 8
const SILHOUETTE: = Color.BLACK
const RIM: = Color("#a5f3fc")
const DANGER: = Color("#f472b6")


const FIGHTER_GLOW: = Color(0.647, 0.953, 0.988, 0.35)

var _solids: Array = []
var _platforms: Array = []
var _spikes: Array = []




static func silhouette_material() -> ShaderMaterial:
	var m: = ShaderMaterial.new()
	m.shader = preload("res://shaders/flash.gdshader")
	m.set_shader_parameter("base_tint", Color.WHITE)
	m.set_shader_parameter("outline_color", FIGHTER_GLOW)
	m.set_shader_parameter("frame_size", Vector2(16, 16))
	return m



func add_solid(at: Vector2, mask: int) -> void :
	_solids.append([at, mask])


func add_platform(at: Vector2) -> void :
	_platforms.append([at])


func add_spike(at: Vector2, points_up: bool) -> void :
	_spikes.append([at, points_up])


func _draw() -> void :
	for s in _solids:
		var at: Vector2 = s[0]
		var mask: int = s[1]
		draw_rect(Rect2(at, Vector2(TILE, TILE)), SILHOUETTE)
		if mask & 1:
			draw_rect(Rect2(at, Vector2(TILE, 1)), RIM)
		if mask & 2:
			draw_rect(Rect2(at + Vector2(TILE - 1, 0), Vector2(1, TILE)), RIM)
		if mask & 4:
			draw_rect(Rect2(at + Vector2(0, TILE - 1), Vector2(TILE, 1)), RIM)
		if mask & 8:
			draw_rect(Rect2(at, Vector2(1, TILE)), RIM)
	for p in _platforms:
		var at: Vector2 = p[0]
		draw_rect(Rect2(at, Vector2(TILE, 3)), SILHOUETTE)
		draw_rect(Rect2(at, Vector2(TILE, 1)), RIM)
	for s in _spikes:
		var at: Vector2 = s[0]
		var pts: PackedVector2Array
		if s[1]:
			pts = PackedVector2Array([at + Vector2(0.5, 8), at + Vector2(4, 1), at + Vector2(7.5, 8)])
		else:
			pts = PackedVector2Array([at + Vector2(0.5, 0), at + Vector2(4, 7), at + Vector2(7.5, 0)])
		draw_colored_polygon(pts, SILHOUETTE)
		draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[0]]), DANGER, 1.0)
