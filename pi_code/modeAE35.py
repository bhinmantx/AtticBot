#TODO
# the IR illuminator and main lamp are currently controlled via the shift register. I want to set that array here



class ModeAE35:
	def __init__(self, joy, lightPan,lightTilt, lightMain,lightIR):
		self.joy = joy
		self.lightPan = lightPan
		self.lightTilt = lightTilt
		self.lightMain = lightMain
		self.lightIR = lightIR
		self.frontArm = frontArm

	def update(self):

		'''
		DOWN = 0,-1
		UP = 0,1
		LEFT = -1,0
		RIGHT = 1,0
		'''
		lh = self.joy.get_hat(0)
		if lh[0] == -1: #left
			self.lightPan.updatePos(-4)
		if lh[0] == 1: #right
			self.lightPan.updatePos(4)
		if lh[1] == -1: #down
			self.lightTilt.updatePos(-4)
		if lh[1] == 1: #up
			self.lightTilt.updatePos(4)
