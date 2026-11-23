class_name Player
extends CharacterBody2D

signal landed(impact: float)
signal jumped

const RUN_SPEED: = 92.0
const ACCEL: = 1000.0
const DECEL: = 1400.0
const AIR_ACCEL: = 800.0
const AIR_DECEL: = 520.0
const JUMP_VELOCITY: = -270.0
const GRAVITY_UP: = 620.0
const GRAVITY_DOWN: = 960.0
const MAX_FALL: = 300.0
const JUMP_CUT: = 0.5
const COYOTE_TICKS: = 6
const BUFFER_TICKS: = 7
const HEAVY_LANDING: = 285.0
const BOUNCE_VELOCITY: = -350.0


const HITBOX: = Rect2(-3, -11, 6, 10)


const ANIMS: = {
	"idle": {"frames": [0, 1, 2, 1, 0, 3], "fps": 5.0}, 
	"run": {"frames": [8, 9, 10, 11, 12, 13], "fps": 12.0}, 
	"jump": {"frames": [16, 17], "fps": 10.0}, 
	"fall": {"frames": [18, 19], "fps": 8.0}, 
	"dead": {"frames": [24, 25, 26, 27, 28, 29], "fps": 14.0}, 
}

enum State{FROZEN, ACTIVE, DEAD}

var state: = State.FROZEN
var facing: = 1


var input_override = null
var fx_parent: Node2D

var _coyote: = 0
var _buffer: = 0
var _bounced: = false
var _was_on_floor: = true
var _anim: = "idle"
var _anim_time: = 0.0
var _trail_tick: = 0
var _flash: = 0.0

var char_id: String = "froggy"
var current_run_speed: float = RUN_SPEED
var current_jump_velocity: float = JUMP_VELOCITY
var current_gravity_down: float = GRAVITY_DOWN
var current_bounce_vel: float = BOUNCE_VELOCITY
var can_double_jump: bool = false
var has_double_jumped: bool = false
var can_dash: bool = false
var dash_timer: float = 0.0
var can_wall_jump: bool = false

@onready var visual: Node2D = $Visual
@onready var sprite: Sprite2D = $Visual / Sprite
@onready var dust: CPUParticles2D = $Dust


func _ready() -> void :
	_update_character_sprite()


func _update_character_sprite() -> void :
	char_id = Game.current_character if Game else "froggy"
	var tex: = Game.get_character_texture(char_id) if Game else null
	if tex:
		sprite.texture = tex
		sprite.hframes = 8
		sprite.vframes = 4
		sprite.position = Vector2(0, -8)
		if sprite.material is ShaderMaterial:
			(sprite.material as ShaderMaterial).set_shader_parameter("frame_size", Vector2(16, 16))

	# Assign unique character powers
	current_run_speed = RUN_SPEED
	current_jump_velocity = JUMP_VELOCITY
	current_gravity_down = GRAVITY_DOWN
	current_bounce_vel = BOUNCE_VELOCITY
	can_double_jump = false
	can_dash = false
	can_wall_jump = false

	match char_id:
		"froggy":
			current_jump_velocity = -310.0 # +15% High Jump
		"bunny":
			current_run_speed = 122.0 # +32% Super Speed
		"mushroom":
			current_gravity_down = 620.0 # Floaty Spore Fall
			current_run_speed = 96.0
		"detective":
			current_run_speed = 96.0 # Coin Magnet & 2x Coins handled in Coin
		"knight":
			current_bounce_vel = -430.0 # Titan Stomp Super Bounce
		"marine":
			can_double_jump = true # Jetpack Air Jump
		"heroine":
			can_dash = true # Air Dash on Shift
		"lizard":
			can_wall_jump = true # Wall Slide & Wall Kick


func _physics_process(delta: float) -> void :
	if state == State.ACTIVE:
		_move(delta)
	_animate(delta)
	visual.scale = visual.scale.lerp(Vector2.ONE, 1.0 - exp(-14.0 * delta))
	if _flash > 0.0:
		_flash = max(_flash - delta * 4.0, 0.0)
		(sprite.material as ShaderMaterial).set_shader_parameter("flash", _flash)


func _read_input() -> Dictionary:
	if input_override != null:
		return input_override
	return {
		"x": Input.get_axis("move_left", "move_right"), 
		"jump_pressed": Input.is_action_just_pressed("jump"), 
		"jump_held": Input.is_action_pressed("jump"), 
		"jump_released": Input.is_action_just_released("jump"), 
	}


