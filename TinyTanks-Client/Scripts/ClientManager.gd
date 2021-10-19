extends Node

# The URL we will connect to
export var websocket_url = "ws://localhost:8000"

# Our WebSocketClient instance
var _client = WebSocketClient.new()
var connect_counter := 0
var test_id = "XCLIENTX"
onready var lobby = get_tree().get_root().get_node("Lobby")

#timer values
export var check_msg_timer_val := 1.5
onready var check_msg_time = check_msg_timer_val

func _ready():
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")
	
	# Initiate connection to the given URL
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)

func _on_data():
	# you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	
	#parse then dmux message
	var payload = _client.get_peer(1).get_packet().get_string_from_utf8()

	#var id = payload.substr(0, 8)
	var type = payload.substr(8, 2)
	var msg = payload.substr(10, payload.length()-10)

	if(type=="02"):
		receive_chat(msg)

func _process(delta):
	check_msg_time -= delta
	if(check_msg_time < 0):
		check_msg_time = check_msg_timer_val
		check_chat()
		
	_client.poll()

func send_chat(text):
	var payload = test_id + "01" + text
	_client.get_peer(1).put_packet(payload.to_utf8())
	
func check_chat():
	var payload = test_id + "03"
	_client.get_peer(1).put_packet(payload.to_utf8())
	
func receive_chat(msg):
	lobby.receive_chat(msg)
	