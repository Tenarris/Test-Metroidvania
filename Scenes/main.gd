extends Node2D

var projectile_scene: PackedScene = load("res://Scenes/projectile.tscn")
var enemy_projectile: PackedScene = load("res://Scenes/enemy_projectile.tscn")

func _ready():
	var menu_node = get_node("Menu/MenuSettings")
	menu_node.open_settings_menu.connect(on_open_settings)






func on_open_settings():
	$Menu/MenuSettings.visible = not $Menu/MenuSettings.visible

func _on_player_projectile_spawn(): #FIXME: figure out how to connect signals better
	var projectile_instance = projectile_scene.instantiate()
	$ProjectilesFolder.add_child(projectile_instance)

func _on_enemy_enemy_projectile_spawn():
	var enemy_projectile_instance = enemy_projectile.instantiate()
	$ProjectilesFolder.add_child(enemy_projectile_instance)



# Copied from CS Boat game for reference, so I remember:
# F1 is search documentation!!! (Class, methods, properties)
# Or ctrl click! (Pull up documentation or what u made)
