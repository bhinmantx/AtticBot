//Combination of example code from processing.org and some helpful drawing functions
import http.requests.*;
import processing.video.*;

class HeatVision extends Telemetry {
  int heatX, heatY, heatSize; //position of the heat image
  float MINTEMP, MAXTEMP;
  JSONObject heat_data;
  JSONArray heat_readings;
  PApplet applet; //For camera initialization!
  Capture cam;
  PImage heatvision;
  HeatVision(int BaseX, int BaseY, PApplet applet, ArrayList<Pickable> pickables, int pickID) {
    super(BaseX, BaseY, 100, 100, pickables, pickID);
    this.heatX = -594;
    this.heatY = 140;
    this.heatSize = 484;
    this.MINTEMP = 20.0;
    this.MAXTEMP = 40.0;

    String[] cameras = Capture.list();

    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      exit();
    } else {
      println("Available cameras:");
      for (int i = 0; i < cameras.length; i++) {
        println(cameras[i]);
      }
      this.cam = new Capture(applet, cameras[0]);  // cam = new Capture(this, "pipeline:autovideosrc"); ///alternate in case of pipeline issues
      this.cam.start(); //TODO: Add graceful failure
    }
  }


  void updateHeatSettings() { //I used to pass the new min/max temp values here
    try {
      PostRequest post = new PostRequest(TelemetryServer + "/HEAT"); //we should be passing this from constructor
      post.addHeader("Content-Type", "application/json");
      post.addData("{\"MINTEMP\":" + this.MINTEMP + ",\"MAXTEMP\":"  + this.MAXTEMP+ "}"); //cheater cheater
      post.send(); //send request
    }
    catch(Exception e) {
      println("trouble updating temps");
    }
  }

  void update(JSONObject ignoring) {
    updateHeatOverlayPosition();
    try {
      this.heat_data  = loadJSONObject(TelemetryServer + "/HEAT"); //again we should really be passing this URL
      this.heat_readings = heat_data.getJSONArray("readings");
      this.heatvision = createImage(32, 24, RGB);
      this.heatvision.loadPixels();
      for (int i = 0; i < this.heatvision.pixels.length; i++) {
        JSONArray  reading = heat_readings.getJSONArray(i);
        int[] values = reading.getIntArray();
        this.heatvision.pixels[i] = color(values[0], values[1], values[2]);
      }

      if (this.cam.available() == true) {
        this.cam.read();
      }
    }
    catch(Exception e) {
      println("trouble getting data");
    }
    return;
  }

  public void Tdraw() {
    pushMatrix();
    translate(this.DrawX, this.DrawY);
    //DISABLED//this.picker.start(this.pickID);
    pushMatrix();
    this.drawBorder(this.cam.width, this.cam.height, color(255, 255, 255));
    popMatrix();
    tint(255, 255);
    image(this.cam, 0, 0);


    tint(255, 200);


    this.heatvision.updatePixels();
    this.heatvision.resize(this.heatSize, 0);
    pushMatrix();
    scale(-1, 1);
    image(this.heatvision, this.heatX, this.heatY);
    popMatrix();
    //DISABLED//this.picker.stop();
    popMatrix();
  }

  void updateHeatOverlayPosition() {
    //GOTCHA: if you have a modifier key depressed (like shift, or control) but not a "regular" key it will still act as though a "regular" key is depressed.
    //This can be helpful if you want a change to keep happening and only want to hold "shift"
    if (!this.isZoomed) {
      return;
    }
    if (keyPressed) {
      print("heatsize= " + this.heatSize);
      print(" heatX= " + this.heatX);
      println(" heatY= " + this.heatY);

      print("MINTEMP: " + this.MINTEMP);
      println(" MAXTEMP: " + this.MAXTEMP);

      switch(key) {
      case 'w':
        this.heatY++;
        break;
      case 's':
        this.heatY--;
        break;
      case 'd':
        this.heatX++;
        break;
      case 'a':
        this.heatX--;
        break;

      case 'W':
        this.heatY+= 10;
        break;
      case 'S':
        this.heatY-= 10;
        break;
      case 'D':
        this.heatX+= 10;
        break;
      case 'A':
        this.heatX-= 10;
        break;

      case 'f':
        this.heatSize+= 1;
        break;
      case 'g':
        this.heatSize-= 1;
        break;

      case 'F':
        this.heatSize+= 10;
        break;
      case 'G':
        this.heatSize-= 10;
        break;
      case 't':
        this.MINTEMP-=.3;
        this.updateHeatSettings();
        break;
      case 'y':
        MINTEMP+=.3;
        this.updateHeatSettings();
        break;
      case 'T':
        this.MINTEMP-=2.0;
        this.updateHeatSettings();
        break;
      case 'Y':
        this.MINTEMP+=2.0;
        this.updateHeatSettings();
        break;

      case 'u':
        this.MAXTEMP-=.3;
        this.updateHeatSettings();
        break;
      case 'i':
        MAXTEMP+=.3;
        this.updateHeatSettings();
        break;
      case 'U':
        this.MAXTEMP-=2.0;
        this.updateHeatSettings();
        break;
      case 'I':
        this.MAXTEMP+=2.0;
        this.updateHeatSettings();
        break;


      case 'm':
        this.updateHeatSettings();
        break;
      }
    }
  }
}
