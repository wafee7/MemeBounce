extends Control

const FLYERS: = 6
const HOW_TO_PLAY_SCENE: GDScript = preload("res://scripts/how_to_play.gd")
const LEVEL_SELECT_SCENE: GDScript = preload("res://scripts/level_select.gd")

@onready var play_btn: Button = $Buttons/Play
@onready var levels_btn: Button = $Buttons/Levels
@onready var how_btn: Button = $Buttons/HowToPlay
@onready var quit_btn: Button = $Buttons/Quit

@onready var title: Label = $Title
@onready var title_ghost: Label = $TitleGhost
@onready var robot: Sprite2D = $Robot
@onready var echo_sprite: Sprite2D = $EchoSprite

var _t: = 0.0
var _glitch_t: = 0.0
var _title_x: = 0.0
var _flyers: Array[Sprite2D] = []
var _floor_memes: Array[Sprite2D] = []
var _chatter_t: = 2.0

# Coin counter UI
var _coin_spr: Sprite2D
var _coin_lbl: Label

# Character Carousel UI
var _selected_char_idx: int = 0
var _char_name_lbl: Label
var _char_perk_lbl: Label
var _char_preview: Sprite2D
var _char_action_btn: Button
var _char_status_lbl: Label
var _char_lock_icon: Sprite2D
var _lock_tex: Texture2D


static func get_lock_icon() -> Texture2D:
	var path: = "res://assets/sprites/lock.png"
	if FileAccess.file_exists(path):
		var img: = Image.load_from_file(path)
		if img:
			return ImageTexture.create_from_image(img)
	return null


func _ready() -> void :
	get_tree().paused = false
	if Game:
		Game.load_game()
		_selected_char_idx = Game.CHARACTERS.find(Game.current_character)
		if _selected_char_idx == -1:
			_selected_char_idx = 0

	_lock_tex = get_lock_icon()

	_update_bottom_sprites()
	robot.material = null
	title.text = "MEMEBOUNCE"
	title_ghost.text = "MEMEBOUNCE"
	_title_x = 70.0
	title.position.x = _title_x
	title_ghost.position.x = _title_x
	$Background.setup_random(Vector2(320, 180))
	$Floor.color = TileLayer.SILHOUETTE
	$FloorEdge.color = TileLayer.RIM
	
	_build_memes()
	_build_coin_badge()
	_build_character_showcase()

	play_btn.pressed.connect(_on_play)
	levels_btn.pressed.connect(_on_levels)
	how_btn.pressed.connect(_on_how_to_play)
	quit_btn.pressed.connect(_on_quit)

	quit_btn.visible = not OS.has_feature("web")
	play_btn.grab_focus()

	for btn: Button in [play_btn, levels_btn, how_btn, quit_btn]:
		btn.focus_entered.connect(func() -> void:
			if Game:
				Game.sfx("select", -8.0)
		)


func _update_bottom_sprites() -> void:
	var char_tex: Texture2D = Game.get_character_texture(Game.current_character) if Game else null
	if char_tex:
		robot.texture = char_tex
		echo_sprite.texture = char_tex


func _build_coin_badge() -> void:
	var badge: ColorRect = ColorRect.new()
	badge.color = Color(0.06, 0.09, 0.16, 0.9)
	badge.position = Vector2(244, 5)
	badge.size = Vector2(72, 16)
	add_child(badge)

	var border: ColorRect = ColorRect.new()
	border.position = Vector2(244, 5)
	border.size = Vector2(72, 1)
	border.color = Color(0.98, 0.86, 0.12, 0.8)
	add_child(border)

	_coin_spr = Sprite2D.new()
	var img: = Image.load_from_file("res://assets/sprites/coins/spr_coin_strip4.png")
	if img:
		_coin_spr.texture = ImageTexture.create_from_image(img)
	_coin_spr.hframes = 4
	_coin_spr.frame = 0
	_coin_spr.position = Vector2(253, 13)
	add_child(_coin_spr)

	_coin_lbl = Label.new()
	var c_count: int = Game.coins if Game else 0
	_coin_lbl.text = "x %d" % c_count
	_coin_lbl.position = Vector2(264, 7)
	_coin_lbl.size = Vector2(50, 12)
	_coin_lbl.add_theme_color_override("font_color", Color(0.98, 0.86, 0.12))
	add_child(_coin_lbl)


func _refresh_coin_badge() -> void:
	if _coin_lbl and Game:
		_coin_lbl.text = "x %d" % Game.coins


