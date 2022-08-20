
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
  void Tdraw() {
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
