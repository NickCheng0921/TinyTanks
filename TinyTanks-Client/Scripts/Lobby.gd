extends Node2D

# Declare member variables here. Examples:
var sendChatBox
var receiveChatBox
var clientManager
# Called when the node enters the scene tree for the first time.
func _ready():
	sendChatBox = $"chatInputBox"
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

func _on_chatInputBox_text_changed():
	#check chat, if newline was entered, send msg
	sendChatBox.select_all()
	var text = sendChatBox.get_selection_text()
	if text.ends_with('\n'):
		sendChatBox.cut()
		text = text.strip_edges()
		if(text != ""):
			clientManager.send_chat(text)
	else:
		#if we get weird highlighting issues in the chat box, move this call before the if else to save the overhead of last char comparison
		sendChatBox.deselect()