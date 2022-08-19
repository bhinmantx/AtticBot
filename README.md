# AtticBot
A control and telemetry system for a Pi based robot (Python) and a ground station (Processing.org)

## How it works

The AtticBot is a tank tread equipped bot based on the OSEPP Tritank with heavy modifications

![Imgur Image](https://i.imgur.com/cZR0PQR.png)

## Sensors and Imaging
The bot is equipped with the following
- 1 HD camera (USB)
- 2 FPV radio transmitter cameras (Front and back)
- IR Illuminator
- Heat vision camera
  - Proof of concept for heatvision overlay: https://i.imgur.com/RYSgZOK.mp4
- An autolevelling servo articulated arm 
  - Remote temperature sensor
  - LIDAR range finder
  - Aiming laser
  - IR enabled radio camera
- Second servo arm
  - Millimeter wave radar
  - Humidity and ambient temperature sensor
  - MQ-134 air quality sensor

## Bot health monitoring
- Each Lipo cell has a contact temperature sensor
- Drive and arm motors have contact temperature sensor
- 3 axis accelerometer for orientation
- compass
- MQ smoke detector 



