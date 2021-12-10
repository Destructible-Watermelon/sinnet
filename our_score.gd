extends Sprite

func _ready():
    var screen_size = Vector2(600,600)
    var scaling_factor = min(screen_size.x/800, screen_size.y/800)
    position.x = screen_size.x/2
    position.y = screen_size.y/8
    scale = Vector2(scaling_factor,scaling_factor)