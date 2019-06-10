extends Area2D

func _ready():
    self.connect('area_entered', self, 'on_area_entered')

func on_area_entered(area):
    print('hey')