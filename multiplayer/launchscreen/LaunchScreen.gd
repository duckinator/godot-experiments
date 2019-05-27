extends Control

const LOBBY = preload("res://lobby/Lobby.tscn")

onready var vbox = $Panel/HBoxContainer/HBoxContainer/VBoxContainer
onready var server_button = vbox.get_node("StartServer")
onready var client_button = vbox.get_node("StartClient")

func _ready():
	server_button.connect("pressed", self, "start", [true])
	client_button.connect("pressed", self, "start", [false])

func start(is_server):
	get_tree().set_meta("starting_server", is_server)
	get_tree().change_scene_to(LOBBY)
