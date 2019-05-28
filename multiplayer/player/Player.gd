extends KinematicBody

const VELOCITY = 50

var tag = null
var vel = null

func _ready():
	pass

func _process(delta):
	if get_network_master() != Network.get_unique_id():
		return
	
	var movement = Vector3()
	if Input.is_action_pressed("movement_forward"):
		movement.z -= Input.get_action_strength("movement_forward")
	if Input.is_action_pressed("movement_backward"):
		movement.z += Input.get_action_strength("movement_backward")
	if Input.is_action_pressed("movement_left"):
		movement.x -= Input.get_action_strength("movement_left")
	if Input.is_action_pressed("movement_right"):
		movement.x += Input.get_action_strength("movement_right")
	movement = movement.normalized()
	vel = movement * VELOCITY
	vel = move_and_slide(vel)

remote func remote_translate(trans):
	translation = trans
