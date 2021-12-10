extends Sprite
var velocity = Vector2(0,0)
var screen_size

signal scored
func _ready():
    screen_size = Vector2(600,600)
    $Timer.connect("timeout", self, "ball_start")
    if get_tree().is_network_server():
        new_ball()

func new_ball():
    velocity = Vector2(0,0)
    self.position= screen_size/2
    rpc("process_hit", position,velocity)
    $Timer.start()
    self.position= screen_size/2

func ball_start():
    velocity = Vector2(0,(-100))
    rpc("process_hit", position,velocity)

remote func process_hit(pos, vel):
    position = pos
    velocity = vel
    velocity.y = -velocity.y
    position.y = screen_size.y-position.y
func hit(player_speed): 
    velocity.x += player_speed.x
    velocity.x = clamp(velocity.x, -120, 120)
    velocity.y = 180*abs(sin(acos(player_speed.y/300)))
    rpc("process_hit", position, velocity)

func _process(delta):
    position += velocity*delta
    if position.x > (screen_size.x-8):
        position.x -= (position.x - (screen_size.x-8))*2
        velocity.x = -velocity.x
    elif position.x < 0:
        position.x = -position.x
        velocity.x = -velocity.x
    if not position.y > -8:
        emit_signal("scored")
