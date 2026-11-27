class_name LevelSelect
extends Control

# Comic-styled Level Select Modal for MEMEBOUNCE

const COLOR_INK: Color       = Color(0.08, 0.06, 0.12, 1.0)
const COLOR_YELLOW: Color    = Color(0.98, 0.86, 0.12, 1.0)
const COLOR_CYAN: Color      = Color(0.13, 0.83, 0.93, 1.0)
const COLOR_LOCKED: Color    = Color(0.45, 0.48, 0.58, 1.0)
const COLOR_RED: Color       = Color(0.95, 0.35, 0.35, 1.0)

var _lock_tex: Texture2D
var _coin_spr: Sprite2D
var _coin_t: float = 0.0


static func get_lock_icon() -> Texture2D:
	var path: = "res://assets/sprites/lock.png"
	if ResourceLoader.exists(path):
		return load(path)
	return null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	_lock_tex = get_lock_icon()

	# 1. Dark comic vignette backdrop
	var backdrop: ColorRect = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.03, 0.03, 0.08, 0.95)
	add_child(backdrop)

	# 2. Comic borders
	_draw_rect(backdrop, Rect2(4, 3, 312, 174), COLOR_INK)
	_draw_rect(backdrop, Rect2(5, 4, 310, 172), COLOR_YELLOW)
	_draw_rect(backdrop, Rect2(7, 6, 306, 168), COLOR_INK)

	# 3. Header bar
	_build_header(backdrop)

	# 4. Level Cards (Rows 1 & 2)
	_build_level_cards(backdrop)

	# 5. Footer Back Button
	_build_footer(backdrop)


func _draw_rect(parent: Node, rect: Rect2, color: Color) -> ColorRect:
	var cr: ColorRect = ColorRect.new()
	cr.position = rect.position
	cr.size = rect.size
	cr.color = color
	cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(cr)
	return cr


func _build_header(parent: Node) -> void:
	var header_box: ColorRect = _draw_rect(parent, Rect2(8, 7, 304, 18), COLOR_YELLOW)
	_draw_rect(header_box, Rect2(1, 1, 302, 16), COLOR_INK)

	var title: Label = Label.new()
	title.text = "- SELECT LEVEL -"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 4)
	title.size = Vector2(304, 12)
	title.add_theme_color_override("font_color", COLOR_YELLOW)
	header_box.add_child(title)

	# Animated spinning golden coin
	_coin_spr = Sprite2D.new()
	if ResourceLoader.exists("res://assets/sprites/coins/spr_coin_strip4.png"):
		_coin_spr.texture = load("res://assets/sprites/coins/spr_coin_strip4.png")
	_coin_spr.hframes = 4
	_coin_spr.frame = 0
	_coin_spr.position = Vector2(252, 9)
	header_box.add_child(_coin_spr)

	var coin_lbl: Label = Label.new()
	var c_count: int = Game.coins if Game else 0
	coin_lbl.text = "x %d" % c_count
	coin_lbl.position = Vector2(262, 4)
	coin_lbl.size = Vector2(40, 12)
	coin_lbl.add_theme_color_override("font_color", COLOR_YELLOW)
	header_box.add_child(coin_lbl)

	# Subtitle
	var sub: Label = Label.new()
	sub.text = "BEAT EACH LEVEL TO UNLOCK THE NEXT STAGE"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, 26)
	sub.size = Vector2(320, 10)
	sub.add_theme_color_override("font_color", Color(0.65, 0.75, 0.95))
	parent.add_child(sub)


func _build_level_cards(parent: Node) -> void:
	# Row 1 (Levels 1 to 4): y = 37, card_w = 70, card_h = 55, gap = 6
	var row1_x_start: = 11.0
	var card_w: = 70.0
	var card_h: = 55.0
	var gap_x: = 6.0

	for i in 4:
		var x: float = row1_x_start + i * (card_w + gap_x)
		_create_card(parent, i, Vector2(x, 37.0), Vector2(card_w, card_h))

	# Row 2 (Levels 5 to 7): y = 97, card_w = 72, card_h = 55, gap = 12 (centered for 3 cards)
	var row2_w: float = 3.0 * 72.0 + 2.0 * 12.0
	var row2_x_start: float = (320.0 - row2_w) / 2.0

	for i in 3:
		var lvl_idx: int = 4 + i
		var x: float = row2_x_start + i * (72.0 + 12.0)
		_create_card(parent, lvl_idx, Vector2(x, 97.0), Vector2(72.0, card_h))


