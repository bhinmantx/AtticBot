class AccelData extends Telemetry {
  float x, y, z;
  PFont dataFont;
  int lastUpdate;
  int horizonX1, horizonX2, horizonY1, horizonY2; //for the attitude line
  MovingAverage avgX;
  MovingAverage avgY;
  MovingAverage avgZ;
  float correctX, correctY, correctZ;

  AccelData(int BaseX, int BaseY, int r, int g, int b, Picker picker, int pickID) {
    super(BaseX, BaseY, r, g, b, picker, pickID);
    dataFont = createFont("Georgia", 32);
    //350,384,0, 550, 384, 0
    horizonX1 = 350;
    horizonX2 = 384;
    horizonY1 = 550;
    horizonY2 = 384;
    avgX = new MovingAverage(5);
    avgY = new MovingAverage(5);
    avgZ = new MovingAverage(5);
  }
  //A=0
  void calibrate() {
    correctX = avgX.average();
    correctY = avgY.average();
    correctZ = avgZ.average();
  }
  void update(JSONObject data) {
    try {
      this.x = data.getJSONObject("accel_data").getFloat("x");
      this.y = data.getJSONObject("accel_data").getFloat("y");
      this.z = data.getJSONObject("accel_data").getFloat("z");
    }
    catch (Exception e) {
      println("Problem with accel_data");
    }

    avgX.nextValue(x - correctX);
    avgY.nextValue(y - correctY);
    avgZ.nextValue(z - correctZ);
    //lastUpdate = update;
  }

  float getX() {

    return x;
  }
  void centerAndZoom(int newX, int newY) {
    this.DrawX = newX;
    this.DrawY = newY;
    this.DrawX = width/2;
    this.DrawY = height/2;
  }

  void draw() {
    Boolean showWarning = false;
    Boolean tiltWarning = false;
    if (millis() - lastUpdate > 5000) {
      // showWarning = true;
    }
    
    this.picker.start(this.pickID);
    
                                                                      pushMatrix();
    this.drawBorder(300, 240);

    translate(DrawX, DrawY);
    fill(r, g, b);
    //textSize(30);
    textFont(dataFont);
    //  w = 300;
    //  h = 240; //should be like, number servos time font size
    //   this.picker.start(this.pickID);
    // rect(0, 0, w, h);

    if (showWarning) {
      //fill(255, 0, 0);
    } else {
      fill(255, 255, 255);
    }
    text("AccelReading", 5, 40 );
    text("X: " + x, 5, 80 );
    text("Y: " + y, 5, 120 );
    text("Z: " + z, 5, 160);
//                                                           popMatrix(); //readout!
    
    
    
                                                           pushMatrix();

                      
    translate(200, 350, 100);
    strokeWeight(5);
    stroke(200, 0, 0);
    if (abs(avgX.average) > 3.0) {
      tiltWarning = true;
    }
    float rotX = map(avgX.average(), -9, 9, 0, PI);
    float rotY = map(avgY.average(), -9, 9, 0, PI);
    float rotZ = map(avgZ.average(), -9, 9, 0, PI);
    rotateZ(PI/2);
    rotateY(rotY);
    rotateX(rotX);

    stroke(255);
    if (tiltWarning) {
      stroke(255, 0, 0);
    }
    fill(127);
box(160, 80, 200);

                                              pushMatrix();

    translate(20, 50, 100);
                                              pushMatrix();

    float spin = map(mouseX, 0, width, 0.0, 2*3.1415);
    rotateZ(spin);
    drawCylinder(30, 50.0, 50.0);

                                             popMatrix();
    translate(-100, 0, 0);
    drawCylinder(30, 50.0, 50.0);
                                             popMatrix();
                                             popMatrix();
                                             popMatrix(); //readout!
      this.picker.stop();                                        

  }
}
