extends VehicleBody

const MAX_ACCEL = 100

const MAX_ENGINE_FORCE = 5000

const STEERING_LEFT = 0.5
const STEERING_RIGHT = -STEERING_LEFT
const STEERING_RESET_MULTIPLIER = 0.8

func _process(delta):
	# Hack until we add an actual Player scene.
	process_vehicle_movement(null, delta)

# This is called by the Player, if they're currently in the vehicle.
func process_vehicle_movement(player, delta):
	if Input.is_action_pressed("activate"):
		player.leave_vehicle(self)
		return
	
	if Input.is_action_pressed("hard_stop"):
		hard_stop()
		return
	
	if Input.is_action_pressed("forward"):
		adjust_acceleration(+MAX_ACCEL)
	elif Input.is_action_pressed("backward"):
		adjust_acceleration(-MAX_ACCEL)
	
	if Input.is_action_pressed("left"):
		adjust_steering(STEERING_LEFT / 2)
	elif Input.is_action_pressed("right"):
		adjust_steering(STEERING_RIGHT / 2)
	elif steering != 0:
		steering *= STEERING_RESET_MULTIPLIER

func adjust_steering(val):
	steering = clamp(steering + val, STEERING_RIGHT, STEERING_LEFT)

func adjust_acceleration(val):
	engine_force = clamp(engine_force + val, -MAX_ENGINE_FORCE, MAX_ENGINE_FORCE)
	brake = 0

func hard_stop():
	engine_force = 0
	brake = 5000