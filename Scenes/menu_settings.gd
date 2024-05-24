extends Control

signal open_settings_menu()
signal pause_game(enable: bool)

func _ready():
	pause_game.connect(menu_pause_game)
	
	var display_mode_button = get_node("PanelContainer/MarginContainer/SettingsMenu/DisplayMode/Dropdown")
	display_mode_button.item_selected.connect(change_display_mode)
	
	var quit_button = get_node("PanelContainer/MarginContainer/SettingsMenu/Quit")
	quit_button.button_up.connect(close_game)

func _input(_event):
	if Input.is_action_just_pressed("Settings"):
		open_settings_menu.emit()
		if self.visible == true:
			pause_game.emit(true)
		else:
			pause_game.emit(false)

func close_game():
	get_tree().quit()

func menu_pause_game(enable: bool): #pauses game while menu is up
	get_tree().paused = enable #FIXME: player x velocity only enables when button is held down, and players stop holding buttons on menu screens

func change_display_mode(mode):
	if mode == 0: #fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	if mode == 1: #windowed
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
