# Currently does not engage the treads, just the levelling arms





def make_arm_interpolater(left_min, left_max, right_min, right_max):
	# Figure out how 'wide' each range is
	leftSpan = left_max - left_min
	rightSpan = right_max - right_min

	# Compute the scale factor between left and right values
	scaleFactor = float(rightSpan) / float(leftSpan)

	# create interpolation function using pre-calculated scaleFactor
	def interp_fn(value):
		return right_min + (value-left_min)*scaleFactor

	return interp_fn




class ModeDrive:
	def __init__(self, joy, frontArm, rearArm):
		self.joy = joy
		self.rearArm = rearArm
		self.frontArm = frontArm
		self.frontArmRanger = make_arm_interpolater(-1,1,frontArm.minPos,frontArm.maxPos)
		self.rearArmRanger = make_arm_interpolater(-1,1,rearArm.minPos,rearArm.maxPos)

	def update(self):

		rt = self.joy.get_axis(5)

		arm_val = self.tempWheelRanger(rt)
		self.frontArm.directSet(int(arm_val))
	

		
		print("updating arms")