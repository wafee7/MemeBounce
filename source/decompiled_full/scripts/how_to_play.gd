extends Control

# Comic Book Field Manual for MEMEBOUNCE
# Pixel-perfect alignment, real animated character sprites, echo shader ghost & page navigation

const ECHO_SHADER: Shader = preload("res://shaders/echo.gdshader")

# Comic styling palette
const COLOR_PAPER: Color       = Color(0.96, 0.93, 0.85, 1.0) # Classic comic book paper
const COLOR_INK: Color         = Color(0.08, 0.06, 0.12, 1.0) # Deep comic ink
const COLOR_YELLOW: Color      = Color(0.98, 0.86, 0.12, 1.0) # Action yellow
const COLOR_RED: Color         = Color(0.92, 0.22, 0.22, 1.0) # Action red
const COLOR_BLUE: Color        = Color(0.20, 0.60, 0.95, 1.0) # Sky blue
const COLOR_CYAN: Color        = Color(0.13, 0.83, 0.93, 1.0) # Echo cyan
const COLOR_GOLD: Color        = Color(0.95, 0.72, 0.10, 1.0) # Trophy gold
const COLOR_WHITE: Color       = Color(1.0, 1.0, 1.0, 1.0)

var _current_page: int = 0
const TOTAL_PAGES: int = 4

var _page_containers: Array[Control] = []
var _animated_sprites: Array[Dictionary] = []
var _page_label: Label
var _prev_btn: Button
var _next_btn: Button
var _time: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	# 1. Dark comic vignette backdrop (covers entire 320x180 screen)
	var backdrop: ColorRect = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.02, 0.02, 0.06, 0.92)
	add_child(backdrop)

	# 2. Outer comic book border frame (312 x 172, centered)
	_draw_rect(backdrop, Rect2(4, 3, 312, 174), COLOR_INK)
	_draw_rect(backdrop, Rect2(5, 4, 310, 172), COLOR_YELLOW)
	_draw_rect(backdrop, Rect2(7, 6, 306, 168), COLOR_INK)

	# 3. Top Comic Book Header Strip
	_create_header()

	# 4. Pages Container (x=9, y=24, w=302, h=130)
	var page_area: Control = Control.new()
	page_area.layout_mode = 0
	page_area.offset_left = 9.0
	page_area.offset_top = 24.0
	page_area.offset_right = 311.0
	page_area.offset_bottom = 154.0
	page_area.size = Vector2(302, 130)
	add_child(page_area)

	# Build all 4 comic pages
	var p1: Control = _build_page_1()
	var p2: Control = _build_page_2()
	var p3: Control = _build_page_3()
	var p4: Control = _build_page_4()

	for p in [p1, p2, p3, p4]:
		page_area.add_child(p)
		_page_containers.append(p)

	# 5. Bottom Navigation Toolbar
	_create_bottom_toolbar()

	# Show initial page
	_show_page(0)


# -------------------------------------------------------------
# TOP HEADER
# -------------------------------------------------------------
func _create_header() -> void:
	# Yellow banner bar
	_draw_rect(self, Rect2(8, 7, 304, 15), COLOR_YELLOW)

	# Left issue badge
	var badge: Label = Label.new()
	badge.text = "[ISSUE #1]"
	badge.layout_mode = 0
	badge.offset_left = 12.0
	badge.offset_top = 8.0
	badge.add_theme_color_override("font_color", COLOR_INK)
	add_child(badge)

	# Title
	var title: Label = Label.new()
	title.text = "★ MEMEBOUNCE : COMIC FIELD MANUAL ★"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.layout_mode = 0
	title.offset_left = 55.0
	title.offset_top = 8.0
	title.offset_right = 265.0
	title.offset_bottom = 20.0
	title.add_theme_color_override("font_color", COLOR_INK)
	add_child(title)

	# Right page counter
	_page_label = Label.new()
	_page_label.text = "PG 1/4"
	_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_page_label.layout_mode = 0
	_page_label.offset_left = 266.0
	_page_label.offset_top = 8.0
	_page_label.offset_right = 308.0
	_page_label.offset_bottom = 20.0
	_page_label.add_theme_color_override("font_color", COLOR_RED)
	add_child(_page_label)


