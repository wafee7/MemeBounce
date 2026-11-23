class_name Coin
extends Node2D

var sprite: Sprite2D
var _anim_t: float = 0.0
var _collected: bool = false
static var _coin_tex: Texture2D = null


static func get_tex() -> Texture2D:
	if _coin_tex:
		return _coin_tex
	var path: = "res://assets/sprites/coins/spr_coin_strip4.png"
	if FileAccess.file_exists(path):
		var img: = Image.load_from_file(path)
		if img:
			_coin_tex = ImageTexture.create_from_image(img)
	elif ResourceLoader.exists(path):
		_coin_tex = load(path)
	return _coin_tex


func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = get_tex()
	sprite.hframes = 4
	sprite.frame = 0
	add_child(sprite)


func hitbox() -> Rect2:
	return Rect2(position + Vector2(-6, -6), Vector2(12, 12))


func collect() -> void:
	if _collected:
		return
	_collected = true
	var g: Node = get_tree().root.get_node_or_null("Game") if get_tree() else null
	if g:
		var multiplier: int = 2 if (g.get("current_character") == "detective") else 1
		if g.has_method("add_coins"):
			g.add_coins(1 * multiplier)
		if g.has_method("sfx"):
			g.sfx("select", 5.0, 0.06)

	# Sparkle jump tween
	var tw: = create_tween()
	tw.tween_property(self, "position:y", position.y - 12.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "scale", Vector2(1.5, 1.5), 0.22)
	tw.parallel().tween_property(self, "modulate:a", 0.0, 0.22)
	tw.tween_callback(queue_free)


func _process(delta: float) -> void:
	if _collected:
		return
	_anim_t += delta
	if sprite:
		sprite.frame = int(_anim_t * 8.0) % 4
		sprite.position.y = sin(_anim_t * 4.0) * 1.5

	# Detective magnet effect: auto-attract coins within 52 pixels
	var g: Node = get_tree().root.get_node_or_null("Game") if get_tree() else null
	if g and g.get("current_character") == "detective":
		var p: Node2D = get_tree().root.find_child("Player", true, false) as Node2D
		if p and is_instance_valid(p):
			var dist: float = position.distance_to(p.position)
			if dist < 54.0 and dist > 1.0:
				position = position.move_toward(p.position, 130.0 * delta)
