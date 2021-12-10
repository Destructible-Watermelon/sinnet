extends Sprite
signal hit
export var hit_frame_time = 0.15
var speed = 120
var screen_size
func _ready():
    screen_size = Vector2(600,600)
func _process(delta):
    var velocity = Vector2()
    if Input.is_action_pressed("ui_right"):
        velocity.x += 1
    if Input.is_action_pressed("ui_left"):
        velocity.x -= 1
    if Input.is_action_pressed("ui_down"):
        velocity.y += 1
    if Input.is_action_pressed("ui_up"):
        velocity.y -= 1
    if (position.y == 0 and velocity.y < 0) or (position.y == screen_size.y/2-10-64 and velocity.y > 0):
        velocity.y = 0
    if (position.x == 0 and velocity.x < 0) or (position.x == screen_size.x-64 and velocity.x > 0):
        velocity.x = 0
    if velocity.length() > 0:
        velocity = velocity.normalized()*speed
    position += velocity * delta
    position.x = clamp(position.x, 0, screen_size.x-64)
    position.y = clamp(position.y, 0, screen_size.y/2-10-64)
    if Input.is_action_just_pressed("ui_select") and frame == 0:
        hit_and_cool(velocity)
    rpc_unreliable("set_op", position, frame)
func hit_and_cool(vel):
    emit_signal("hit", name, vel)
    frame = 1
    $Timer.start(hit_frame_time)
    yield($Timer, "timeout")
    frame = 0
    