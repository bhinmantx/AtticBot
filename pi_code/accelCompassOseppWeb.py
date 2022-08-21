import http.server
import json
import time
import smbus
import math
import board
import digitalio
import adafruit_lis3dh
import sys
import requests
import os
import math

import psutil

import argparse
import busio

import adafruit_mlx90640 



#from gpiozero import LoadAverage
from gpiozero import CPUTemperature




#cap = cv2.VideoCapture(0)




INTERPOLATE = 10

# MUST set I2C freq to 1MHz in /boot/config.txt
i2c = busio.I2C(board.SCL, board.SDA)

# low range of the sensor (this will be black on the screen)
MINTEMP = 20.0
# high range of the sensor (this will be white on the screen)
MAXTEMP = 50.0



n = len(sys.argv)

for i in range(1, n):
    print(sys.argv[i], end = " ")

if n >= 2: #allows us to change the range of interest. TARGET_TEMP is supposed to be near a particular temp of interest (such as the body temp of a possum)
    MINTEMP = float(sys.argv[1])
    MAXTEMP = float(sys.argv[2])

heat_settings = { #allows us to update them from the web endpoint
    'MINTEMP':MINTEMP,
    'MAXTEMP':MAXTEMP
}
heat_data = { 
    'readings':[]
}



# the list of colors we can choose from
heatmap = (
    (0.0, (0, 0, 0)),
    (0.20, (0, 0, 0.5)),
    (0.40, (0, 0.5, 0)),
    (0.60, (0.5, 0, 0)),
    (0.80, (0.75, 0.75, 0)),
    (0.90, (1.0, 0.75, 0)),
    (1.00, (1.0, 1.0, 1.0)),
)

# how many color values we can have
COLORDEPTH = 1000

colormap = [0] * COLORDEPTH




# some utility functions
def constrain(val, min_val, max_val):
    return min(max_val, max(min_val, val))


def map_value(x, in_min, in_max, out_min, out_max):
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min


def gaussian(x, a, b, c, d=0):
    return a * math.exp(-((x - b) ** 2) / (2 * c**2)) + d


def gradient(x, width, cmap, spread=1):
    width = float(width)
    r = sum(
        [gaussian(x, p[1][0], p[0] * width, width / (spread * len(cmap))) for p in cmap]
    )
    g = sum(
        [gaussian(x, p[1][1], p[0] * width, width / (spread * len(cmap))) for p in cmap]
    )
    b = sum(
        [gaussian(x, p[1][2], p[0] * width, width / (spread * len(cmap))) for p in cmap]
    )
    r = int(constrain(r * 255, 0, 255))
    g = int(constrain(g * 255, 0, 255))
    b = int(constrain(b * 255, 0, 255))
    return r, g, b


for i in range(COLORDEPTH):
    colormap[i] = gradient(i, COLORDEPTH, heatmap)




# initialize the sensor
mlx = adafruit_mlx90640.MLX90640(i2c)
print("MLX addr detected on I2C, Serial #", [hex(i) for i in mlx.serial_number])

mlx.refresh_rate = adafruit_mlx90640.RefreshRate.REFRESH_16_HZ

print(mlx.refresh_rate)
print("Refresh rate: ", pow(2, (mlx.refresh_rate - 1)), "Hz")

frame = [0] * 768
def get_heat():    
    global frame,colors
    readings=[]
    stamp = time.monotonic()
    try:
        mlx.getFrame(frame)
    except ValueError:
        print("exception")  # these happen, no biggie - retry

    print("Read 2 frames in %0.2f s" % (time.monotonic() - stamp))

    pixels = [0] * 768
    for i, pixel in enumerate(frame):
        coloridx = map_value(pixel, MINTEMP, MAXTEMP, 0, COLORDEPTH - 1)
        coloridx = int(constrain(coloridx, 0, COLORDEPTH - 1))
        pixels[i] = colormap[coloridx]

    for h in range(24):
        for w in range(32):            
            pixel = pixels[h * 32 + w]
            readings.append(pixels[h * 32 + w])
            #here is where we populate thing maybe?
    return readings

FILE = 'frontend2.html'
PORT = 8000
sensor_data_json = {
            'ltPost':0,'rtPos':0,
            'armServos':[ 
            0,0,0,0],
            "servoEPos":0,"servoFPos":0,
            'howhotobj':0,'ambient':0,
            'controlMode':0,
            'lastUpdate':0,
            }
accel_data = {
    'x':0,'y':0,'z':0
}

compass_data = {
    'heading':0,'other':0
}


sincelastUpdate = round(time.time() * 1000)
prev_update_time = 0

i2c = board.I2C()
int1 = digitalio.DigitalInOut(board.D6)  # Set this to the correct pin for the interrupt!
lis3dh = adafruit_lis3dh.LIS3DH_I2C(i2c, int1=int1)


