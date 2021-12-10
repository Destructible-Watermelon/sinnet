extends Panel
signal connect_attempted
func _ready():
    $Node/Button.connect("button_up", self, "_on_Button_button_up")
    self.rect_size = Vector2(600,600)
func _on_Button_button_up():
    emit_signal("connect_attempted",$Node/TextEdit.text if $Node/TextEdit.text != "" else null, $Node/TextEdit2.text)