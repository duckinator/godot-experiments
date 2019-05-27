extends Node

# All the signals this script can emit.
signal peer_connected
signal peer_disconnected
signal connection_failed
signal server_disconnected

var network_peer = null setget set_network_peer, get_network_peer

var remote_address = null
var remote_port = null
var local_address = null
var local_port = null

# Default values.
const DEFAULT_PORT = 9876
const DEFAULT_MAX_PLAYERS = 20


var players = {}

# Default network game settings -- actually populated in _ready().
var settings = null

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Default player names are formatted as "Player<random number>".
	settings = { name = "Player" + str(rng.randi_range(1, 9999)) }
	
	# Connect signals on the scene tree to functions in this file.
	# Some of those functions will then emit other signals.
	var tree = get_tree()
	tree.connect("network_peer_connected", self, "peer_connected")
	tree.connect("network_peer_disconnected", self, "peer_disconnected")
	tree.connect("connected_to_server", self, "connected_to_server")
	tree.connect("connection_failed", self, "connection_failed")
	tree.connect("server_disconnected", self, "server_disconnected")

# Forces the server to include itself in the (local) list of players.
func add_self_if_needed():
	if is_server():
		register_player(1, settings)

# Sets the local network peer to `peer` (a NetworkedMultiplayerENet instance).
#
# Also stores it, so get_network_peer() can retrieve it later.
func set_network_peer(peer):
	var tree = get_tree()
	tree.set_network_peer(peer)
	tree.set_meta("network_peer", peer)

# Returns the value stored via `set_network_peer(peer)`
func get_network_peer():
	return get_tree().get_meta("network_peer")

# Return the port being listened on, if we're a server.
func get_port():
	if not is_server():
		return null
	
	return get_network_peer()

# Return the unique network ID for the current system.
func get_unique_id():
	return get_tree().get_network_unique_id()

# Allow new network connections.
func allow_connections():
	get_tree().refuse_new_network_connections = false

# Block new network connections.
func block_connections():
	get_tree().refuse_new_network_connections = true


# Returns true if this instance of the game is the server, false otherwise.
func is_server():
	return get_tree().is_network_server()

# Start a server listening on `port`, and allow only `max_players` players.
#
# If `port` is unspecified/null, default to DEFAULT_PORT.
# If `max_players` is unspecified/null, default to DEFAULT_MAX_PLAYERS.
func start_server(port=null, max_players=null):
	if port == null:
		port = DEFAULT_PORT
	if max_players == null:
		max_players = DEFAULT_MAX_PLAYERS
	var peer = NetworkedMultiplayerENet.new()
	
	remote_address = null
	remote_port = null
	local_address = null
	local_port = port
	
	var err = peer.create_server(port, max_players)
	if err != OK:
		printerr("ERROR: Network.start_server(): ", err)
		return
	set_network_peer(peer)
	add_self_if_needed()

# Connect to a server listening on `address`, port `port`.
#
# If `port` is unspecified/null, default to DEFAULT_PORT.
func join(address, port=null):
	if port == null:
		port = DEFAULT_PORT
	
	remote_address = address
	remote_port = port
	local_address = null
	local_port = null
	
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client(address, port)
	if err != OK:
		printerr("ERROR: Network.join(): ", err)
		return
	set_network_peer(peer)

# Disconnect the game from the network.
func quit():
	get_network_peer().close_connection()
	set_network_peer(null)

# Runs when each client connects.
# Currently unused. register_player() emits the "peer_connected" event.
func peer_connected(id):
	pass

# Runs when a client disconnects.
func peer_disconnected(id):
	var info = players[id]
	players.erase(id)
	emit_signal("peer_disconnected", id, info)

# Only called on clients, not server. Sends this clients ID to the server.
# The server will then send it to everyone else.
func connected_to_server():
    rpc("register_player", get_unique_id(), settings)

func connection_failed():
	emit_signal("connection_failed")

func server_disconnected():
	emit_signal("server_disconnected")

remote func register_player(id, info):
	# Store the info -- for both clients and servers.
	players[id] = info
	
	# We put a special-case here so that the server doesn't send info to itself (when id==1),
	# so that we don't have to duplicate the rest of the function.
	if is_server() and id != 1:
		# Send our info the player.
		rpc_id(id, "register_player", 1, settings)
		
		# Send _everyone else's_ info to the player.
		for peer_id in players.keys():
			rpc_id(id, "register_player", peer_id, players[peer_id])
	
	emit_signal("peer_connected", id, info)
