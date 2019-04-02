extends Node2D

export(float) var speed = 67

func _physics_process(delta):
    var v = Vector2(0, 0)
    if Input.is_action_pressed("ui_left"):
        v.x -= 1
    if Input.is_action_pressed("ui_right"):
        v.x += 1
    if Input.is_action_pressed("ui_up"):
        v.y -= 1
    if Input.is_action_pressed("ui_down"):
        v.y += 1

    position += v * speed * delta

    if v.x != 0:
        $AnimationPlayer.play("run")
    else:
        $AnimationPlayer.play("stand")