class hmc5883l:

    __scales = {
        0.88: [0, 0.73],
        1.30: [1, 0.92],
        1.90: [2, 1.22],
        2.50: [3, 1.52],
        4.00: [4, 2.27],
        4.70: [5, 2.56],
        5.60: [6, 3.03],
        8.10: [7, 4.35],
    }

    def __init__(self, port=1, address=0x1E, gauss=1.3, declination=(0,0)):
        self.bus = smbus.SMBus(port)
        self.address = address

        (degrees, minutes) = declination
        self.__declDegrees = degrees
        self.__declMinutes = minutes
        self.__declination = (degrees + minutes / 60) * math.pi / 180

        (reg, self.__scale) = self.__scales[gauss]
        self.bus.write_byte_data(self.address, 0x00, 0x70) # 8 Average, 15 Hz, normal measurement
        self.bus.write_byte_data(self.address, 0x01, reg << 5) # Scale
        self.bus.write_byte_data(self.address, 0x02, 0x00) # Continuous measurement

    def declination(self):
        return (self.__declDegrees, self.__declMinutes)

    def twos_complement(self, val, len):
        # Convert twos compliment to integer
        if (val & (1 << len - 1)):
            val = val - (1<<len)
        return val

    def __convert(self, data, offset):
        val = self.twos_complement(data[offset] << 8 | data[offset+1], 16)
        if val == -4096: return None
        return round(val * self.__scale, 4)

    def axes(self):
        data = self.bus.read_i2c_block_data(self.address, 0x00)
        #print map(hex, data)
        x = self.__convert(data, 3)
        y = self.__convert(data, 7)
        z = self.__convert(data, 5)
        return (x,y,z)

    def heading(self):
        (x, y, z) = self.axes()
        headingRad = math.atan2(y, x)
        headingRad += self.__declination

        # Correct for reversed heading
        if headingRad < 0:
            headingRad += 2 * math.pi

        # Check for wrap and compensate
        elif headingRad > 2 * math.pi:
            headingRad -= 2 * math.pi

        # Convert to degrees from radians
        headingDeg = headingRad * 180 / math.pi
        return headingDeg

    def degrees(self, headingDeg):
        degrees = math.floor(headingDeg)
        minutes = round((headingDeg - degrees) * 60)
        return (degrees, minutes)

    def __str__(self):
        (x, y, z) = self.axes()
        return "Axis X: " + str(x) + "\n" \
               "Axis Y: " + str(y) + "\n" \
               "Axis Z: " + str(z) + "\n" \
               "Declination: " + self.degrees(self.declination()) + "\n" \
               "Heading: " + self.degrees(self.heading()) + "\n"


    
def getSystemStats():
    system_stats = {}
    cpu_temp = CPUTemperature().temperature
    cpu_load = cpu = str(psutil.cpu_percent()) + '%'

    system_stats["cpu_tempt"] = cpu_temp
    system_stats["cpu_load"] = cpu_load

    return system_stats



compass = hmc5883l(gauss = 4.7, declination = (-2,5))


class TestHandler(http.server.SimpleHTTPRequestHandler):
    """The test example handler."""
    lastUpdate = 0
    def do_POST(self):
        global sensor_data_json
        global MINTEMP,MAXTEMP
        if self.path == 'TELEMETRY':
            sincelastUpdate = round(time.time() * 1000) - prev_update_time
            #print(self.headers)
            length = int(self.headers.get_all('content-length')[0])
            #print(self.headers.get_all('content-length'))
            data_string = self.rfile.read(length)

            #print(data_string)
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.flush_headers()
            #sensor_data = {'Arch': 'pacman',
            #               'Gentoo': 'emerge'
            #}
            sensor_data_json = json.loads(data_string)
            sensor_data_json["lastUpdate"] = lastUpdate
            #self.wfile.write(sensor_data_json.encode())
            #print(sensor_data_json)

        self.wfile.write("".encode())
        if self.path == '/HEAT':
            length = int(self.headers.get_all('content-length')[0])

            data_string = self.rfile.read(length)

            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.flush_headers()

            heat_settings = json.loads(data_string)

            MINTEMP=heat_settings["MINTEMP"]
            MAXTEMP=heat_settings["MAXTEMP"]

            self.wfile.write("".encode())

    def do_GET(self):
        global sensor_data_json
        global heat_data
        #global heading_accel
        
        
        #print(self.headers)
        #length = int(self.headers.get_all('content-length')[0])
        #print(self.headers.get_all('content-length'))
        #data_string = self.rfile.read(length)
        #print(data_string)
        if self.path == '/TELEMETRY':
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.flush_headers()
            compass_data['heading'] = compass.degrees(compass.heading())[0]
            accel_data['x'], accel_data['y'], accel_data['z'] = lis3dh.acceleration

            system_stats = getSystemStats()
            heading_accel = {
                'compass_data':compass_data,
                'accel_data': accel_data,
                'system_stats': system_stats

            }
            #sensor_data_json = json.dumps(sensor_data_json)
            #outgoing_json = json.dumps(sensor_data_json)
            outgoing_json = json.dumps(heading_accel)
            #print(sensor_data_json)
            self.wfile.write(outgoing_json.encode())


        '''if self.path.startswith('/image'):
            self.send_response(200)
            self.send_header("Content-type", "image/jpeg")
            self.end_headers()
            ret, frame = cap.read()
            _, jpg = cv2.imencode(".jpg", frame)
            self.wfile.write(jpg)
        else:
            self.send_response(404)'''        
       
        #self.wfile.write(sensor_data_json.encode())

        if self.path == '/HEAT': 
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.flush_headers()
 
            heat_data['readings'] = get_heat()
            outgoing_json = json.dumps(heat_data)
            self.wfile.write(outgoing_json.encode())


        if self.path == '/image.jpg':
            self.send_response(404)
            self.end_headers()
            '''self.send_response(200)
            self.send_header("Content-type", "image/jpeg")
            self.end_headers()
            ret, frame = cap.read()
            _, jpg = cv2.imencode(".jpg", frame)
            self.wfile.write(jpg)
            '''
        if self.path == '/accel':
            #print(str(int(LoadAverage(minutes=1).load_average*100))+"%")
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.flush_headers()
            try: 
                accel_data['x'], accel_data['y'], accel_data['z'] = lis3dh.acceleration
            except Exception as e:
                print(e) 
            outgoing_json = json.dumps(accel_data)
            self.wfile.write(outgoing_json.encode())

    def log_message(self, format, *args): #silencing console
        pass
        


def start_server():
    """Start the server."""
    server_address = ("", PORT)
    server = http.server.HTTPServer(server_address, TestHandler)
    server.serve_forever()

start_server()