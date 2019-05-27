extends Control

const LOBBY_SCENE = "res://lobby/Lobby.tscn"

onready var vbox = $Panel/HBoxContainer/HBoxContainer/VBoxContainer
onready var server_button = vbox.get_node("StartServer")
onready var address_lineedit = vbox.get_node("HBoxContainer/LineEdit")
onready var client_button = vbox.get_node("HBoxContainer/StartClient")
onready var quit_button = vbox.get_node("Quit")

func _ready():
	server_button.connect("pressed", self, "start", [true])
	client_button.connect("pressed", self, "start", [false])
	quit_button.connect("pressed", get_tree(), "quit")

func start(is_server):
	var address = address_lineedit.text
	if len(address.strip_edges()) == 0 and not is_server:
		return
	
	get_tree().set_meta("starting_server", is_server)
	get_tree().set_meta("server_address", address)
	return get_tree().change_scene(LOBBY_SCENE)
