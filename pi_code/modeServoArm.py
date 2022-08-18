
# IMPORTANT NOTE: This version of the controller is not mapped to the joystick position like the old version! This is a speed-of-movement based on position of stick!
# the servos will NOT reset if the joysticks go back to neutral
#

def make_arm_ranger(left_min, left_max, right_min, right_max):
		# Figure out how 'wide' each range is
	leftSpan = left_max - left_min
	rightSpan = right_max - right_min

	# Compute the scale factor between left and right values
	scaleFactor = float(rightSpan) / float(leftSpan)

	# create interpolation function using pre-calculated scaleFactor
	def level_fn(value):
		return right_min + (value-left_min)*scaleFactor

	return level_fn
	


class ModeServoArm:
	def __init__(self, joy, shoulderPan,shoulderTilt,leveller,sensorPan,sensorTilt,camNum,laser,spotLight):
		self.joy = joy
		self.shoulderPan = shoulderPan
		self.shoulderTilt = shoulderTilt
		self.leveller = leveller
		self.sensorPan = sensorPan
		self.sensorTilt = sensorTilt
		self.camNum = camNum
		self.laser = laser
		self.spotLight = spotLight
		self.levelFunc = make_arm_ranger(self.shoulderPan.minPos, self.shoulderPan.maxPos, self.leveller.maxPos, self.leveller.minPos)
		self.arm_ranger = make_arm_ranger(-1,1,-5,5)
		self.levellerTweak = 0

	def update(self):
		lsRL = self.joy.get_axis(0)
		lsUD = self.joy.get_axis(1)
		rsRL = self.joy.get_axis(3)
		rsUD = self.joy.get_axis(4)

		rb = self.joy.get_button(5)
		lb = self.joy.get_button(4)
		if(rb):
			self.levellerTweak += 1
		if(lb):
			self.levellerTweak -= 1
		shoulder_pan_change = self.arm_ranger(lsRL) 
		shoulder_tilt_change = self.arm_ranger(lsUD)
		sensor_pan_change =  self.arm_ranger(rsRL)
		sensor_tilt_change =  self.arm_ranger(rsUD)
		self.shoulderPan.updatePos(int(shoulder_pan_change))
		self.shoulderTilt.updatePos(int(shoulder_tilt_change))
		self.sensorPan.updatePos(int(sensor_pan_change))
		self.sensorTilt.updatePos(int(sensor_tilt_change))
		self.leveller_change = int(self.levelFunc(self.shoulderPan.current))
		self.leveller_change += self.levellerTweak
		print("leveller change: " + str(self.leveller_change) )

		self.leveller.directSet(self.leveller_change)
	


		#check each value in the joystick and update the proper servos/motors

