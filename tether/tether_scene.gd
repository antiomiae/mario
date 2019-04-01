extends Node2D

func _ready():
    #$TetherAnchorNode.color = Color(0, 0.846161, 0.910156)

    $DebugCharacter/GrapplingHook.attach_to_anchor($TetherAnchorNode/StaticBody2D, Vector2(-8, 0))