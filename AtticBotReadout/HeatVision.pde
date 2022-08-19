//Combination of example code from processing.org and some helpful drawing functions
import http.requests.*;
import processing.video.*;






class HeatVision {
  int BaseX, BaseY, DrawX, DrawY;
  int heatX, heatY, heatSize; //position of the heat image
  float MINTEMP, MAXTEMP;
  PApplet applet; //For camera initialization!
  JSONObject heat_data;
  JSONArray heat_readings;
  Picker picker;
  int pickID;
  Capture cam;
  HeatVision(int BaseX, int BaseY, PApplet applet) {
    this.BaseX = BaseX;
    this.BaseY = BaseY;
    this.heatX = 0;
    this.heatY = 0;
    this.heatSize = 100;
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
      PostRequest post = new PostRequest("http://192.168.50.209:8001/HEAT"); //we should be passing this from constructor
      post.addHeader("Content-Type", "application/json");
      post.addData("{\"MINTEMP\":" + this.MINTEMP + ",\"MAXTEMP\":"  + this.MAXTEMP+ "}"); //cheater cheater
      post.send(); //send request
    }
    catch(Exception e) {
      println("trouble updating temps");
      // println(post.getContent()); //print response //find out how to pass stuff to the exception!
    }
  }

  void Update() {
    updateHeatOverlayPosition();

    try {
      this.heat_data  = loadJSONObject("http://192.168.50.209:8001/HEAT"); //again we should really be passing this URL
      this.heat_readings = heat_data.getJSONArray("readings");

      PImage img = createImage(32, 24, RGB);
      img.loadPixels();
      for (int i = 0; i < img.pixels.length; i++) {
        JSONArray  reading = heat_readings.getJSONArray(i);
        int[] values = reading.getIntArray();
        img.pixels[i] = color(values[0], values[1], values[2]);
      }

      if (this.cam.available() == true) {
        this.cam.read();
      }
      tint(255, 127);

      image(cam, 0, 0);

      img.updatePixels();
      img.resize(heatSize, 0);
      pushMatrix();
      scale(-1, 1);
      image(img, this.heatX, this.heatY);
      popMatrix();
      delay(20);
    }
    catch(Exception e) {
      println("trouble getting data");
    }
  }

  void updateHeatOverlayPosition() {
    //GOTCHA: if you have a modifier key depressed (like shift, or control) but not a "regular" key it will still act as though a "regular" key is depressed.
    //This can be helpful if you want a change to keep happening and only want to hold "shift"
    if (keyPressed) {
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
        this.updateHeatSettings();
        break;
      }
    }
  }
}
