extends Node2D

var axis_labels = []
var value_labels = []

onready var axis_container = $CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer
onready var value_container = $CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer2

func _ready():
    for i in range(JOY_AXIS_MAX):
        var label = Label.new()
        label.text = "{0}".format([i])
        axis_container.add_child(label)
        axis_labels.push_back(label)

        label = Label.new()
        label.text = "{0}".format([0.0])
        value_container.add_child(label)
        value_labels.append(label)

func _process(delta):
    for i in range(JOY_AXIS_MAX):
        value_labels[i].text = "{0}".format([Input.get_joy_axis(0, i)])