func _move(delta: float) -> void :
	var inp: = _read_input()
	var dir: float = signf(inp.x) if absf(inp.x) > 0.2 else 0.0
	var on_floor: = is_on_floor()

	var rate: float
	if dir != 0.0:
		rate = ACCEL if on_floor else AIR_ACCEL
		facing = int(dir)
	else:
		rate = DECEL if on_floor else AIR_DECEL
	velocity.x = move_toward(velocity.x, dir * current_run_speed, rate * delta)

	if on_floor:
		_coyote = COYOTE_TICKS
		has_double_jumped = false
		if velocity.y >= 0.0:
			_bounced = false
	else:
		_coyote = max(_coyote - 1, 0)
	if inp.jump_pressed:
		_buffer = BUFFER_TICKS
	else:
		_buffer = max(_buffer - 1, 0)

	if _buffer > 0 and _coyote > 0:
		velocity.y = current_jump_velocity
		_buffer = 0
		_coyote = 0
		squash(Vector2(0.7, 1.35))
		Game.sfx("jump", -2.0)
		jumped.emit()
	elif can_double_jump and not on_floor and not has_double_jumped and inp.jump_pressed and _coyote == 0:
		velocity.y = current_jump_velocity * 0.95
		has_double_jumped = true
		squash(Vector2(0.65, 1.4))
		if Game:
			Game.sfx("jump", 2.0)
		dust.restart()
		dust.emitting = true

	# Heroine Air Dash
	if dash_timer > 0.0:
		dash_timer -= delta
	elif can_dash and (Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_C)):
		dash_timer = 0.5
		velocity.x = facing * 240.0
		velocity.y = -30.0
		squash(Vector2(1.5, 0.6))
		if Game:
			Game.sfx("bounce", 0.0)
		dust.restart()
		dust.emitting = true

	# Lizard Wall Slide & Kick
	if can_wall_jump and is_on_wall() and not on_floor and velocity.y > 0.0:
		velocity.y = minf(velocity.y, 45.0)
		if inp.jump_pressed:
			var wall_n = get_wall_normal()
			velocity.x = wall_n.x * current_run_speed * 1.35
			velocity.y = current_jump_velocity * 0.95
			facing = int(wall_n.x)
			if Game:
				Game.sfx("jump", 1.0)

	if inp.jump_released and velocity.y < 0.0 and not _bounced:
		velocity.y *= JUMP_CUT

	var g: = GRAVITY_UP if (velocity.y < 0.0 and (inp.jump_held or _bounced)) else current_gravity_down
	velocity.y = minf(velocity.y + g * delta, MAX_FALL)

	var fall_speed: = velocity.y
	move_and_slide()

	if is_on_floor() and not _was_on_floor:
		_on_land(fall_speed)
	_was_on_floor = is_on_floor()


	_trail_tick += 1
	if velocity.length() > 150.0 and _trail_tick % 3 == 0:
		_spawn_afterimage()


func _on_land(impact: float) -> void :
	var k: = clampf(impact / MAX_FALL, 0.2, 1.0)
	squash(Vector2(1.0 + 0.45 * k, 1.0 - 0.4 * k))
	dust.amount = 6 + int(6 * k)
	dust.restart()
	dust.emitting = true

	if impact > HEAVY_LANDING:
		Game.sfx("land", -4.0, 0.0)
	landed.emit(impact)


func squash(s: Vector2) -> void :
	visual.scale = s


func bounce(launch: float = -9999.0) -> void :
	velocity.y = current_bounce_vel if launch == -9999.0 else launch
	_bounced = true
	_coyote = 0
	_buffer = 0
	squash(Vector2(0.55, 1.55))


func hitbox() -> Rect2:
	return Rect2(position + HITBOX.position, HITBOX.size)



func anim_code() -> int:
	return sprite.frame | ((1 if sprite.flip_h else 0) << 8)


func die() -> void :
	state = State.DEAD
	velocity = Vector2.ZERO
	_set_anim("dead")
	_flash = 1.0
	squash(Vector2(1.4, 0.7))


func respawn(at: Vector2) -> void :
	position = at
	velocity = Vector2.ZERO
	state = State.FROZEN
	facing = 1
	_was_on_floor = true
	_bounced = false
	_coyote = 0
	_buffer = 0
	_set_anim("idle")
	visual.scale = Vector2(0.1, 2.2)
	_flash = 1.0
	(sprite.material as ShaderMaterial).set_shader_parameter("flash_color", Color("#22d3ee"))


func activate() -> void :
	state = State.ACTIVE
	(sprite.material as ShaderMaterial).set_shader_parameter("flash_color", Color.WHITE)


func _set_anim(a: String) -> void :
	if _anim != a:
		_anim = a
		_anim_time = 0.0


func _animate(delta: float) -> void :
	if state != State.DEAD:
		if state == State.FROZEN or is_on_floor():
			_set_anim("run" if absf(velocity.x) > 12.0 else "idle")
		else:
			_set_anim("jump" if velocity.y < 0.0 else "fall")
	_anim_time += delta
	var data: Dictionary = ANIMS[_anim]
	var frames: Array = data.frames
	var idx: = int(_anim_time * data.fps)
	if _anim == "dead":
		idx = mini(idx, frames.size() - 1)
		sprite.visible = _anim_time < 0.6
	else:
		idx %= frames.size()
		sprite.visible = true
	sprite.frame = frames[idx]
	sprite.flip_h = facing < 0


func _spawn_afterimage() -> void :
	if fx_parent == null:
		return
	var ghost: = Sprite2D.new()
	ghost.texture = sprite.texture
	ghost.hframes = sprite.hframes
	ghost.vframes = sprite.vframes
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h
	ghost.position = position + sprite.position
	ghost.modulate = Color(0, 0, 0, 0.4)
	fx_parent.add_child(ghost)
	var tw: = ghost.create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, 0.22)
	tw.tween_callback(ghost.queue_free)
