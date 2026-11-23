class_name Billboard
extends Node2D



const SIZE: = Vector2(48, 48)
const BOARD: = Rect2(6, 10, 36, 36)

const NEON: = Color("#fde047")
const CAPTIONS: = ["HUH?", "BONK", "SHEESH", "BRO???", "NO WAY", "WOW", "MEOW", "RIZZ", 
	"POV: U FELL", "SUCH JUMP", "GG", "OOF", "SUS", "BASED", "COPIUM", "NOICE"]

var meme: Texture2D
var caption: = ""


func setup(p_meme: Texture2D, p_caption: String) -> void :
	meme = p_meme
	caption = p_caption


func _ready() -> void :
	z_index = -5
	var img: = Sprite2D.new()
	img.texture = meme
	img.scale = Vector2(0.5, 0.5)
	img.position = BOARD.get_center() - Vector2(0, SIZE.y)
	add_child(img)
	var lbl: = Label.new()
	lbl.text = caption
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.position = Vector2(-16, - SIZE.y)
	lbl.size = Vector2(SIZE.x + 32, 8)
	lbl.modulate = NEON
	add_child(lbl)


func _draw() -> void :
	var up: = Vector2(0, - SIZE.y)
	draw_rect(Rect2(BOARD.position + up, BOARD.size), NEON)
	draw_rect(Rect2(BOARD.position + up, BOARD.size).grow(-1), TileLayer.SILHOUETTE)