# -------------------------------------------------------------
# PAGE 1: MOVEMENT & JUMPING
# -------------------------------------------------------------
func _build_page_1() -> Control:
	var page: Control = _create_page_root()

	# LEFT PANEL: Running (147 x 128)
	var left_p: Control = _create_panel(page, Rect2(0, 0, 148, 128), Color(0.88, 0.94, 0.98))
	_add_panel_title(left_p, "EP.1: WADDLE & RUN", COLOR_BLUE)

	# Lawn ground
	_draw_rect(left_p, Rect2(2, 94, 144, 32), Color(0.35, 0.72, 0.40))
	_draw_rect(left_p, Rect2(2, 94, 144, 2), COLOR_INK)

	# Running Froggy sprite
	var run_frog: Sprite2D = _create_char_sprite("froggy", Vector2(36, 84))
	left_p.add_child(run_frog)
	_animated_sprites.append({"sprite": run_frog, "fps": 10.0, "frames": [8, 9, 10, 11, 12, 13]})

	# Sound effect burst
	_add_burst(left_p, Vector2(10, 24), "*SWOOSH!*", COLOR_YELLOW)

	# Speech bubble
	_add_speech_bubble(left_p, Rect2(52, 22, 90, 48), "Use [A] & [D]\nto waddle left\nand right!", COLOR_INK)

	# Controls tag
	_add_key_badge(left_p, Vector2(8, 104), "KEY: A / D", COLOR_INK, COLOR_WHITE)

	# RIGHT PANEL: Jumping (148 x 128)
	var right_p: Control = _create_panel(page, Rect2(154, 0, 148, 128), Color(0.98, 0.94, 0.86))
	_add_panel_title(right_p, "EP.2: THE HIGH LEAP", COLOR_YELLOW)

	# Pit and platforms
	_draw_rect(right_p, Rect2(2, 94, 46, 32), COLOR_INK)
	_draw_rect(right_p, Rect2(100, 94, 46, 32), COLOR_INK)

	# Mid-air jumping Froggy sprite
	var jump_frog: Sprite2D = _create_char_sprite("froggy", Vector2(74, 58))
	jump_frog.frame = 17
	right_p.add_child(jump_frog)

	# Sound burst
	_add_burst(right_p, Vector2(8, 22), "*BOING!*", COLOR_RED)

	# Speech bubble
	_add_speech_bubble(right_p, Rect2(8, 22, 132, 28), "Tap SPACE to hop!\nHOLD SPACE for MAX height!", COLOR_INK)

	# Controls tag
	_add_key_badge(right_p, Vector2(8, 104), "KEY: SPACE", COLOR_RED, COLOR_WHITE)

	return page


