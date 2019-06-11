extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
    var fighters = get_tree().get_nodes_in_group('fighters')

    for fighter in fighters:
        if !fighter.dead:
            fighter.process_hits()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass