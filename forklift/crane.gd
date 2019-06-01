extends RigidBody2D

onready var pincers = [$left_pincer, $right_pincer]
onready var springs = [$left_pincer_top_spring, $left_pincer_bottom_spring, $right_pincer_top_spring, $right_pincer_bottom_spring]

onready var spring_rest_length = $left_pincer_top_spring.rest_length
var spring_displacement = 13

func adjust_pincer(dir = 1, amount = 0.1):
    for spring in springs:
        spring.rest_length = spring.rest_length - dir*amount
        spring.rest_length = clamp(spring.rest_length, spring_rest_length - spring_displacement, spring_rest_length)
        #spring.length = spring.rest_length

func _physics_process(delta: float) -> void:
    if Input.is_key_pressed(KEY_SHIFT):
        if Input.is_action_pressed('ui_right'):
            adjust_pincer(1)
        elif Input.is_action_pressed('ui_left'):
            adjust_pincer(-1)
    else:
        pass
#        if Input.is_action_pressed('up'):
#            $"../crane_hoist/DampedSpringJoint2D".rest_length -= 0.5
#            #self.position.y -= 0.5
#        elif Input.is_action_pressed('down'):
#            $"../crane_hoist/DampedSpringJoint2D".rest_length += 0.5
#            #self.position.y += 0.5
#        $"../crane_hoist/DampedSpringJoint2D".rest_length = max(1, $"../crane_hoist/DampedSpringJoint2D".rest_length)