# -------------------------------------------------------------
# PAGE 2: HAZARDS & THE ECHO SHADER
# -------------------------------------------------------------
func _build_page_2() -> Control:
	var page: Control = _create_page_root()

	# LEFT PANEL: Spikes & Death (148 x 128)
	var left_p: Control = _create_panel(page, Rect2(0, 0, 148, 128), Color(0.98, 0.88, 0.86))
	_add_panel_title(left_p, "EP.3: SKILL ISSUE?", COLOR_RED)

	# Floor with spikes
	_draw_rect(left_p, Rect2(2, 94, 144, 32), COLOR_INK)
	for i in 6:
		var sp: Label = Label.new()
		sp.text = "^"
		sp.layout_mode = 0
		sp.offset_left = 32 + i * 14
		sp.offset_top = 84
		sp.add_theme_color_override("font_color", COLOR_RED)
		left_p.add_child(sp)

	# Dead character sprite
	var dead_frog: Sprite2D = _create_char_sprite("froggy", Vector2(74, 82))
	dead_frog.frame = 26
	dead_frog.rotation = 0.5
	left_p.add_child(dead_frog)

	_add_burst(left_p, Vector2(8, 24), "*OUCH!*", COLOR_RED)
	_add_speech_bubble(left_p, Rect2(8, 22, 132, 34), "Pointy = ouch!\nFalling is fine, spikes are NOT!", COLOR_INK)
	_add_caption(left_p, Vector2(8, 104), "Death is step 1 of your strategy!")

	# RIGHT PANEL: GHOST ECHO (148 x 128)
	var right_p: Control = _create_panel(page, Rect2(154, 0, 148, 128), Color(0.10, 0.08, 0.18))
	_add_panel_title(right_p, "EP.4: GHOST ECHO!", COLOR_CYAN)

	# Sci-fi floor
	_draw_rect(right_p, Rect2(2, 94, 144, 32), Color(0.18, 0.14, 0.28))

	# Pressure switch
	_draw_rect(right_p, Rect2(24, 90, 24, 4), COLOR_YELLOW)

	# REAL GHOST ECHO (with echo.gdshader!)
	var echo_ghost: Sprite2D = _create_char_sprite("froggy", Vector2(36, 82))
	echo_ghost.frame = 0
	var echo_mat: ShaderMaterial = ShaderMaterial.new()
	echo_mat.shader = ECHO_SHADER
	echo_mat.set_shader_parameter("alpha", 0.75)
	echo_mat.set_shader_parameter("tint", COLOR_CYAN)
	echo_ghost.material = echo_mat
	right_p.add_child(echo_ghost)

	# Alive frog jumping off the echo
	var alive_frog: Sprite2D = _create_char_sprite("froggy", Vector2(90, 56))
	alive_frog.frame = 16
	right_p.add_child(alive_frog)

	# Exit door
	_draw_rect(right_p, Rect2(116, 54, 26, 40), Color(0.2, 0.9, 0.4, 0.5))

	_add_burst(right_p, Vector2(8, 20), "*REBOUND!*", COLOR_YELLOW)
	_add_speech_bubble(right_p, Rect2(8, 20, 132, 30), "Press [R]! I'm your ghost bro!\nI hold switches for you!", COLOR_CYAN)
	_add_caption(right_p, Vector2(8, 104), "Press [R] anytime to summon echo!")

	return page


# -------------------------------------------------------------
# PAGE 3: UNLOCKABLE CHARACTER SQUAD
# -------------------------------------------------------------
func _build_page_3() -> Control:
	var page: Control = _create_page_root()

	var p: Control = _create_panel(page, Rect2(0, 0, 302, 128), COLOR_PAPER)
	_add_panel_title(p, "EP.5: CLAIM NEW LEGENDS!", COLOR_GOLD)

	var squad: Array = [
		{"name": "FROGGY", "milestone": "UNLOCKED", "tag": "DEFAULT", "tex": "froggy", "x": 39},
		{"name": "BUNNY", "milestone": "LVL 1 BEAT", "tag": "SPEEDY", "tex": "bunny", "x": 115},
		{"name": "MUSHROOM", "milestone": "LVL 2 BEAT", "tag": "SPORE", "tex": "mushroom", "x": 191},
		{"name": "DETECTIVE", "milestone": "LVL 3 BEAT", "tag": "SLEUTH", "tex": "detective", "x": 267}
	]

	for item in squad:
		var cx: float = item["x"]

		# Card box (66 x 80)
		_draw_rect(p, Rect2(cx - 33, 18, 66, 80), COLOR_WHITE)
		_draw_rect_outline(p, Rect2(cx - 33, 18, 66, 80), COLOR_INK, 1)

		# Top Name bar
		_draw_rect(p, Rect2(cx - 32, 19, 64, 11), COLOR_YELLOW)
		var nl: Label = Label.new()
		nl.text = item["name"]
		nl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nl.layout_mode = 0
		nl.offset_left = cx - 33
		nl.offset_top = 20
		nl.offset_right = cx + 33
		nl.offset_bottom = 31
		nl.add_theme_color_override("font_color", COLOR_INK)
		p.add_child(nl)

		# Character sprite
		var spr: Sprite2D = _create_char_sprite(item["tex"], Vector2(cx, 48))
		spr.frame = 0
		p.add_child(spr)
		_animated_sprites.append({"sprite": spr, "fps": 5.0, "frames": [0, 1, 2, 1, 0, 3]})

		# Role tag
		var rl: Label = Label.new()
		rl.text = item["tag"]
		rl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rl.layout_mode = 0
		rl.offset_left = cx - 33
		rl.offset_top = 64
		rl.offset_right = cx + 33
		rl.offset_bottom = 74
		rl.add_theme_color_override("font_color", Color(0.3, 0.4, 0.6))
		p.add_child(rl)

		# Milestone tag
		var ml: Label = Label.new()
		ml.text = item["milestone"]
		ml.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ml.layout_mode = 0
		ml.offset_left = cx - 33
		ml.offset_top = 78
		ml.offset_right = cx + 33
		ml.offset_bottom = 90
		ml.add_theme_color_override("font_color", COLOR_RED)
		p.add_child(ml)

	# Bottom Banner
	_draw_rect(p, Rect2(6, 104, 290, 18), COLOR_YELLOW)
	_draw_rect_outline(p, Rect2(6, 104, 290, 18), COLOR_INK, 1)
	var bl: Label = Label.new()
	bl.text = "★ UNLOCK 8 LEGENDARY HEROES WITH UNIQUE POWERS! ★"
	bl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bl.layout_mode = 0
	bl.offset_left = 6
	bl.offset_top = 107
	bl.offset_right = 296
	bl.offset_bottom = 120
	bl.add_theme_color_override("font_color", COLOR_INK)
	p.add_child(bl)

	return page


