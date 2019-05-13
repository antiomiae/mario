extends Node2D

export var total_lives := 7
export var lives_left := 7
export var spacing := 7

var _sprites = []

func _arrange_sprites():
    $Sprite.visible = false
    for i in range(_sprites.size()):
        var sprite:Sprite = _sprites[i]
        var width = sprite.get_rect().size.x
        sprite.position = Vector2(spacing*i, 0)

func _init_sprites():
    for i in range(total_lives):
        var sprite = $Sprite.duplicate()
        _sprites.push_back(sprite)
        add_child(sprite)

func _update_sprites():
    for i in range(total_lives):
        _sprites[i].visible = (i < lives_left)

func _ready():
    _init_sprites()
    _arrange_sprites()
    _update_sprites()

func set_lives_left(lives):
    lives_left = lives
    _update_sprites()