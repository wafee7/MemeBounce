extends Node



const LEVELS: = [
	"res://scenes/levels/level_1.tscn", 
	"res://scenes/levels/level_2.tscn", 
	"res://scenes/levels/level_3.tscn", 
	"res://scenes/levels/level_4.tscn", 
	"res://scenes/levels/level_5.tscn", 
	"res://scenes/levels/level_6.tscn", 
	"res://scenes/levels/level_7.tscn", 
]
const MAIN_MENU: = "res://scenes/ui/main_menu.tscn"
const END_SCREEN: = "res://scenes/ui/end_screen.tscn"


const SFX: = {
	"jump": 1, "land": 1, "death": 6, "rebound": 1, "echo": 1, 
	"plate_on": 1, "plate_off": 1, "door_open": 1, "door_close": 1, 
	"bounce": 1, "complete": 2, "respawn": 1, "select": 1, 
	"flyer_chatter": 7, "flyer_pop": 4, "flyer_kill": 5, "snore": 1, 
}


const VOICE_SLOTS: = ["death", "rebound", "echo", "complete", "plate_on", "plate_off", "door_open", "door_close", "flyer_kill"]

const PRIORITY_LINES: = ["flyer_kill"]


var test_mode: = false
var current_level: = 0
var failures: = 0

const CHARACTERS: = ["froggy", "bunny", "mushroom", "detective", "knight", "marine", "heroine", "lizard"]
const CHAR_NAMES: = {
	"froggy": "FROGGY (THE LEAPER)",
	"bunny": "SPEEDY BUNNY",
	"mushroom": "SPORE BOUNCER",
	"detective": "SIGMA DETECTIVE",
	"knight": "TERRIBLE KNIGHT",
	"marine": "CYBER MARINE",
	"heroine": "VALKYRIE HEROINE",
	"lizard": "GROTTO LIZARD"
}
const CHAR_COSTS: = {
	"froggy": 0,
	"bunny": 25,
	"mushroom": 50,
	"detective": 80,
	"knight": 110,
	"marine": 140,
	"heroine": 175,
	"lizard": 200
}
const CHAR_PERKS: = {
	"froggy": "HIGH LEAP (+15% JUMP)",
	"bunny": "SUPER SPEED (+30% RUN)",
	"mushroom": "FLOATY SPORES (SOFT GRAVITY)",
	"detective": "COIN MAGNET (x2 COINS)",
	"knight": "TITAN STOMP (SUPER BOUNCE)",
	"marine": "JET THRUST (DOUBLE JUMP)",
	"heroine": "AIR DASH (SHIFT TO DASH)",
	"lizard": "WALL SCALER (WALL JUMP)"
}
const LEVEL_TITLES: = [
	"FIRST FALL",
	"MEET YOUR ECHO",
	"SPRING LOADED",
	"BOUNCE BACK",
	"INCOMING",
	"CROSSFIRE",
	"LAST BOUNCE"
]
var current_character: String = "froggy"
var unlocked_characters: Array = ["froggy"]
var coins: int = 0
var unlocked_levels: int = 1
var _char_textures: = {}

var _sfx: = {}
var _last_pick: = {}
var _voices: Array[AudioStreamPlayer] = []
var _next_voice: = 0
var _voice_line: AudioStreamPlayer
var _queued_line: = []
var _music: AudioStreamPlayer
var _changing: = false
var _quitting: = false


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Allow the OS to close the window cleanly at any time
	get_tree().auto_accept_quit = true
	_setup_input()
	load_game()
	for slot in SFX:
		var clips: Array[AudioStream] = []
		for i in SFX[slot]:
			clips.append(load("res://assets/audio/meme/%s_%d.ogg" % [slot, i]))
		_sfx[slot] = clips
	for i in 10:
		var p: = AudioStreamPlayer.new()
		add_child(p)
		_voices.append(p)
	_voice_line = AudioStreamPlayer.new()
	add_child(_voice_line)
	_voice_line.finished.connect(_play_queued_line)
	_setup_music()


func _notification(what: int) -> void :
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_release_audio()
		get_tree().quit()


func quit_game() -> void :
	if _quitting:
		_release_audio()
		get_tree().quit()
		return
	_quitting = true
	_show_quit_meme()


