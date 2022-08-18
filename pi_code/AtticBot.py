'''

TODO
1. Assign permanent servo channels
2. Determine range and starting points for those servos
3. Experiments with auto leveling  

'''

from __future__ import division
import time
from time import sleep
from botServo import *
from modeServoArm import *
from modeAE35 import *
from modeDrive import *

# Import the PCA9685 module.
import Adafruit_PCA9685
#and the motor driver
from adafruit_motorkit import MotorKit 
import pygame, sys
import os
from pygame.locals import *

from smbus import SMBus

import datetime
from collections import defaultdict


addr = 0x8 # bus address
bus = SMBus(1) # indicates /dev/ic2-1
# Servo controller
pwm = Adafruit_PCA9685.PCA9685(address=0x42)
kit = MotorKit() # default address

# Set frequency to 60hz, good for servos.
pwm.set_pwm_freq(60)


#Set max servo freq for the wheel base extender
wheel_min = 315
wheel_max  = 415

'''
1. Get input from controller
2. Has mode changed?
3. update mode variable. Else, use "switch" (mode number)
'''









# Helper function to make setting a servo pulse width simpler.
def set_servo_pulse(channel, pulse):
    pulse_length = 1000000    # 1,000,000 us per second
    pulse_length //= 60       # 60 Hz
    #print('{0}us per period'.format(pulse_length))
    pulse_length //= 4096     # 12 bits of resolution
    #print('{0}us per bit'.format(pulse_length))
    pulse *= 1000
    pulse //= pulse_length
    pwm.set_pwm(channel, 0, pulse)


screen = pygame.display.set_mode([10,10])
pygame.joystick.init() #find the joysticks
joy = pygame.joystick.Joystick(0)
joy.init()
if(joy.get_name()=='Sony Entertainment Wireless Controller'):
	print("DS4 connected")
else:
	print("Not a DS4")
def make_interpolater(left_min, left_max, right_min, right_max):
	# Figure out how 'wide' each range is
	leftSpan = left_max - left_min
	rightSpan = right_max - right_min

	# Compute the scale factor between left and right values
	scaleFactor = float(rightSpan) / float(leftSpan)

	# create interpolation function using pre-calculated scaleFactor
	def interp_fn(value):
		return right_min + (value-left_min)*scaleFactor

	return interp_fn

clear = lambda: os.system('clear')
ranger = make_interpolater(-1,1,-5,5)

arm_mode = ModeServoArm(joy,shoulderPan,shoulderTilt,shoulderLeveller,sensorPan,sensorTilt,0,1,2)
ae35_mode = ModeAE35(joy,lightPan,lightTilt,0,1,frontArm)
drive_mode = ModeDrive(joy,frontArm,rearArm)
#Ranger = make_interpolater(1,-1,85,45)




debounceTimer = 0

rightNow = datetime.datetime.now()
debounce = False

debounceLimit = 10


wheelRanger = make_interpolater(1,-1,wheel_max,wheel_min)



while True:

	rightNow = datetime.datetime.now()
	

	mdelta = int(rightNow.timestamp() * 1000)
	if mdelta - debounceTimer > debounceLimit :
		debounce = False
		debounceTimer = mdelta



	pygame.event.get()

	telemetry_data = {} #servo positions and anything else we can think of


	'''
	#Alternate bindings of PS4 controller prevented further event checking
	#The pygame version does have issues with the center touch pad and the button clicks (R3, L3)
	#But it doesn't monopolize the app 
	a0 = left stick left right
	a1 = left stick   Up Down
	a2 = Left Trigger
	a3 = right stick left right
	a4 = right stick up down
	a5 =  Right trigger

	lsRL = joy.get_axis(0)
	lsUD = joy.get_axis(1)
	rsRL = joy.get_axis(3)
	rsUD = joy.get_axis(4)

	rt = joy.get_axis(5)
	lt = joy.get_axis(2)
	
	rb = joy.get_button(5)
	lb = joy.get_button(4)
	lh0 = joy.get_hat(0) 

	'''


	#Should break the debounce out for each button
	if not debounce :

		arm_mode.update()
		ae35_mode.update()

		rtPos = int(abs(wheelRanger (rt)))
		ltPos = int(abs(wheelRanger (lt)))

		debounce = True
		debounceLimit = 1

	try:
		#These values are set in the "Mode" classes
		#I'm updating everything here at once			
		pwm.set_pwm(SENSORARMSHOULDERPAN, 0, shoulderPan.current)
		pwm.set_pwm(SENSORARMSHOULDERTILT, 0, shoulderTilt.current)
		pwm.set_pwm(SENSORARMLEVELLER, 0, shoulderLeveller.current) #automated 
		pwm.set_pwm(SENSORPAN, 0, sensorPan.current)
		pwm.set_pwm(SENSORTILT, 0, sensorTilt.current)
		pwm.set_pwm(LIGHTPAN, 0, lightPan.current)
		pwm.set_pwm(LIGHTTILT, 0, lightTilt.current)
		pwm.set_pwm(FRONTARM,0,frontArm.current)

	except Exception as e:
		print(e)		


	
	#while data != 0:  #disabled the data since we're not pulling info from the i2c bus right now
	#	out = out + str(data)
	#	data = bus.read_byte(addr)
	#print(data.decode('utf-8'))
	os.system('cls' if os.name == 'nt' else 'clear') #a way to blank the console
	time.sleep(.01)
	print(shoulderLeveller.current) #checking that automated leveller
	