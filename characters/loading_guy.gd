extends Node2D

func _ready():
    $guy_animation_player.play('falling_asleep_2')
    connect('visibility_changed', self, 'on_visible_changed')

func on_visible_changed():
    if self.visible:
        $guy_animation_player.play("falling_asleep_2")
        $guy_animation_player.seek(0)
        $guy_animation_player.queue("sleeping")