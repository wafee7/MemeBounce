class_name PressurePlate
extends Node2D





const COLORS: = [Color("#a78bfa"), Color("#60a5fa")]
const WIDTH: = 16.0

var channel: = 0
var pressed: = false

@onready var sparks: CPUParticles2D = $Sparks


func setup(p_channel: int) -> void :
	channel = p_channel


func _ready() -> void :
	sparks.color = COLORS[channel]


func _draw() -> void :
	var bar: = Rect2(3, -4, WIDTH - 6, 1) if pressed else Rect2(3, -6, WIDTH - 6, 3)
	draw_rect(bar, COLORS[channel])
	draw_rect(Rect2(0, -3, WIDTH, 3), TileLayer.SILHOUETTE)
	draw_rect(Rect2(0, -3, WIDTH, 1), TileLayer.RIM)
	draw_rect(Rect2(0, -3, 1, 3), TileLayer.RIM)
	draw_rect(Rect2(WIDTH - 1, -3, 1, 3), TileLayer.RIM)



func trigger_rect() -> Rect2:
	return Rect2(position + Vector2(1, -5), Vector2(14, 7))


func is_pressed_by(hitbox: Rect2) -> bool:
	var feet: = Rect2(hitbox.position.x, hitbox.end.y - 1, hitbox.size.x, 2)
	return trigger_rect().intersects(feet)


func set_pressed(p: bool) -> void :
	if p == pressed:
		return
	pressed = p
	queue_redraw()
	if p:
		sparks.restart()
		sparks.emitting = true
		Game.sfx("plate_on", -4.0)
	else:
		Game.sfx("plate_off", -8.0)
