class AccelData extends Telemetry {
  float x, y, z;
  PFont dataFont;
  int lastUpdate;
  int horizonX1, horizonX2, horizonY1, horizonY2; //for the attitude line
  MovingAverage avgX;
  MovingAverage avgY;
  MovingAverage avgZ;
  float correctX, correctY, correctZ;

  AccelData(int BaseX, int BaseY, int w, int h, ArrayList<Pickable>  pickables, int pickID) {
    super(BaseX, BaseY, w, h, pickables, pickID);
    dataFont = createFont("Montserrat SemiBold", 10);
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

 //   this.DrawX = width/2;
  //  this.DrawY = height/2;

  }

  public void Tdraw() {
    Boolean showWarning = false;
    Boolean tiltWarning = false;
    if (millis() - lastUpdate > 5000) {
      // showWarning = true;
    }



    pushMatrix();
    translate(DrawX, DrawY);
    this.drawBorder(this.w, this.h, color(0, 0, 255));
    fill(r, g, b);

    textFont(dataFont);


    if (showWarning) {
      //fill(255, 0, 0);
    } else {
      fill(255, 255, 255);
    }
    text("AccelReading", 5, 20 );
    text("X: " + setFloatto(x,10000), 5, 40 );
    text("Y: " + setFloatto(y,10000), 5, 60 );
    text("Z: " + setFloatto(z,10000), 5, 80);


    pushMatrix();
    translate(200, 200, 100); //moving the 3d model
    pushMatrix();

    rotateX(mouseRotX);
    rotateY(mouseRotY);

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
    popMatrix();
    popMatrix();

  }
}
