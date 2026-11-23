extends CanvasLayer


@onready var panel: Control = $Root
@onready var resume_btn: Button = $Root / Panel / Box / Resume


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	$Root / Panel / Box / Resume.pressed.connect(_resume)
	$Root / Panel / Box / Restart.pressed.connect(_restart)
	$Root / Panel / Box / Menu.pressed.connect(_menu)
	$Root / Panel / Box / Quit.pressed.connect(_quit)


func _unhandled_input(event: InputEvent) -> void :
	if event.is_action_pressed("pause"):
		if panel.visible:
			_resume()
		else:
			_open()
		get_viewport().set_input_as_handled()


func _open() -> void :
	get_tree().paused = true
	panel.visible = true
	resume_btn.grab_focus()
	Game.sfx("select")


func _resume() -> void :
	get_tree().paused = false
	panel.visible = false
	Game.sfx("select")


func _restart() -> void :
	Game.sfx("select")
	Game.restart_level()


func _menu() -> void :
	Game.sfx("select")
	Game.to_main_menu()


func _quit() -> void :
	Game.sfx("select")
	Game.quit_game()