func _create_card(parent: Node, lvl_idx: int, pos: Vector2, sz: Vector2) -> void:
	var unlocked: bool = Game.is_level_unlocked(lvl_idx) if Game else (lvl_idx == 0)
	var lvl_title: String = Game.LEVEL_TITLES[lvl_idx] if (Game and lvl_idx < Game.LEVEL_TITLES.size()) else ("LEVEL %d" % (lvl_idx + 1))

	var card: ColorRect = ColorRect.new()
	card.position = pos
	card.size = sz
	card.color = COLOR_INK
	parent.add_child(card)

	# Border
	var border_col: Color = COLOR_CYAN if unlocked else Color(0.2, 0.22, 0.3)
	_draw_rect(card, Rect2(0, 0, sz.x, sz.y), border_col)
	var inner_bg: ColorRect = _draw_rect(card, Rect2(1, 1, sz.x - 2, sz.y - 2), Color(0.08, 0.1, 0.16) if unlocked else Color(0.05, 0.05, 0.08))

	# Level tag (e.g. "LV 1")
	var num_lbl: Label = Label.new()
	num_lbl.text = "LV %d" % (lvl_idx + 1)
	num_lbl.position = Vector2(2, 2)
	num_lbl.size = Vector2(sz.x - 4, 10)
	num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num_lbl.add_theme_color_override("font_color", COLOR_YELLOW if unlocked else COLOR_LOCKED)
	inner_bg.add_child(num_lbl)

	# Level Name - split on spaces manually so pixel font wraps correctly
	var title_words: = lvl_title.split(" ")
	var title_line1: = ""
	var title_line2: = ""
	var split_done: = false
	for w in title_words:
		if not split_done and (title_line1 + w).length() <= 8:
			title_line1 += ("" if title_line1 == "" else " ") + w
		else:
			split_done = true
			title_line2 += ("" if title_line2 == "" else " ") + w
	var display_title: = title_line1 + ("\n" + title_line2 if title_line2 != "" else "")
	var title_lbl: Label = Label.new()
	title_lbl.text = display_title
	title_lbl.position = Vector2(2, 10)
	title_lbl.size = Vector2(sz.x - 4, 20)
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_lbl.add_theme_color_override("font_color", Color.WHITE if unlocked else COLOR_LOCKED)
	inner_bg.add_child(title_lbl)

	if unlocked:
		var play_btn: Button = Button.new()
		play_btn.text = "PLAY"
		play_btn.position = Vector2(6, 36)
		play_btn.size = Vector2(sz.x - 12, 16)
		play_btn.pressed.connect(func() -> void:
			if Game:
				Game.sfx("select")
				Game.go_to_level(lvl_idx)
		)
		play_btn.focus_entered.connect(func() -> void:
			if Game:
				Game.sfx("select", -8.0)
		)
		inner_bg.add_child(play_btn)
		if lvl_idx == 0:
			play_btn.grab_focus()
	else:
		# Locked state: display pixel-art padlock icon and red locked text
		if _lock_tex:
			var lock_s: Sprite2D = Sprite2D.new()
			lock_s.texture = _lock_tex
			lock_s.position = Vector2(sz.x / 2.0 - 24, 20)
			lock_s.scale = Vector2(0.8, 0.8)
			inner_bg.add_child(lock_s)

		var lock_lbl: Label = Label.new()
		lock_lbl.text = "LOCKED"
		lock_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_lbl.position = Vector2(6, 38)
		lock_lbl.size = Vector2(sz.x - 8, 12)
		lock_lbl.add_theme_color_override("font_color", COLOR_RED)
		inner_bg.add_child(lock_lbl)


func _build_footer(parent: Node) -> void:
	var back_btn: Button = Button.new()
	back_btn.text = "[ BACK TO MENU (ESC) ]"
	back_btn.position = Vector2(85, 149)
	back_btn.size = Vector2(150, 19)
	back_btn.pressed.connect(_close)
	back_btn.focus_entered.connect(func() -> void:
		if Game:
			Game.sfx("select", -8.0)
	)
	parent.add_child(back_btn)


func _close() -> void:
	if Game:
		Game.sfx("select", -8.0)
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_close()
			get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	_coin_t += delta
	if _coin_spr:
		_coin_spr.frame = int(_coin_t * 8.0) % 4
