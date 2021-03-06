extends Control

const LAUNCH_SCREEN_SCENE = "res://launchscreen/LaunchScreen.tscn"
const MAP_SCENE = "res://Map.tscn"
const FONT = preload("res://fonts/HackFont.tres")

onready var start_button = $HBoxContainer/VBoxContainer/StartButton
onready var vbox = $HBoxContainer/VBoxContainer/PlayersVBox
onready var template = vbox.get_node("TemplateLabel")
onready var server_information = $ServerInformation

var is_server = false

func _ready():
	var tree = get_tree()
	$AcceptDialog.connect("confirmed", self, "go_to_launch_screen")
	
	is_server = tree.get_meta("starting_server")
	
	var server_address = ["127.0.0.1", null]
	if tree.has_meta("server_address") and tree.get_meta("server_address") != null:
		server_address = Network.parse_address(tree.get_meta("server_address"))
	
	if is_server:
		Network.start_server(null, null) # TODO: Allow overriding port/max_connections
		server_information.text = "Listening on port " + str(Network.local_port)
	else:
		Network.join(server_address[0], server_address[1])
		server_information.text = Network.friendly_remote_address()
	
	Network.connect("peer_connected", self, "peer_connected")
	Network.connect("peer_disconnected", self, "peer_disconnected")
	Network.connect("connection_failed", self, "connection_failed")
	Network.connect("server_disconnected", self, "server_disconnected")
	add_existing_peers()
	
	if Network.is_server():
		start_button.connect("pressed", self, "start_game")
	else:
		start_button.visible = false

func connection_failed():
	popup("Failed to connect to server.")

func server_disconnected():
	popup("Server closed the connection.")

func popup(message):
	$AcceptDialog.dialog_text = message
	$AcceptDialog.popup_exclusive = true
	
	# Remove the close button (the X in the top-right), so people 
	# won't be stuck forever if they accidentally close it that way.
	$AcceptDialog.remove_child($AcceptDialog.get_close_button())
	
	$AcceptDialog.popup_centered()

func add_existing_peers():
	for id in Network.players.keys():
		peer_connected(id, Network.players[id])

func peer_connected(id, info):
	var player_name = info["name"]
	
	if vbox.has_node(str(id)):
		return
	
	var label = template.duplicate()
	label.visible = true
	label.name = str(id)
	label.text = player_name
	vbox.add_child(label)

func peer_disconnected(id, _info):
	for node in vbox.get_children():
		if node.name == str(id):
			vbox.remove_child(node)


func go_to_launch_screen():
	Network.quit()
	return get_tree().change_scene(LAUNCH_SCREEN_SCENE)

remote func start_game():
	if Network.is_server():
		Network.block_connections()
		for id in Network.players.keys():
			rpc_id(id, "start_game")
	return get_tree().change_scene(MAP_SCENE)