# -------------------------------------------------------------
# PAGE 4: PRO TIPS & CHEATSHEET
# -------------------------------------------------------------
func _build_page_4() -> Control:
	var page: Control = _create_page_root()

	# LEFT PANEL: Controls Cheatsheet
	var left_p: Control = _create_panel(page, Rect2(0, 0, 148, 128), Color(0.94, 0.98, 0.94))
	_add_panel_title(left_p, "CONTROLS CHEAT SHEET", Color(0.20, 0.75, 0.40))

	var list: Array = [
		["A / D", "Move Left / Right"],
		["SPACE", "Jump (Hold for height)"],
		["R KEY", "Bounce Back / Summon Echo"],
		["ESC", "Pause Game / Close Menu"]
	]

	for i in list.size():
		var y: float = 20.0 + i * 26.0
		_add_key_badge(left_p, Vector2(6, y), list[i][0], COLOR_INK, COLOR_YELLOW)
		var desc: Label = Label.new()
		desc.text = list[i][1]
		desc.layout_mode = 0
		desc.offset_left = 6
		desc.offset_top = y + 12
		desc.offset_right = 142
		desc.offset_bottom = y + 24
		desc.add_theme_color_override("font_color", COLOR_INK)
		left_p.add_child(desc)

	# RIGHT PANEL: Meme Wisdom & Play button
	var right_p: Control = _create_panel(page, Rect2(154, 0, 148, 128), Color(0.98, 0.95, 0.88))
	_add_panel_title(right_p, "PRO MEME TIPS", COLOR_YELLOW)

	var tips_lbl: Label = Label.new()
	tips_lbl.text = "1. You can bounce\n   off your echo's head!\n2. Echoes hold doors open!\n3. Never give up.\n   Bounce back stronger!"
	tips_lbl.layout_mode = 0
	tips_lbl.offset_left = 8
	tips_lbl.offset_top = 22
	tips_lbl.offset_right = 142
	tips_lbl.offset_bottom = 85
	tips_lbl.add_theme_color_override("font_color", COLOR_INK)
	right_p.add_child(tips_lbl)

	# Action Button
	var start_btn: Button = Button.new()
	start_btn.text = "READY TO BOUNCE!"
	start_btn.layout_mode = 0
	start_btn.offset_left = 12
	start_btn.offset_top = 94
	start_btn.offset_right = 136
	start_btn.offset_bottom = 116
	start_btn.pressed.connect(_on_close)
	start_btn.focus_entered.connect(_play_sfx)
	right_p.add_child(start_btn)

	return page


