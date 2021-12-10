extends Sprite
var screen_size
func _ready():
    screen_size = Vector2(600,600)
remote func set_op(value, frm):
    position = Vector2(value.x, screen_size.y-value.y)
    frame = frm