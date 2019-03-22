extends Node2D

onready var camera = get_node("mario/camera")
onready var tilemap = get_node("TileMap")

func _ready():
    var map_rect = tilemap.get_used_rect()
    var pos = map_rect.position
    var size = map_rect.size
    var cell_size = tilemap.cell_size
    camera.limit_left = pos.x * cell_size.x
    camera.limit_top = pos.y * cell_size.y
    camera.limit_right = (pos.x + size.x) * cell_size.x
    camera.limit_bottom = (pos.y + size.y) * cell_size.y

