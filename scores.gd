extends Node
signal game_won
func set_score(scores, names):
    get_node(names[0]).frame = scores[0]
    get_node(names[1]).frame = scores[1]
    if scores[0] == get_child(0).vframes-1:
        emit_signal("game_won", 0)
    elif scores[1] == get_child(0).vframes-1:
        emit_signal("game_won", 1)