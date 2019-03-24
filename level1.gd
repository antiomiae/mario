extends Node2D

onready var camera = get_node("mario/camera")
onready var tilemap = get_node("TileMap")

const CONTINUE = preload("res://continue.tscn")

func _ready():
    var map_rect = tilemap.get_used_rect()
    var pos = map_rect.position
    var size = map_rect.size
    var cell_size = tilemap.cell_size
    camera.limit_left = pos.x * cell_size.x
    camera.limit_top = pos.y * cell_size.y
    camera.limit_right = (pos.x + size.x) * cell_size.x
    camera.limit_bottom = (pos.y + size.y) * cell_size.y

func _physics_process(delta):
    if $mario.global_position.y > camera.limit_bottom:
        call_deferred("do_continue")

func do_continue():
    var dialog = CONTINUE.instance()
    dialog.connect("choose_continue", self, "continue_chosen")
    Director.push_scene(dialog)

func continue_chosen():
    Director.pop_scene()
    get_tree().reload_current_scene()