# -------------------------------------------------------------
# BOTTOM TOOLBAR & NAVIGATION
# -------------------------------------------------------------
func _create_bottom_toolbar() -> void:
	# Bottom bar background
	_draw_rect(self, Rect2(8, 156, 304, 18), COLOR_INK)

	# Previous Page Button
	_prev_btn = Button.new()
	_prev_btn.text = "< PREV"
	_prev_btn.layout_mode = 0
	_prev_btn.offset_left = 12.0
	_prev_btn.offset_top = 158.0
	_prev_btn.offset_right = 72.0
	_prev_btn.offset_bottom = 172.0
	_prev_btn.pressed.connect(_on_prev_page)
	_prev_btn.focus_entered.connect(_play_sfx)
	add_child(_prev_btn)

	# Next Page Button
	_next_btn = Button.new()
	_next_btn.text = "NEXT >"
	_next_btn.layout_mode = 0
	_next_btn.offset_left = 76.0
	_next_btn.offset_top = 158.0
	_next_btn.offset_right = 136.0
	_next_btn.offset_bottom = 172.0
	_next_btn.pressed.connect(_on_next_page)
	_next_btn.focus_entered.connect(_play_sfx)
	add_child(_next_btn)

	# Navigation hint
	var nav_hint: Label = Label.new()
	nav_hint.text = "SCROLL OR A/D"
	nav_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nav_hint.layout_mode = 0
	nav_hint.offset_left = 138.0
	nav_hint.offset_top = 160.0
	nav_hint.offset_right = 230.0
	nav_hint.offset_bottom = 172.0
	nav_hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	add_child(nav_hint)

	# Close Button
	var close_btn: Button = Button.new()
	close_btn.text = "[ CLOSE ]"
	close_btn.layout_mode = 0
	close_btn.offset_left = 236.0
	close_btn.offset_top = 158.0
	close_btn.offset_right = 304.0
	close_btn.offset_bottom = 172.0
	close_btn.pressed.connect(_on_close)
	close_btn.focus_entered.connect(_play_sfx)
	add_child(close_btn)
	close_btn.grab_focus()


func _show_page(page_idx: int) -> void:
	_current_page = clampi(page_idx, 0, TOTAL_PAGES - 1)
	for i in range(_page_containers.size()):
		_page_containers[i].visible = (i == _current_page)

	if _page_label:
		_page_label.text = "PG %d/%d" % [_current_page + 1, TOTAL_PAGES]
	if _prev_btn:
		_prev_btn.disabled = (_current_page == 0)
	if _next_btn:
		_next_btn.disabled = (_current_page == TOTAL_PAGES - 1)


func _on_prev_page() -> void:
	if _current_page > 0:
		_play_sfx()
		_show_page(_current_page - 1)


func _on_next_page() -> void:
	if _current_page < TOTAL_PAGES - 1:
		_play_sfx()
		_show_page(_current_page + 1)


# -------------------------------------------------------------
# GRAPHICAL HELPERS
# -------------------------------------------------------------
func _create_page_root() -> Control:
	var c: Control = Control.new()
	c.layout_mode = 0
	c.offset_left = 0
	c.offset_top = 0
	c.offset_right = 302
	c.offset_bottom = 128
	c.size = Vector2(302, 128)
	return c


func _create_panel(parent: Control, r: Rect2, bg_col: Color) -> Control:
	var c: Control = Control.new()
	c.layout_mode = 0
	c.position = r.position
	c.size = r.size

	# Panel drop shadow
	_draw_rect(c, Rect2(2, 2, r.size.x, r.size.y), Color(0.0, 0.0, 0.0, 0.25))
	# Panel background
	_draw_rect(c, Rect2(0, 0, r.size.x, r.size.y), bg_col)
	# Comic ink outline
	_draw_rect_outline(c, Rect2(0, 0, r.size.x, r.size.y), COLOR_INK, 2)
	parent.add_child(c)
	return c


func _add_panel_title(parent: Control, text: String, col: Color) -> void:
	var pw: float = parent.size.x
	_draw_rect(parent, Rect2(2, 2, pw - 4, 13), col)
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.layout_mode = 0
	lbl.offset_left = 6
	lbl.offset_top = 3
	lbl.offset_right = pw - 6
	lbl.offset_bottom = 15
	lbl.add_theme_color_override("font_color", COLOR_INK)
	parent.add_child(lbl)


func _add_speech_bubble(parent: Control, r: Rect2, text: String, border_col: Color) -> void:
	# Comic speech bubble box
	_draw_rect(parent, Rect2(r.position.x + 1, r.position.y + 1, r.size.x, r.size.y), Color(0.0, 0.0, 0.0, 0.15))
	_draw_rect(parent, r, COLOR_WHITE)
	_draw_rect_outline(parent, r, border_col, 1)

	var lbl: Label = Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.layout_mode = 0
	lbl.offset_left = r.position.x + 4
	lbl.offset_top = r.position.y + 3
	lbl.offset_right = r.position.x + r.size.x - 4
	lbl.offset_bottom = r.position.y + r.size.y - 3
	lbl.add_theme_color_override("font_color", COLOR_INK)
	parent.add_child(lbl)


