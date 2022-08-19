#Modified from Adafruit example code! https://github.com/adafruit/Adafruit_MLX90640
#Stripped out some interpolation and display functions
#Added a web server to grab 


import http.server
import json
import time
import smbus
import sys
import requests
import os
import math

import argparse

import board
import busio

import adafruit_mlx90640 



PORT = 8001





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
mlx.refresh_rate = adafruit_mlx90640.RefreshRate.REFRESH_8_HZ
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



class TempHandler(http.server.SimpleHTTPRequestHandler):
    lastUpdate = 0 #for timeout warnings on telemetry 

    def do_GET(self):
        global heat_data
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

    def do_POST(self): #if we want to change our temperature range. TODO add the "target temp field"
        global MINTEMP,MAXTEMP
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

    def log_message(self, format, *args): #silencing console
        pass


        def start_server():

    server_address = ("", PORT)
    server = http.server.HTTPServer(server_address, TempHandler)
    server.serve_forever()

start_server()