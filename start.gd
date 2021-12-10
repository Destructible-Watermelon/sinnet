extends Node2D

onready var text setget set_text
signal button_up
func _ready():
    $Button.connect("button_up", self, "_button_up")
    position = Vector2(600,600)/2

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
func set_text(value):
    $Label.text = value
func _button_up():
    emit_signal("button_up")