func _add_burst(parent: Control, pos: Vector2, text: String, col: Color) -> void:
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.layout_mode = 0
	lbl.offset_left = pos.x
	lbl.offset_top = pos.y
	lbl.add_theme_color_override("font_color", col)
	parent.add_child(lbl)


func _add_key_badge(parent: Control, pos: Vector2, text: String, bg_col: Color, txt_col: Color) -> void:
	var w: float = 62.0
	var h: float = 12.0
	_draw_rect(parent, Rect2(pos.x, pos.y, w, h), bg_col)
	_draw_rect_outline(parent, Rect2(pos.x, pos.y, w, h), COLOR_INK, 1)

	var lbl: Label = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.layout_mode = 0
	lbl.offset_left = pos.x
	lbl.offset_top = pos.y + 1
	lbl.offset_right = pos.x + w
	lbl.offset_bottom = pos.y + h
	lbl.add_theme_color_override("font_color", txt_col)
	parent.add_child(lbl)


func _add_caption(parent: Control, pos: Vector2, text: String) -> void:
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.layout_mode = 0
	lbl.offset_left = pos.x
	lbl.offset_top = pos.y
	lbl.add_theme_color_override("font_color", Color(0.3, 0.25, 0.35))
	parent.add_child(lbl)


func _create_char_sprite(char_name: String, pos: Vector2) -> Sprite2D:
	var spr: Sprite2D = Sprite2D.new()
	var g: Node = get_tree().root.get_node_or_null("Game") if get_tree() else null
	if g and g.has_method("get_character_texture"):
		spr.texture = g.get_character_texture(char_name)
	else:
		var img: Image = Image.load_from_file("res://assets/sprites/characters/%s.png" % char_name)
		if img:
			spr.texture = ImageTexture.create_from_image(img)
	spr.hframes = 8
	spr.vframes = 4
	spr.position = pos
	return spr


func _draw_rect(parent: Control, r: Rect2, col: Color) -> ColorRect:
	var cr: ColorRect = ColorRect.new()
	cr.layout_mode = 0
	cr.offset_left = r.position.x
	cr.offset_top = r.position.y
	cr.offset_right = r.position.x + r.size.x
	cr.offset_bottom = r.position.y + r.size.y
	cr.color = col
	parent.add_child(cr)
	return cr


func _draw_rect_outline(parent: Control, r: Rect2, col: Color, thickness: int) -> void:
	_draw_rect(parent, Rect2(r.position.x, r.position.y, r.size.x, thickness), col)
	_draw_rect(parent, Rect2(r.position.x, r.position.y + r.size.y - thickness, r.size.x, thickness), col)
	_draw_rect(parent, Rect2(r.position.x, r.position.y, thickness, r.size.y), col)
	_draw_rect(parent, Rect2(r.position.x + r.size.x - thickness, r.position.y, thickness, r.size.y), col)


# -------------------------------------------------------------
# ANIMATIONS & INPUT
# -------------------------------------------------------------
func _process(delta: float) -> void:
	_time += delta
	for item in _animated_sprites:
		var spr: Sprite2D = item["sprite"]
		if not spr or not is_instance_valid(spr) or not spr.is_inside_tree():
			continue
		var frames: Array = item["frames"]
		var fps: float = item["fps"]
		var idx: int = int(_time * fps) % frames.size()
		spr.frame = frames[idx]


func _play_sfx() -> void:
	if not get_tree():
		return
	var g: Node = get_tree().root.get_node_or_null("Game")
	if g and g.has_method("sfx"):
		g.sfx("select", -8.0)


func _on_close() -> void:
	_play_sfx()
	queue_free()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_on_close()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_LEFT or event.keycode == KEY_A or event.keycode == KEY_UP:
			_on_prev_page()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_RIGHT or event.keycode == KEY_D or event.keycode == KEY_DOWN or event.keycode == KEY_SPACE:
			_on_next_page()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_on_prev_page()
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_on_next_page()
			get_viewport().set_input_as_handled()
