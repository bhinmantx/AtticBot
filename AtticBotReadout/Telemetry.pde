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
  boolean isZoomed;
  Telemetry(int BaseX, int BaseY, int r, int g, int b) {
    this.BaseX = BaseX;
    this.BaseY = BaseY;
    this.DrawX = BaseX;
    this.DrawY = BaseY;
    this.r = r;
    this.g = g;
    this.b = b;
    this.isZoomed = false;
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
    this.isZoomed = false;
  }




  void update(JSONObject data) {
  }

  void centerAndZoom(int newX, int newY) {   
    this.isZoomed = true;
    this.DrawX = newX;
    this.DrawY = newY;
  }

  void unCenterAndUnZoom() {
    this.isZoomed = false;
    this.DrawX = this.BaseX;
    this.DrawY = this.BaseY;
  }

  public void Tdraw () {
    this.drawBorder(100, 100, 128);
  }
  void drawBorder(int borderWidth, int borderHeight, int borderColor) {
  
   // //DISABLED//this.picker.start(this.pickID);
   
    fill(borderColor);
    stroke(153);
    rect(0,0, borderWidth, borderHeight);
   // //DISABLED//this.picker.stop();
 
  }
}
