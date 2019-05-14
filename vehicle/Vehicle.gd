extends VehicleBody

# When accelerating, this is the amount `engine_force`
# is increased by until `engine_force` reaches `MAX_ENGINE_FORCE`.
const ACCEL = 100

# The maximum value of `engine_force`.
# Note that this is not the same as speed, and will
# interact with other aspects of the vehicle.
const MAX_ENGINE_FORCE = 5000

# Controls the rate at which the wheels straighten out
# when you aren't actively steering.
#
# This should be between 0 and 1.
#
# 0.0   = wheels straighten out immediately.
# 1.0   = wheels can only be straightened manually.
export (float) var STEERING_RESET_MULTIPLIER = 0.8

# In the vehicle UI, the `steering` variable can be set
# to anything from -180 to +180.
#
# This means that, in theory, you could set STEERING_LEFT to 180.
#
# However, in my experience:
# - 0.1 to 0.9 work well
# - 1.0 makes it unable to turn
# - 1.1
# - 1.6+ has the fronts of wheels facing slightly backwards.
const STEERING_LEFT = 0.5
const STEERING_RIGHT = -STEERING_LEFT

func _process(delta):
	# If/when you add a Player scene, you can simply remove the next line
	# and call it from Player.
	process_vehicle_movement(null, delta)

# This is called by the Player, if they're currently in the vehicle.
func process_vehicle_movement(player, delta):
	if Input.is_action_pressed("hard_stop"):
		hard_stop()
		return
	
	if Input.is_action_pressed("forward"):
		adjust_acceleration(+ACCEL)
	elif Input.is_action_pressed("backward"):
		adjust_acceleration(-ACCEL)
	
	# When steering, we turn in smaller increments.
	# This means that simply tapping left/right will turn
	# a smaller amount than holding.
	if Input.is_action_pressed("left"):
		adjust_steering(STEERING_LEFT / 2)
	elif Input.is_action_pressed("right"):
		adjust_steering(STEERING_RIGHT / 2)
	elif steering != 0:
		# If we aren't going straight, and aren't actively steering,
		# this makes the wheels drift towards being straight.
		steering *= STEERING_RESET_MULTIPLIER

func adjust_steering(val):
	steering = clamp(steering + val, STEERING_RIGHT, STEERING_LEFT)

func adjust_acceleration(val):
	engine_force = clamp(engine_force + val, -MAX_ENGINE_FORCE, MAX_ENGINE_FORCE)
	brake = 0

func hard_stop():
	steering = 0
	engine_force = 0
	brake = 5000