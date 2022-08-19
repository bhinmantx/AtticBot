////Indexes servo information
/*
      'ltPos': ltPos,'rtPos':rtPos,
 "servoAPos":servoAPos,"servoBPos":servoBPos,
 "servoCPos":servoCPos,"servoDPos":servoDPos,
 "servoEPos":servoEPos,"servoFPos":servoFPos,
 'howhotobj':howhotobj,'ambient':ambient,
 'controlMode':controlMode,
 */


/*
We want telemetry data
 an easy way to draw it on the screen that's portable
 it'd be nice to collect them
 Like, temp data
 background image?
 
 takes a base set of coords maybe size
 arm indexes    servoAPos,servoBPos,
 servoCPos,servoDPos
 */

class Telemetry {
  int BaseX, BaseY, DrawX, DrawY; // saving where we want to draw, and where to start our draw
  int r, g, b; //background colors for the shape
  int w, h; //we draw a background shape
  Picker picker;
  int pickID;
  Telemetry(int BaseX, int BaseY, int r, int g, int b) {
    this.BaseX = BaseX;
    this.BaseY = BaseY;
    this.DrawX = BaseX;
    this.DrawY = BaseY;
    this.r = r;
    this.g = g;
    this.b = b;
  }

  Telemetry(int BaseX, int BaseY, int r, int g, int b, Picker picker, int pickID) {
    this.BaseX = BaseX;
    this.BaseY = BaseY;
    this.DrawX = BaseX;
    this.DrawY = BaseY;
    this.r = r;
    this.g = g;
    this.b = b;
    this.picker = picker;
    this.pickID = pickID;
  }




  void update(JSONObject data) {
  }

  void centerAndZoom(int newX, int newY) {   ///if the
    println("I will set my bases to these!");
    this.DrawX = newX;
    this.DrawY = newY;
  }

  void unCenterAndUnZoom() {
    println("UNCENTER AND ZOOOOM");
    this.DrawX = this.BaseX;
    this.DrawY = this.BaseY;
  }

  void draw () {
    pushMatrix();
    fill(128, 0, 0, 128);
    w = 100;
    h = 100;
    rect(DrawX, DrawY, w, h);
    popMatrix();
  }
}


//We know that servo arm stuff is in an array
class ServoArm extends Telemetry {
  int servoAPos, servoBPos, servoCPos, servoDPos;
  PFont dataFont;
  int lastUpdate;
  ServoArm(int BaseX, int BaseY, int r, int g, int b) {
    super(BaseX, BaseY, r, g, b);
    dataFont = createFont("Georgia", 32);
  }
  //A=0
  void update(JSONObject dataObj, int update) {
    JSONArray data = dataObj.getJSONArray("servoSettings");
    servoAPos = data.getInt(0);
    servoBPos = data.getInt(1);
    servoCPos = data.getInt(2);
    servoDPos = data.getInt(3);
    lastUpdate = update;
  }
  void draw() {
    Boolean showWarning = false;
    if (millis() - lastUpdate > 5000) {
      // showWarning = true;
    }
    pushMatrix();
    translate(DrawX, DrawY);
    fill(r, g, b);
    //textSize(30);
    textFont(dataFont);
    w = 300;
    h = 240; //should be like, number servos time font size
    rect(0, 0, w, h);
    if (showWarning) {
      fill(255, 0, 0);
    } else {
      fill(255, 255, 255);
    }
    text("Servo Arm Vals", 5, 40 );
    text("ServoA: " + servoAPos, 5, 80 );
    text("ServoB: " + servoBPos, 5, 120 );
    text("ServoC: " + servoCPos, 5, 160);
    text("ServoD: " + servoDPos, 5, 200 );
    popMatrix();
  }
}



class AccelData extends Telemetry {
  float x, y, z;
  PFont dataFont;
  int lastUpdate;
  int horizonX1, horizonX2, horizonY1, horizonY2; //for the attitude line
  MovingAverage avgX;
  MovingAverage avgY;
  float correctX, correctY;

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
  }
  //A=0
  void calibrate() {
    correctX = avgX.average();
    correctY = avgY.average();
  }
  void update(JSONObject data, int update) {
    x = data.getFloat("x");
    y = data.getFloat("y");
    z = data.getFloat("z");


    avgX.nextValue(x - correctX);
    avgY.nextValue(y - correctY);
    lastUpdate = update;
  }

  float getX() {

    return x;
  }
  void centerAndZoom(int newX, int newY) {   ///if the
    println("NWWWWEEEEEWWWWW!");
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
  
    pushMatrix();
    translate(DrawX, DrawY);
    fill(r, g, b);
    //textSize(30);
    textFont(dataFont);
    w = 300;
    h = 240; //should be like, number servos time font size
    this.picker.start(this.pickID);
    rect(0, 0, w, h);

    if (showWarning) {
      //fill(255, 0, 0);
    } else {
      fill(255, 255, 255);
    }
    text("AccelReading", 5, 40 );
    text("X: " + x, 5, 80 );
    text("Y: " + y, 5, 120 );
    text("Z: " + z, 5, 160);
    popMatrix();
    pushMatrix();

    push();
    translate(512, 368, 100);
    strokeWeight(5);
    stroke(200, 0, 0);
    if (abs(avgX.average) > 3.0) {
      tiltWarning = true;
    }
    float rotX = map(avgX.average(), -9, 9, 0, PI);
    float rotY = map(avgY.average(), -9, 9, 0, PI);

    rotateZ(PI/2);
    //  rotateY(rotY);
    rotateX(rotX);

    stroke(255);
    if (tiltWarning) {
      stroke(255, 0, 0);
    }
    fill(127);
    this.picker.start(this.pickID);
    box(160, 80, 200);

    pushMatrix();

    translate(20, 50, 100);
    pushMatrix();
    push();
    float spin = map(mouseX, 0, width, 0.0, 2*3.1415);
    rotateZ(spin);
    drawCylinder(30, 50.0, 50.0);
    pop();
    popMatrix();
    translate(-100, 0, 0);
    drawCylinder(30, 50.0, 50.0);
    popMatrix();


    pop();
    popMatrix();
    this.picker.stop();
  }
}