func _build_character_showcase() -> void:
	var card_x: = 36.0
	var card_y: = 42.0
	var card_w: = 248.0
	var card_h: = 60.0

	# 1. Outer Box (cyan border)
	var outer_box: ColorRect = ColorRect.new()
	outer_box.position = Vector2(card_x, card_y)
	outer_box.size = Vector2(card_w, card_h)
	outer_box.color = Color(0.13, 0.83, 0.93, 0.85)
	add_child(outer_box)

	var inner_box: ColorRect = ColorRect.new()
	inner_box.position = Vector2(1, 1)
	inner_box.size = Vector2(card_w - 2, card_h - 2)
	inner_box.color = Color(0.04, 0.06, 0.11, 0.96)
	outer_box.add_child(inner_box)

	# 2. Left Scroll Button [<]
	var prev_btn: Button = Button.new()
	prev_btn.text = "<"
	prev_btn.position = Vector2(3, 18)
	prev_btn.size = Vector2(18, 24)
	prev_btn.pressed.connect(_prev_character)
	prev_btn.focus_entered.connect(func() -> void: if Game: Game.sfx("select", -8.0))
	inner_box.add_child(prev_btn)

	# 3. Right Scroll Button [>]
	var next_btn: Button = Button.new()
	next_btn.text = ">"
	next_btn.position = Vector2(card_w - 21, 18)
	next_btn.size = Vector2(18, 24)
	next_btn.pressed.connect(_next_character)
	next_btn.focus_entered.connect(func() -> void: if Game: Game.sfx("select", -8.0))
	inner_box.add_child(next_btn)

	# 4. Preview Spotlight & Character Sprite (Left column, 2.6x scale = 42x42px, unblocked!)
	var spotlight: ColorRect = ColorRect.new()
	spotlight.position = Vector2(27, 8)
	spotlight.size = Vector2(46, 42)
	spotlight.color = Color(0.08, 0.12, 0.22, 0.7)
	inner_box.add_child(spotlight)

	_char_preview = Sprite2D.new()
	_char_preview.position = Vector2(50, 29)
	_char_preview.scale = Vector2(2.6, 2.6)
	_char_preview.hframes = 8
	_char_preview.vframes = 4
	_char_preview.frame = 8
	inner_box.add_child(_char_preview)

	# 5. Right Column: Character Name Tag (Gold)
	_char_name_lbl = Label.new()
	_char_name_lbl.position = Vector2(78, 5)
	_char_name_lbl.size = Vector2(144, 11)
	_char_name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_char_name_lbl.add_theme_color_override("font_color", Color(0.98, 0.86, 0.12))
	inner_box.add_child(_char_name_lbl)

	# 6. Character Power / Perk Tag (Cyan)
	_char_perk_lbl = Label.new()
	_char_perk_lbl.position = Vector2(78, 17)
	_char_perk_lbl.size = Vector2(144, 10)
	_char_perk_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_char_perk_lbl.add_theme_color_override("font_color", Color(0.55, 0.9, 1.0))
	inner_box.add_child(_char_perk_lbl)

	# 7. Action Button (Equip / Unlock)
	_char_action_btn = Button.new()
	_char_action_btn.position = Vector2(78, 31)
	_char_action_btn.size = Vector2(144, 21)
	_char_action_btn.pressed.connect(_on_char_action)
	_char_action_btn.focus_entered.connect(func() -> void: if Game: Game.sfx("select", -8.0))
	inner_box.add_child(_char_action_btn)

	# 8. Lock Icon (Badge on character portrait)
	if _lock_tex:
		_char_lock_icon = Sprite2D.new()
		_char_lock_icon.texture = _lock_tex
		_char_lock_icon.position = Vector2(35, 16)
		_char_lock_icon.scale = Vector2(0.85, 0.85)
		_char_lock_icon.visible = false
		inner_box.add_child(_char_lock_icon)

	# 9. Equipped Status Label
	_char_status_lbl = Label.new()
	_char_status_lbl.position = Vector2(78, 36)
	_char_status_lbl.size = Vector2(144, 12)
	_char_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_char_status_lbl.add_theme_color_override("font_color", Color(0.13, 0.83, 0.93))
	_char_status_lbl.visible = false
	inner_box.add_child(_char_status_lbl)

	_update_carousel_view()


func _prev_character() -> void:
	if Game:
		Game.sfx("select", -6.0)
		var total: int = Game.CHARACTERS.size()
		_selected_char_idx = (_selected_char_idx - 1 + total) % total
		_update_carousel_view()


func _next_character() -> void:
	if Game:
		Game.sfx("select", -6.0)
		var total: int = Game.CHARACTERS.size()
		_selected_char_idx = (_selected_char_idx + 1) % total
		_update_carousel_view()


