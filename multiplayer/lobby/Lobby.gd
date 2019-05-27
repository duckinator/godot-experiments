extends Control

const LAUNCH_SCREEN_SCENE = "res://launchscreen/LaunchScreen.tscn"
const FONT = preload("res://fonts/HackFont.tres")

onready var vbox = $HBoxContainer/VBoxContainer/PlayersVBox
onready var template = vbox.get_node("TemplateLabel")
onready var server_information = $ServerInformation

var is_server = false

func _ready():
	var tree = get_tree()
	
	$AcceptDialog.connect("confirmed", self, "go_to_launch_screen")
	
	is_server = get_tree().get_meta("starting_server")
	Network.setup()
	if is_server:
		Network.start_server(null, null) # TODO: Allow overriding port/max_connections
		server_information.text = "Listening on port " + str(Network.local_port)
	else:
		Network.join("127.0.0.1") # TODO: Don't hard-code address.
		server_information.text = str(Network.remote_address) + ":" + str(Network.remote_port)
	
	Network.connect("peer_connected", self, "peer_connected")
	Network.connect("peer_disconnected", self, "peer_disconnected")
	Network.connect("connection_failed", self, "connection_failed")
	Network.connect("server_disconnected", self, "server_disconnected")
	add_existing_peers()

func connection_failed():
	popup("Failed to connect to server.")

func server_disconnected():
	popup("Server closed the connection.")

func popup(message):
	$AcceptDialog.dialog_text = message
	$AcceptDialog.dialog_hide_on_ok = true
	$AcceptDialog.popup_exclusive = true
	$AcceptDialog.popup_centered()

func add_existing_peers():
	for id in Network.players.keys():
		peer_connected(id, Network.players[id])

func peer_connected(id, info):
	var player_name = info["name"]
	print("PEER CONNECTED: " + player_name)
	
	if vbox.has_node(str(id)):
		return
	
	var label = template.duplicate()
	label.visible = true
	label.name = str(id)
	label.text = player_name
	vbox.add_child(label)

func peer_disconnected(id, info):
	print("PEER DISCONNECTED: " + info["name"])
	for node in vbox.get_children():
		if node.name == str(id):
			vbox.remove_child(node)


func go_to_launch_screen():
	Network.quit()
	get_tree().change_scene(LAUNCH_SCREEN_SCENE)
