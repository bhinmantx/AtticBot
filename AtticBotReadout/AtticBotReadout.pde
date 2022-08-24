/*
Telemetry reader and some config for a Raspberry Pi based robot with several sensors.
 */

import controlP5.*;
ControlP5 cp5;
Chart vPosChart;
Chart shuntCurrChart;

float mouseRotX, mouseRotY;
String TelemetryServer = "http://192.168.50.209:8000";
int NUM_TELEMS = 6; //really this should be just a constant and you enable various telemetry later

JSONObject attic_bot_data, accel_data, compass_data, telemetry_data;
JSONArray arm_data;

PImage AE35CamFeed, MainDisplay, bgImage;
boolean NewImageAvailable = false;
int imageDelay = 200; //to slow down requests to the pi
int lastImageGet = 0;
int w, h; //for resize detection

ServoArm armData;
AccelData accelData;
HeatVision heatVision;
SystemHealth systemHealth;
HudCompass compass;
PowerReadings powerReadings;
AtmosphereReading atmosphereReading;

ArrayList<Pickable> pickables = new ArrayList<Pickable>();

int lastPicked = -1;

Telemetry[] T_Enabled =  new Telemetry[NUM_TELEMS]; //Since parts of the robot can be active or inactive here's an easier way to track and activate



void setup() {
  size(1280, 900, P3D);
  surface.setTitle("Attic Bot Telemetry");
  w = width;
  h = height;
  surface.setResizable(true);
  cp5 = new ControlP5(this);
  armData = new ServoArm(10, 10, 0, 128, 0);
  accelData = new AccelData(50, 150, 100, 120, pickables, 0);
  compass = new HudCompass(0, 0, pickables, 1);
  heatVision = new HeatVision(width/2, 200, this, pickables, 2);
  atmosphereReading = new AtmosphereReading(50, 500, 120, 80, pickables, 3);
  powerReadings = new PowerReadings(150, 150, pickables, 4, cp5, this);
  systemHealth = new SystemHealth(100, 700, pickables, 5);


  //AE35CamFeed = loadImage("http://192.168.50.99:8030/image.jpg");  //Should we convert AE35 stuff to a telemetry entry? It's from a different endpoint
  bgImage = loadImage("data/bgImage.png", "png"); //get something less boring!
  MainDisplay = AE35CamFeed;
  //thread("getNewImage"); //Parts of the Pi side are still offline. Should add the threading to its own "Enabled" array
  //thread("updateHeatVision");

  T_Enabled[0] = accelData;
  T_Enabled[1] = compass ;
  T_Enabled[2] = heatVision ;
  T_Enabled[3] = atmosphereReading ;
  T_Enabled[4] = powerReadings;
  T_Enabled[5] = systemHealth;

  vPosChart = cp5.addChart("dataflow")
    .setPosition(750, 730)
    .setSize(100, 100)
    .setRange(0, 12)
    ///.setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setView(Chart.AREA)
    .setStrokeWeight(1.5)
    .setLabel("Shunt Voltage")
    .setColorCaptionLabel(color(40))
    ;



  vPosChart.addDataSet("incoming");
  vPosChart.setData("incoming", new float[100]);

  powerReadings.addCharts(vPosChart);
  //deal with resize
  registerMethod("pre", this);
}


void pre() {
  println("was this checked?");
  if (w != width || h != height) {
    // Sketch window has resized
    w = width;
    h = height;
    compass.wasResized();
    // Do what you need to do here
  }
}


void draw() {
  background(100, 100, 100);

  imageMode(CENTER);
  image(bgImage, width/2, height/2);
  imageMode(CORNER);

  int rightNow = millis();
  //Deal with threaded images later
  if (rightNow - lastImageGet > imageDelay && NewImageAvailable) {

    //  MainDisplay = AE35CamFeed;
    NewImageAvailable = false;
    // thread("getNewImage"); //offline during testing

    lastImageGet = rightNow;
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
    telemetry_data = loadJSONObject(TelemetryServer + "/TELEMETRY");
  }
  catch(Exception e) {
    println("trouble getting data");
  }

  for (int i = 0; i < NUM_TELEMS; i++) {
    T_Enabled[i].update(telemetry_data);
    T_Enabled[i].Tdraw();
  }
  // systemHealth.update(telemetry_data);
  //atmosphereReading.update(telemetry_data);
  // powerReadings.update(telemetry_data);
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
    heatVision.update(telemetry_data);
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

  mouseRotX = 0;
  mouseRotY = 0;

  int click_id = NUM_TELEMS+1;

  for (int q = 0; q < pickables.size() - 1; q++) {
    Pickable part = pickables.get(q);
    if (part.WasClicked(mouseX, mouseY)) {
      click_id = q;
      break;
    }
  }
  if (click_id > NUM_TELEMS) { //outside of zones?
    if (lastPicked > -1) {
      T_Enabled[lastPicked].unCenterAndUnZoom();
      lastPicked = -1;
    }
    return;
  }

  if (click_id > -1) {
    if (click_id != lastPicked) {
      T_Enabled[click_id].centerAndZoom(222, 222);
      lastPicked = click_id;
    } else {
      T_Enabled[lastPicked].unCenterAndUnZoom();
      lastPicked = -1;
    }
  }
}


void mouseDragged() {

  mouseRotX = map(mouseY, 0, width/2, PI, 0);
  mouseRotY = map(mouseX, 0, height/2, 0, PI);
}


float setFloatto(float value, int modification) {
  value = value *  modification;
  int value_int = int(value);
  value = float(value_int/ modification);
  return value;
}