func _update_carousel_view() -> void:
	if not Game:
		return
	var char_id: String = Game.CHARACTERS[_selected_char_idx]
	var display_name: String = Game.CHAR_NAMES.get(char_id, char_id.to_upper())
	var cost: int = Game.CHAR_COSTS.get(char_id, 0)
	var is_unlocked: bool = Game.is_char_unlocked(char_id)
	var is_current: bool = (Game.current_character == char_id)

	_char_name_lbl.text = display_name
	if _char_perk_lbl:
		var perk: String = Game.CHAR_PERKS.get(char_id, "")
		_char_perk_lbl.text = "[ %s ]" % perk
	var tex: Texture2D = Game.get_character_texture(char_id)
	if tex:
		_char_preview.texture = tex

	if _char_lock_icon:
		_char_lock_icon.visible = not is_unlocked

	if is_current:
		_char_action_btn.visible = false
		_char_status_lbl.visible = true
		_char_status_lbl.text = "[ CURRENT HERO ]"
	elif is_unlocked:
		_char_status_lbl.visible = false
		_char_action_btn.visible = true
		_char_action_btn.text = "EQUIP HERO"
	else:
		# Locked
		_char_status_lbl.visible = false
		_char_action_btn.visible = true
		_char_action_btn.text = "UNLOCK (%d C)" % cost


func _on_char_action() -> void:
	if not Game:
		return
	var char_id: String = Game.CHARACTERS[_selected_char_idx]
	var is_unlocked: bool = Game.is_char_unlocked(char_id)
	var cost: int = Game.CHAR_COSTS.get(char_id, 0)

	if is_unlocked:
		# Equip
		Game.select_character(char_id)
		Game.sfx("select")
		_update_bottom_sprites()
		_update_carousel_view()
	else:
		# Attempt unlock with coins
		if Game.coins >= cost:
			if Game.unlock_character(char_id, true):
				Game.sfx("complete")
				_refresh_coin_badge()
				_update_bottom_sprites()
				_update_carousel_view()
		else:
			# Not enough coins
			Game.sfx("death", -6.0)
			_char_action_btn.text = "NEED %d MORE!" % (cost - Game.coins)
			var tw: = create_tween()
			tw.tween_interval(1.2)
			tw.tween_callback(func() -> void:
				if is_instance_valid(self):
					_update_carousel_view()
			)


func _build_memes() -> void :
	for i in FLYERS:
		var f: = Sprite2D.new()
		f.texture = Flyer.SKINS[i % Flyer.SKINS.size()]
		f.position = Vector2(40 + i * 60, 18 + (i * 37) % 44)
		add_child(f)
		move_child(f, $Background.get_index() + 1)
		_flyers.append(f)

	for i in 2:
		var m: = Sprite2D.new()
		m.texture = Hud.MEMES[[2, 5][i]]
		m.scale = Vector2(0.5, 0.5)
		m.offset = Vector2(0, -32)
		m.position = Vector2([24, 296][i], 150)
		add_child(m)
		_floor_memes.append(m)


func _process(delta: float) -> void :
	_t += delta
	if _coin_spr:
		_coin_spr.frame = int(_t * 8.0) % 4

	for i in _flyers.size():
		var f: = _flyers[i]
		f.position.x -= (14.0 + i * 3.0) * delta
		if f.position.x < -12:
			f.position.x = 332
		f.position.y += sin(_t * 2.0 + i) * 0.15
	for i in _floor_memes.size():
		_floor_memes[i].position.y = 150 - absf(sin(_t * 4.0 + i * 1.7)) * 6.0
	_chatter_t -= delta
	if _chatter_t <= 0.0:
		_chatter_t = randf_range(2.5, 5.0)
		Game.sfx("snore" if randf() < 0.3 else "flyer_chatter", -16.0, 0.3)
	
	var run_frame: = 8 + int(_t * 12.0) % 6
	robot.frame = run_frame
	echo_sprite.frame = 8 + int((_t - 0.4) * 12.0) % 6

	if _char_preview:
		# Animate run row (row 1 = frames 8-13), 6 frames at 8 fps
		_char_preview.frame = 8 + int(_t * 8.0) % 6

	_glitch_t -= delta
	if _glitch_t <= 0.0:
		_glitch_t = randf_range(0.08, 2.5)
		var on: = randf() < 0.35
		title_ghost.visible = on
		title_ghost.position = Vector2(_title_x + randi_range(-3, 3), title.position.y + randi_range(-1, 1))
		title.position.x = _title_x + (randi_range(-1, 1) if on else 0)


func _on_play() -> void :
	Game.sfx("select")
	Game.start_game()


func _on_levels() -> void :
	Game.sfx("select", -8.0)
	var ls: Node = LEVEL_SELECT_SCENE.new()
	add_child(ls)


func _on_how_to_play() -> void :
	Game.sfx("select", -8.0)
	var htp: Node = HOW_TO_PLAY_SCENE.new()
	add_child(htp)


func _on_quit() -> void :
	Game.quit_game()


func _unhandled_input(event: InputEvent) -> void :
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_on_quit()