func _show_quit_meme() -> void :
	var layer: = CanvasLayer.new()
	layer.layer = 256
	layer.process_mode = Node.PROCESS_MODE_ALWAYS

	var rect: = ColorRect.new()
	rect.color = Color(0.04, 0.04, 0.08, 0.96)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(rect)

	var tex: Texture2D = load("res://assets/sprites/hamster.png")
	if tex:
		var card: = TextureRect.new()
		card.texture = tex
		card.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		card.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var w: = 110.0
		var h: = 95.0
		var vp_sz: = get_viewport().get_visible_rect().size
		card.size = Vector2(w, h)
		card.position = Vector2((vp_sz.x - w) / 2.0, (vp_sz.y - h) / 2.0 - 10.0)
		layer.add_child(card)

	var label_top: = Label.new()
	label_top.text = "RAGEQUIT? GG!"
	label_top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_top.add_theme_color_override("font_color", Color(0.98, 0.8, 0.08))
	label_top.size = Vector2(get_viewport().get_visible_rect().size.x, 20.0)
	label_top.position = Vector2(0, 12.0)
	layer.add_child(label_top)

	var label_bot: = Label.new()
	label_bot.text = "THANKS FOR PLAYING MEMEBOUNCE!"
	label_bot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_bot.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	label_bot.size = Vector2(get_viewport().get_visible_rect().size.x, 20.0)
	label_bot.position = Vector2(0, get_viewport().get_visible_rect().size.y - 24.0)
	layer.add_child(label_bot)

	get_tree().root.add_child(layer)

	await get_tree().create_timer(2.2, true, false, true).timeout
	_release_audio()
	get_tree().quit()


func _exit_tree() -> void :
	_release_audio()


func _release_audio() -> void :
	if _music:
		_music.stop()
		_music.stream = null
	_queued_line = []
	for p in _voices + [_voice_line]:
		if p:
			p.stop()
			p.stream = null

	for p in get_tree().get_nodes_in_group("sfx_players"):
		p.stop()
		p.stream = null




func _setup_input() -> void :
	_bind("move_left", [KEY_A, KEY_LEFT], [JOY_BUTTON_DPAD_LEFT])
	_bind("move_right", [KEY_D, KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT])
	_bind("jump", [KEY_SPACE, KEY_W, KEY_UP, KEY_Z], [JOY_BUTTON_A])
	_bind("rebound", [KEY_R], [JOY_BUTTON_Y])
	_bind("pause", [KEY_ESCAPE, KEY_P], [JOY_BUTTON_START])
	var axis_l: = InputEventJoypadMotion.new()
	axis_l.axis = JOY_AXIS_LEFT_X
	axis_l.axis_value = -1.0
	InputMap.action_add_event("move_left", axis_l)
	var axis_r: = InputEventJoypadMotion.new()
	axis_r.axis = JOY_AXIS_LEFT_X
	axis_r.axis_value = 1.0
	InputMap.action_add_event("move_right", axis_r)


func _bind(action: String, keys: Array, buttons: Array) -> void :
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.3)
	for k in keys:
		var ev: = InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
	for b in buttons:
		var jb: = InputEventJoypadButton.new()
		jb.button_index = b
		InputMap.action_add_event(action, jb)




func sfx(sfx_name: String, volume_db: = 0.0, pitch_jitter: = 0.05) -> void :
	if not _sfx.has(sfx_name) or _quitting:
		return
	if sfx_name in VOICE_SLOTS:
		if _voice_line.playing:
			if _queued_line.is_empty() or sfx_name in PRIORITY_LINES:
				_queued_line = [sfx_name, volume_db]
			return
		_play_line(sfx_name, volume_db)
		return
	var p: = _voices[_next_voice]
	_next_voice = (_next_voice + 1) % _voices.size()
	p.stream = _pick(sfx_name)
	p.volume_db = volume_db - 4.0
	p.pitch_scale = 1.0 + randf_range( - pitch_jitter, pitch_jitter)
	p.play()




func pick(slot: String) -> AudioStream:
	return _pick(slot) if _sfx.has(slot) else null



func _pick(slot: String) -> AudioStream:
	var clips: Array = _sfx[slot]
	var i: = randi() % clips.size()
	if clips.size() > 1 and i == _last_pick.get(slot, -1):
		i = (i + 1 + randi() % (clips.size() - 1)) % clips.size()
	_last_pick[slot] = i
	return clips[i]


func _play_line(slot: String, volume_db: float) -> void :
	_voice_line.stream = _pick(slot)
	_voice_line.volume_db = volume_db - 2.0
	_voice_line.play()


func _play_queued_line() -> void :
	if _queued_line.is_empty() or _quitting:
		return
	var q: = _queued_line
	_queued_line = []
	_play_line(q[0], q[1])


func _setup_music() -> void :

	_music = AudioStreamPlayer.new()
	_music.stream = load("res://assets/audio/ambient.wav")
	_music.volume_db = -16.0
	add_child(_music)
	_music.play()




func start_game() -> void :
	failures = 0
	go_to_level(0)


func go_to_level(index: int) -> void :
	current_level = index
	change_scene(LEVELS[index])


func restart_level() -> void :
	change_scene(LEVELS[current_level])


func to_main_menu() -> void :
	change_scene(MAIN_MENU)


func get_character_texture(char_name: String) -> Texture2D:
	if _char_textures.has(char_name):
		return _char_textures[char_name]
	var path: = "res://assets/sprites/characters/%s.png" % char_name
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path)
	if tex:
		_char_textures[char_name] = tex
	return tex


