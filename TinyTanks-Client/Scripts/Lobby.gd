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

func _on_password_button_button_up():
	$"login/username box".select_all()
	var id_txt = $"login/username box".get_selection_text()
	$"login/username box".cut()
	
	$"login/password box".select_all()
	var pass_txt = $"login/password box".get_selection_text()
	$"login/password box".cut()
	
	while(id_txt.length() < 8):
		id_txt += " "
	if(id_txt.length() > 8):
		id_txt = id_txt.substr(0, 8)
		
	clientManager.send_generic(id_txt, "00", pass_txt)
