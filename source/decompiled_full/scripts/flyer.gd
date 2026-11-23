class_name Flyer
extends Node2D







const SKINS: Array[Texture2D] = [
	preload("res://assets/sprites/flyers/pixel-cat-meme-1.png"), 
	preload("res://assets/sprites/flyers/pixel-cat-meme-2.png"), 
	preload("res://assets/sprites/flyers/pixel-cat-meme-3.png"), 
	preload("res://assets/sprites/flyers/pixel-cat-meme-4.png"), 
	preload("res://assets/sprites/flyers/pixel-cat-meme-5.png"), 
	preload("res://assets/sprites/flyers/pixel-shiba-dog.png"), 
]

const CHATTER_MIN: = 45
const CHATTER_MAX: = 110


const SNORE_GAP_MIN: = 130
const SNORE_GAP_MAX: = 200




static func voice_slot(tex: Texture2D, default_slot: = "flyer_chatter") -> String:
	return "snore" if tex and tex.resource_path.get_file() == "pixel-cat-meme-3.png" else default_slot
const FRAME: = 16
const FRAME_TICKS: = 8

const HITBOX: = Rect2(-6, -5, 12, 10)

var spawn_tick: = 0
var start: = Vector2.ZERO
var speed: = 40.0
var bob: = 0.0
var popped: = false
var skin: = 0
var _next_chatter: = 0

@onready var sprite: Sprite2D = $Sprite
@onready var burst: CPUParticles2D = $Burst
@onready var voice: AudioStreamPlayer2D = $Voice


func _ready() -> void :
	voice.add_to_group("sfx_players")
	sprite.texture = SKINS[skin % SKINS.size()]
	sprite.hframes = maxi(1, sprite.texture.get_width() / FRAME)



func setup(p_spawn_tick: int, p_start: Vector2, p_speed: float, p_bob: float, id: = "") -> void :
	spawn_tick = p_spawn_tick
	start = p_start
	speed = p_speed
	bob = p_bob
	skin = absi(hash(id))



func pos_at(tick: int) -> Vector2:
	var t: = tick - spawn_tick
	return Vector2(start.x - speed * t / 60.0, start.y + bob * sin(t * 0.08))


func place(tick: int) -> void :
	position = pos_at(tick)

	if tick - spawn_tick >= _next_chatter:
		var slot: = voice_slot(sprite.texture)
		if slot == "snore":
			_next_chatter = tick - spawn_tick + randi_range(SNORE_GAP_MIN, SNORE_GAP_MAX)
			voice.pitch_scale = randf_range(0.9, 1.1)
		else:
			_next_chatter = tick - spawn_tick + randi_range(CHATTER_MIN, CHATTER_MAX)
			voice.pitch_scale = randf_range(0.8, 1.45)
		voice.stream = Game.pick(slot)
		voice.play()
	if sprite.hframes > 1:
		sprite.frame = ((tick - spawn_tick) / FRAME_TICKS) % sprite.hframes


func hitbox() -> Rect2:
	return Rect2(position + HITBOX.position, HITBOX.size)


func pop() -> void :
	popped = true
	sprite.visible = false
	voice.stop()
	burst.restart()
	burst.emitting = true