func add_coins(amount: int) -> void:
	coins += amount
	save_game()


func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		save_game()
		return true
	return false


func is_char_unlocked(char_name: String) -> bool:
	return char_name in unlocked_characters


func unlock_character(char_name: String, pay_coins: bool = true) -> bool:
	if is_char_unlocked(char_name):
		return true
	var cost: int = CHAR_COSTS.get(char_name, 0)
	if pay_coins and cost > 0:
		if not spend_coins(cost):
			return false
	unlocked_characters.append(char_name)
	current_character = char_name
	save_game()
	return true


func select_character(char_name: String) -> void:
	if is_char_unlocked(char_name):
		current_character = char_name
		save_game()


func is_level_unlocked(lvl_idx: int) -> bool:
	return lvl_idx < unlocked_levels


func save_game() -> void:
	var data: = {
		"coins": coins,
		"unlocked_characters": unlocked_characters,
		"current_character": current_character,
		"unlocked_levels": unlocked_levels,
	}
	var f: = FileAccess.open("user://memebounce_save.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()


func load_game() -> void:
	if not FileAccess.file_exists("user://memebounce_save.json"):
		return
	var f: = FileAccess.open("user://memebounce_save.json", FileAccess.READ)
	if f:
		var json_str: = f.get_as_text()
		f.close()
		var parsed = JSON.parse_string(json_str)
		if parsed is Dictionary:
			if parsed.has("coins"):
				coins = int(parsed["coins"])
			if parsed.has("unlocked_characters") and parsed["unlocked_characters"] is Array:
				unlocked_characters = parsed["unlocked_characters"]
			if parsed.has("current_character") and parsed["current_character"] is String:
				current_character = parsed["current_character"]
			if parsed.has("unlocked_levels"):
				unlocked_levels = clampi(int(parsed["unlocked_levels"]), 1, LEVELS.size())


func level_completed() -> void :
	if test_mode:
		return

	add_coins(15) # Earn 15 coins per completed level!
	if current_level + 2 > unlocked_levels:
		unlocked_levels = mini(current_level + 2, LEVELS.size())
		save_game()
	
	var next_char: = ""
	if current_level == 0 and not "bunny" in unlocked_characters:
		next_char = "bunny"
	elif current_level == 1 and not "mushroom" in unlocked_characters:
		next_char = "mushroom"
	elif current_level == 2 and not "detective" in unlocked_characters:
		next_char = "detective"
	
	if next_char != "":
		unlocked_characters.append(next_char)
		current_character = next_char
		save_game()
		_show_unlock_modal(next_char)
		return
	
	_advance_next_level()


func _advance_next_level() -> void :
	if current_level + 1 < LEVELS.size():
		go_to_level(current_level + 1)
	else:
		change_scene(END_SCREEN)


func _show_unlock_modal(char_name: String) -> void :
	var layer: = CanvasLayer.new()
	layer.layer = 250
	layer.process_mode = Node.PROCESS_MODE_ALWAYS

	var rect: = ColorRect.new()
	rect.color = Color(0.04, 0.05, 0.1, 0.95)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(rect)

	var vp_sz: = get_viewport().get_visible_rect().size

	var title: = Label.new()
	title.text = "NEW CHARACTER CLAIMED!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.1))
	title.size = Vector2(vp_sz.x, 20.0)
	title.position = Vector2(0, 14.0)
	layer.add_child(title)

	var full_tex: = get_character_texture(char_name)
	if full_tex:
		var icon_rect: = TextureRect.new()
		var atlas: = AtlasTexture.new()
		atlas.atlas = full_tex
		atlas.region = Rect2(0, 0, 16, 16)
		icon_rect.texture = atlas
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var sz: = 48.0
		icon_rect.size = Vector2(sz, sz)
		icon_rect.position = Vector2((vp_sz.x - sz) / 2.0, (vp_sz.y - sz) / 2.0 - 10.0)
		layer.add_child(icon_rect)

	var name_lbl: = Label.new()
	name_lbl.text = CHAR_NAMES.get(char_name, char_name.to_upper())
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0))
	name_lbl.size = Vector2(vp_sz.x, 20.0)
	name_lbl.position = Vector2(0, vp_sz.y / 2.0 + 20.0)
	layer.add_child(name_lbl)

	var sub_lbl: = Label.new()
	sub_lbl.text = "Previous character replaced! Bounce back stronger!"
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
	sub_lbl.size = Vector2(vp_sz.x, 20.0)
	sub_lbl.position = Vector2(0, vp_sz.y - 28.0)
	layer.add_child(sub_lbl)

	get_tree().root.add_child(layer)
	sfx("complete")

	await get_tree().create_timer(2.6, true, false, true).timeout
	if is_instance_valid(layer):
		layer.queue_free()
	_advance_next_level()




func change_scene(path: String) -> void :
	if _changing:
		return
	_changing = true
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	_changing = false
