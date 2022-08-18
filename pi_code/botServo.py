


#These are the channels on the PWM controller
SENSORARMSHOULDERPAN =  0
SENSORARMSHOULDERTILT =  1
SENSORARMLEVELLER = 2
SENSORPAN = 4
SENSORTILT = 3
LIGHTPAN = 5
LIGHTTILT = 6
FRONTARM = 7
REARARM = 8



#By default "start" is max minus min /2 
#Dunno how we're going to mess with busses if we end up splitting telemetry between the two

class BotServo:
    def __init__(self, name, minPos,maxPos,channel, bus, start):
        self.name = name
        self.minPos = minPos
        self.maxPos = maxPos
        self.channel = channel
        self.bus = bus
        self.start = start
        self.tick = 0 #what if our update is faster than our communication? 
        self.current = start
    def updatePos(self,change):
    	self.current = self.current + change
    	if (self.current > self.maxPos):
    		self.current = self.maxPos
    	if (self.current < self.minPos):
    		self.current = self.minPos
    	print(str(self.name) + ' ' + str(self.current) )
    def directSet(self,setting): #dangerous! We have a check for the min/max but it's possible it gets pulled early
    	self.current = setting
    	if (self.current > self.maxPos):
    		self.current = self.maxPos
    	if (self.current < self.minPos):
    		self.current = self.minPos
    	print(str(self.name) + ' ' + str(self.current) )


shoulderPan = BotServo("shoulderPan",156,470,SENSORARMSHOULDERPAN,0,307)
shoulderTilt = BotServo("shoulderTilt",158,370,SENSORARMSHOULDERTILT,0,184)
shoulderLeveller = BotServo("shoulderLeveller",90,470,SENSORARMLEVELLER,0,270)
sensorPan = BotServo("sensorPan",120,400,SENSORPAN,0,260)
sensorTilt = BotServo("sensorTilt",120,330,SENSORTILT,0,200)
lightPan = BotServo("lightPan",100,420,LIGHTPAN,0,260)
lightTilt = BotServo("lightTilt",130,310,LIGHTTILT,0,200)
frontArm = BotServo("frontArm",130,400,FRONTARM,0,130)
rearArm= BotServo("rearArm",130,310,REARARM,0,200)

allservos = [shoulderPan,shoulderTilt,shoulderLeveller,sensorPan,sensorTilt,lightPan,lightTilt,frontArm,rearArm]


