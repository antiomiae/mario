extends Node2D

func _ready():
    $gui_layer/life_bar.set_lives_left($duck.lives_left)
    $duck.connect('life_lost', $gui_layer/life_bar, 'set_lives_left')
