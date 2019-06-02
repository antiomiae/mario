extends RigidBody2D

var max_spring_length = 34
var min_spring_length = 5

onready var pincer_spring = $left_pincer/pincer_spring

func close(dir):
    pincer_spring.rest_length = clamp(pincer_spring.rest_length + dir, min_spring_length, max_spring_length)

#func _physics_process(delta: float) -> void:
