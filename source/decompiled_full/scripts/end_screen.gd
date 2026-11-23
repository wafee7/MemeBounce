extends Control



const ROBOT: = preload("res://assets/sprites/shadow.png")
const ECHO_SHADER: = preload("res://shaders/echo.gdshader")
const MAX_ECHOES: = 14
const FLOOR_Y: = 132.0
const MEME_Y: = 100.0

var _echoes: Array[Sprite2D] = []
var _robot: Sprite2D
var _memes: Array[Sprite2D] = []
var _t: = 0.0

@onready var line1: Label = $Line1
@onready var line2: Label = $Line2
@onready var stats: Label = $Stats
@onready var hearts: CPUParticles2D = $Hearts
@onready var menu_btn: Button = $Menu


func _ready() -> void :
	$Background.setup_random(Vector2(320, 180))
	$Floor.color = TileLayer.SILHOUETTE
	$FloorEdge.color = TileLayer.RIM
	$Title.text = "MEMEBOUNCE"
	var sub: = Label.new()
	sub.text = "THANKS FOR PLAYING MEMEBOUNCE!"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, 34)
	sub.size = Vector2(320, 8)
	sub.modulate = Color("#fde047")
	add_child(sub)
	var falls: = Game.failures
	stats.text = "FALLS: %d   (SKILL ISSUE COUNTER)" % falls
	for l in [line1, line2]:
		l.visible_ratio = 0.0
	stats.modulate.a = 0.0
	menu_btn.modulate.a = 0.0
	menu_btn.pressed.connect( func() -> void :
		Game.sfx("select")
		Game.to_main_menu())

	_robot = _make_robot(false)
	_robot.position = Vector2(250, FLOOR_Y)

	for i in Hud.MEMES.size():
		var m: = Sprite2D.new()
		m.texture = Hud.MEMES[i]
		m.scale = Vector2.ZERO
		m.position = Vector2(60 + i * 40, MEME_Y)
		add_child(m)
		_memes.append(m)
	var shown: = mini(falls, MAX_ECHOES)
	for i in shown:
		var e: = _make_robot(true)
		e.position = Vector2(232 - i * 14, FLOOR_Y)
		e.visible = false
		_echoes.append(e)

	var tw: = create_tween()
	tw.tween_interval(0.5)
	for i in shown:
		tw.tween_callback( func() -> void :
			_echoes[i].visible = true
			Game.sfx("select", -10.0 + i * 0.3, 0.0))
		tw.tween_interval(0.12)
	tw.tween_interval(0.2)
	for i in _memes.size():
		tw.tween_callback( func() -> void :
			var pop: = create_tween()
			pop.tween_property(_memes[i], "scale", Vector2(0.5, 0.5), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			Game.sfx(Flyer.voice_slot(_memes[i].texture, "flyer_chatter" if i % 2 == 0 else "flyer_pop"), -6.0, 0.25))
		tw.tween_interval(0.18)
	tw.tween_interval(0.2)
	tw.tween_property(line1, "visible_ratio", 1.0, 1.0)
	tw.tween_interval(0.4)
	tw.tween_callback( func() -> void :
		Game.sfx("complete")
		hearts.emitting = true
		_robot.frame = 16)
	tw.tween_property(line2, "visible_ratio", 1.0, 1.0)
	tw.tween_property(stats, "modulate:a", 1.0, 0.4)
	tw.tween_property(menu_btn, "modulate:a", 1.0, 0.3)
	tw.tween_callback(menu_btn.grab_focus)
	menu_btn.grab_focus()


func _make_robot(is_echo: bool) -> Sprite2D:
	var s: = Sprite2D.new()
	var char_tex: = Game.get_character_texture(Game.current_character) if Game else null
	s.texture = char_tex if char_tex else ROBOT
	s.hframes = 8
	s.vframes = 4
	s.offset = Vector2(0, -8)
	if not is_echo:
		s.material = null
	if is_echo:
		var m: = ShaderMaterial.new()
		m.shader = ECHO_SHADER
		m.set_shader_parameter("alpha", 0.6)
		s.material = m
	add_child(s)
	return s


func _process(delta: float) -> void :
	_t += delta

	for i in _echoes.size():
		_echoes[i].frame = [0, 1, 2, 1][int(_t * 5.0 + i) % 4]
	_robot.frame = [0, 1, 2, 1][int(_t * 5.0) % 4]
	for i in _memes.size():
		_memes[i].position.y = MEME_Y - absf(sin(_t * 5.0 + i * 0.9)) * 6.0
		_memes[i].rotation = sin(_t * 3.0 + i) * 0.12
