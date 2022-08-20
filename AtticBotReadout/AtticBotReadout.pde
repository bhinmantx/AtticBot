/*
Telemetry reader and some config for a Raspberry Pi based robot with several sensors.
 */

import picking.*; //n.clavaud.free.fr/cv/ Nicolas Clavaud


String TelemetryServer = "http://192.168.50.99:8000";
int NUM_TELEMS = 2; //really this should be just a constant and you enable various telemetry later


JSONObject attic_bot_data, accel_data, compass_data, telemetry_data;
JSONArray arm_data;
String[] font_list;

HudCompass compass; //currently offline, can be tested via mouse //see compassServer.py


PImage AE35CamFeed, MainDisplay, bgImage, fakeheat;
boolean NewImageAvailable = false;
int imageDelay = 200; //to slow down requests to the pi
int lastImageGet = 0;

ServoArm armData;
AccelData accelData;
LineGrapher grapher;
HeatVision heatVision;
Picker picker; //for mouse clicks to center a bit of telemetry
int lastPicked = -1;

Telemetry[] T_Enabled =  new Telemetry[NUM_TELEMS]; //Since parts of the robot can be active or inactive here's an easier way to track and activate



void setup() {
  size(1280, 1024, P3D);
  surface.setTitle("Attic Bot Telemetry");
  surface.setResizable(true);

  heatVision = new HeatVision(width/2, 200, this);
  picker = new Picker(this); //for clicking and centering
  armData = new ServoArm(10, 10, 0, 128, 0);
  accelData = new AccelData(50, 150, 100, 100, 100, picker, 0);
  grapher = new LineGrapher(100, 100, 100);
  compass = new HudCompass(0, 0, 100, 100, picker, 1);
  //AE35CamFeed = loadImage("http://192.168.50.99:8030/image.jpg");  //Should we convert AE35 stuff to a telemetry entry? It's from a different endpoint
  bgImage = loadImage("data/bgImage.png", "png"); //get something less boring!
  MainDisplay = AE35CamFeed;
  //thread("getNewImage"); //Parts of the Pi side are still offline. Should add the threading to its own "Enabled" array
  thread("updateHeatVision");

  T_Enabled[0] = accelData;
  T_Enabled[1] = compass ;
  println("added enabled telemetry!");
}


void draw() {
  background(100, 100, 100);

  imageMode(CENTER);
  image(bgImage, width/2, height/2);

  imageMode(CORNER);

  int rightNow = millis();
  if (rightNow - lastImageGet > imageDelay && NewImageAvailable) {

    //  MainDisplay = AE35CamFeed;
    NewImageAvailable = false;
    // thread("getNewImage"); //offline during testing
    thread("updateHeatVision");
    lastImageGet = rightNow;
    thread("updateHeatVision");
  }

  //AE35CamFeed = loadImage("http://192.168.50.99:8081/static/image.jpg"); //again, offline, requires motion OR the PTZ from arducam
  //AE35CamFeed = loadImage("http://192.168.50.99:8081/0/action/snapshot"); //also offline //Note: This is the MOTION based version
  // image(MainDisplay, 100, 200);

  if (keyPressed) {
    if (key == 'c' || key == 'C') {
      accelData.calibrate();
    }
  }
  try {
    telemetry_data = loadJSONObject("http://192.168.50.99:8000/TELEMETRY");
    compass_data = telemetry_data.getJSONObject("compass_data");
    accel_data = telemetry_data.getJSONObject("accel_data");
    //fakeheat = heatVision.Update();
  }
  catch(Exception e) {
    println("trouble getting data");
  }


  //  Float heading = map(mouseX, 0, width, 0, 180); ///testing the compass while it's off.
  Float heading = compass_data.getFloat("heading");
  compass.setHeading(heading);
  compass.draw();

  accelData.update(accel_data, 0);

  //armData.draw();
  accelData.draw();
  heatVision.draw();
  ///Let's update!
  /*
  for (int i = 0; i < NUM_TELEMS; i++) {
   T_Enabled[i].update(attic_bot_data);
   T_Enabled[i].draw();
   }
   */
  //delay(5);
}


void getNewImage() {
  try {
    AE35CamFeed = loadImage("http://192.168.50.99:8030/image.jpg");
    NewImageAvailable = true;
  }
  catch(Exception e) {
    println("trouble getting image data");
  }
}

void updateHeatVision() {
  try {
    heatVision.Update();
    NewImageAvailable = true;
  }
  catch(Exception e) {
    println("trouble getting heat data");
  }
}





void drawCylinder( int sides, float r, float h) //This is for the wheels. Just need to find a way to animate them!
{

  //https://forum.processing.org/two/discussion/26800/how-to-create-a-3d-cylinder-using-pshape-and-vertex-x-y-z
  float angle = 360 / sides;
  float halfHeight = h / 2;

  // draw top of the tube
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, -halfHeight);
  }
  endShape(CLOSE);

  // draw bottom of the tube
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, halfHeight);
  }
  endShape(CLOSE);

  // draw sides
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < sides + 1; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, halfHeight);
    vertex( x, y, -halfHeight);
  }
  endShape(CLOSE);
}



void mouseClicked() { //for the clicker

  int id = picker.get(mouseX, mouseY);
  println("yep. You clicked ID: " + id);
  if (id > NUM_TELEMS) { //outside of zones?
    if (lastPicked > -1) {
      T_Enabled[lastPicked].unCenterAndUnZoom();
      lastPicked = -1;
    }
    return;
  }

  if (id > -1) {
    if (id != lastPicked) {
      T_Enabled[id].centerAndZoom(222, 222);
      lastPicked = id;
    } else {
      T_Enabled[lastPicked].unCenterAndUnZoom();
      lastPicked = -1;
    }
  }
}
