extends Control

const FONT = preload("res://fonts/HackFont.tres")

onready var vbox = $HBoxContainer/VBoxContainer/PlayersVBox
onready var template = vbox.get_node("TemplateLabel")
onready var server_information = $ServerInformation

var is_server = false

func _ready():
	is_server = get_tree().get_meta("starting_server")
	Network.setup()
	if is_server:
		Network.start_server(null, null) # TODO: Allow overriding port/max_connections
		server_information.text = "Listening on port " + str(Network.local_port)
	else:
		Network.join("127.0.0.1") # TODO: Don't hard-code address.
		server_information.text = str(Network.remote_address) + ":" + str(Network.remote_port)

func _process(delta):
	for id in Network.players.keys():
		var player_name = Network.players[id]["name"]
		if not vbox.has_node(player_name):
			var label = template.duplicate()
			label.visible = true
			label.name = player_name
			label.text = player_name
			vbox.add_child(label)
	
	for label in vbox.get_children():
		if label.name == "TemplateLabel":
			continue
		for id in Network.players.keys():
			if Network.players[id]["name"] == label.name:
				continue
		# If we get here, it should be a disconnected client.
		vbox.remove_child(label)
		label.queue_free()
