extends Spatial

const PLAYER = preload("res://player/Player.tscn")

remote var players = []

func rand_vec3(minimum, maximum):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var x = rng.randi_range(minimum, maximum)
	var z = rng.randi_range(minimum, maximum)
	return Vector3(x, 0, z)

func _ready():
	if Network.is_server(): 
		for id in Network.players.keys():
			var tag = Network.players[id]["name"]
			var player = PLAYER.instance()
			player.tag = tag
			add_child(player)
			player.remote_translate(rand_vec3(-20, 20))
			player.set_network_master(id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
