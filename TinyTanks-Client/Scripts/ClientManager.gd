extends Node

#https://generalistprogrammer.com/godot/godot-webassembly-export-to-web-html5-tutorial/
#host local server to run binary

# The URL we will connect to
#export var websocket_url = "ws://localhost:8000"
#location of my GCP instance
export var websocket_url = "ws://35.219.130.83:8000"
#export var websocket_url = "ws://127.0.0.1:8000"

# Our WebSocketClient instance
var _client = WebSocketClient.new()
var connect_counter := 0
var uid = "XCLIENTX"
onready var lobby = get_tree().get_root().get_node("Lobby")
var connectedIcon
var serverStatusLabel

func _ready():
	connectedIcon = get_tree().get_root().get_node("Lobby/connected icon")
	serverStatusLabel = get_tree().get_root().get_node("Lobby/serverStatusLabel")
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_connect_error")
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

func _connect_error(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Failed to connect (connection error): ", was_clean)
	serverStatusLabel.clear()
	serverStatusLabel.add_text("not connected to server")
	connectedIcon.modulate = Color(255, 0, 0)
	set_process(false)

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	serverStatusLabel.clear()
	serverStatusLabel.add_text("not connected to server")
	connectedIcon.modulate = Color(255, 0, 0)
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	connectedIcon.modulate = Color(0, 255, 0)
	serverStatusLabel.clear()
	serverStatusLabel.add_text("connected to server")

func _on_data():
	print("received a message")
	# you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	
	#parse then dmux message
	var payload = _client.get_peer(1).get_packet().get_string_from_utf8()

	var id = payload.substr(0, 8)
	var type = payload.substr(8, 2)
	var msg = payload.substr(10, payload.length()-10)

	if(type=="02"):
		receive_chat(msg)
		
	if(type=="03"):
		uid = msg;
		while(uid.length() < 8):
			uid += " "
		get_tree().get_root().get_node("Lobby/login").hide()

func _process(delta):
	_client.poll()

func send_chat(text):
	var payload = uid + "01" + text
	_client.get_peer(1).put_packet(payload.to_utf8())
	
func send_generic(id, type, content):
	var payload = id + type + content
	_client.get_peer(1).put_packet(payload.to_utf8())
	
func receive_chat(msg):
	lobby.receive_chat(msg)
	