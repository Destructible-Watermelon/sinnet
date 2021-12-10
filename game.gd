extends Node2D
var screen_size
var peer_connected
signal peer_registered
signal server_connected
signal self_readied
signal opponent_readied
var names
var score
var opponent_ready = false
const Player = preload("res://Player.tscn")
const Opponent = preload("res://Opponent.tscn")
func _ready():
    get_tree().paused = true

    $Connect.connect("connect_attempted", self, "_on_Connect_connect_attempted")

    get_tree().connect("connection_failed", self, "_on_connection_failed")

    get_tree().connect("connected_to_server", self, "_on_connected_to_server")

    $Playfield/Node.connect("game_won", self, "handle_game_win")
    screen_size = Vector2(600,600)

    $Timer2.connect("timeout", self, "hide_counter")

func _on_Connect_connect_attempted(ip, port):
    if ip is String and ip != "":
        initialise_client(ip, port as int)
        yield(self, "server_connected")
        
    else:
        initialise_server(port as int)
        if not peer_connected:
            yield(self, "peer_registered")
    $Connect.visible = false
    names = ["1", "2"] if get_tree().is_network_server() else ["2", "1"]
    $Playfield/Node/our_score.set_name(names[0])
    $Playfield/Node/their_score.set_name(names[1])
    get_tree().paused = false
    set_players()
    prepare_start()

func _on_connection_failed():
    var message = Label.new()
    message.text = "\n\n\n\n\nconnection didn't work. restart?"
    $Connect/Node.add_child(message)
    
remote func peer_connect():
    peer_connected = true
    emit_signal("peer_registered")
    
func _on_connected_to_server():
    rpc("peer_connect")
    emit_signal("server_connected")

func initialise_server(port):
    var peer = NetworkedMultiplayerENet.new()
    peer.create_server(port, 1)
    get_tree().set_network_peer(peer)
    var message = Label.new()
    message.text = "\n\n\n\ninitialised server"
    $Connect/Node.add_child(message)


func initialise_client(ip, port):
    var peer = NetworkedMultiplayerENet.new()
    peer.create_client(ip, port)
    get_tree().set_network_peer(peer)
    var message = Label.new()
    message.text = "\n\n\n\ninitialised client"
    $Connect/Node.add_child(message)
remotesync func set_players():
    var our_player
    var their_player
    if not $Playfield/Players.get_children():
        our_player = Player.instance()
        their_player = Opponent.instance()
        $Playfield/Players.add_child(our_player)
        $Playfield/Players.add_child(their_player)
        our_player.set_name(names[0])
        their_player.set_name(names[1])
        our_player.connect("hit", self, "attempt_hit")
    else:
        our_player= $Playfield/Players.get_node(names[0])
        their_player= $Playfield/Players.get_node(names[1])
    their_player.position.x = screen_size.x/2-32
    their_player.position.y = screen_size.y*5/6+32
    our_player.position.x = screen_size.x/2-32
    our_player.position.y = screen_size.y/6-32
    our_player.rpc("set_op", our_player.position,our_player.frame)
remotesync func unpause():
    get_tree().paused = false
remotesync func pause():
    get_tree().paused = true
func game_start():
    var i = 0
    opponent_ready = false
    rpc("pause")
    rpc("zero_score")
    rpc("show_counter")
    rpc("remove_starter")
    rpc("set_players")
    for i in range(1, 6):
        $Timer.start(1)
        yield($Timer, "timeout")
        rpc("counter_frame", i)
    rpc("unpause")
    $Timer2.start(0.5)
    rpc("add_ball")
func hide_counter():
    rpc("_hide_counter")
remotesync func _hide_counter():
    $Counter.visible = false
    $Counter.frame = 0
func attempt_hit(id, vel):
    var player = Rect2(get_node("Playfield/Players").get_node(id).position, Vector2(64,64))
    var ball = Rect2(get_node("Playfield/Ball").position-Vector2(8,8), Vector2(16,16))
    if player.intersects(ball):
        $Playfield/Ball.hit(vel)
remotesync func counter_frame(i):
    pass
    $Counter.frame = i
remotesync func add_ball():
    var Ball = preload("res://ball.tscn")
    $Playfield.add_child(Ball.instance())
    $Playfield/Ball.connect("scored", self, "handle_score")

func handle_score():
    rpc("add_score")
    score[1]+=1
    $Playfield/Node.set_score( score, names)
    $Playfield/Ball.new_ball()
remote func add_score():
    score[0]+=1
    $Playfield/Node.set_score( score, names)
remotesync func zero_score():
    score = [0,0]
    $Playfield/Node.set_score( score, names)
func handle_game_win(winner):
    $Playfield/Ball.queue_free()
    var txt = "you win!" if winner == 0 else "your opponent wins!"
    prepare_start(txt)
remote func op_ready():
    opponent_ready = true
    emit_signal("opponent_readied")
func set_ready():
    rpc("op_ready")
    emit_signal("self_readied")
remotesync func show_counter():
    $Counter.visible = true
remotesync func remove_starter():
    get_node("Start").queue_free()

func prepare_start(txt = null):
    var Start = preload("res://start.tscn")
    var game_starter = Start.instance()
    if txt: game_starter.text = txt
    add_child(game_starter)
    move_child($Start, 1)
    game_starter.connect("button_up",self,"set_ready")
    yield(self, "self_readied")
    $Timer.start(0.05)
    yield($Timer,"timeout")
    if not opponent_ready:
        yield(self, "opponent_readied")
    if get_tree().is_network_server():
        game_start()