extends Node2D

# Declare member variables here. Examples:
var sendChatButton
var sendChatBox
var receiveChatBox
var clientManager
# Called when the node enters the scene tree for the first time.
func _ready():
	sendChatButton = $"sendChatButton"
	sendChatBox = $"chatInputBox"
	sendChatButton.connect("button_up", self, "send_chat")
	clientManager = $"ClientManager"
	receiveChatBox = $"receiveChatBox"

func send_chat():
	sendChatBox.select_all()
	var text = sendChatBox.get_selection_text()
	sendChatBox.cut()
	text = text.strip_edges()
	if(text != ""):
		clientManager.send_chat(text)

func receive_chat(text):
	#receiveChatBox.clear()
	receiveChatBox.add_text(text+'\n')