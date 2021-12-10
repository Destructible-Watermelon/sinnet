extends ColorRect

func _ready():
    var size = Vector2(600,600)
    self.rect_size = size
    $Line.rect_size.x = size.x
    $Line.rect_position.y = (size.y/2-$Line.rect_size.y/2) as int
