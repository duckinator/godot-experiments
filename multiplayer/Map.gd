extends Spatial

const PLAYER = preload("res://player/Player.tscn")

func rand_vec3(minimum, maximum):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var x = rng.randi_range(minimum, maximum)
	var z = rng.randi_range(minimum, maximum)
	return Vector3(x, 0, z)

func _ready():
	get_tree().paused = true
	
	for id in Network.players.keys():
		var tag = Network.players[id]["name"]
		var player = PLAYER.instance()
		player.name = str(id)
		player.tag = tag
		$Players.add_child(player)
		player.translate(rand_vec3(-20, 20))
		player.set_network_master(id)
	
	if Network.is_server():
		# Tell ourselve's we're ready, because we can't use RPC on ourself.
		game_ready(Network.get_unique_id())
	else:
		# Tell server this peer is done preparing.
		rpc_id(1, "game_ready", Network.get_unique_id())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var players_done = []
remote func game_ready(id):
	# If we're not the server, don't bother.
	if not Network.is_server():
		return
	
	# If it's a duplicate, ignore it.
	if id in players_done:
		return
	
	# If we don't know who it is, print an error and bail.
	if not id in Network.players.keys():
		printerr("ERROR: Map.gd/game_ready(): Unknown player id " + str(id))
		return
	
	players_done.append(id)
	
	if len(players_done) == len(Network.players):
		if Network.is_server():
			# Start the game locally, because RPC doesn't work for yourself.
			game_start()
		rpc("game_start")
	
remote func game_start():
	get_tree().paused = false