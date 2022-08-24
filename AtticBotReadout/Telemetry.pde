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
  ArrayList<Pickable> picker;
  int pickID;
  boolean isZoomed;
  Telemetry(int BaseX, int BaseY) {
    this.BaseX = BaseX;
    this.BaseY = BaseY;
    this.DrawX = BaseX;
    this.DrawY = BaseY;

    this.isZoomed = false;
  }

  Telemetry(int BaseX, int BaseY, int w, int h, ArrayList<Pickable> picker, int pickID) {
    this.BaseX = BaseX;
    this.BaseY = BaseY;
    this.DrawX = BaseX;
    this.DrawY = BaseY;
    this.w = w;
    this.h = h;
    this.picker = picker;
    this.pickID = pickID;
    this.isZoomed = false;
    Pickable picked = new Pickable(this.BaseX, this.BaseY, this.w, this.h, this.pickID);
    pickables.add(picked);
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
    pushMatrix();
    translate(this.DrawX, this.DrawY, 0);
    this.drawBorder(this.w, this.h, 128);
    popMatrix();
    this.AdjustPosition();
  }
  void drawBorder(int borderWidth, int borderHeight, int borderColor) {
    //println("drawing border" + this.pickID);
    fill(borderColor);
    stroke(153);
    rect(0, 0, borderWidth, borderHeight);
  }


  void AdjustPosition() {
    //GOTCHA: if you have a modifier key depressed (like shift, or control) but not a "regular" key it will still act as though a "regular" key is depressed.
    //This can be helpful if you want a change to keep happening and only want to hold "shift"
    if (!this.isZoomed) {
      return;
    }
    if (keyPressed && this.isZoomed) {
      switch(key) {
      case 'w':
        this.DrawY--;
        break;
      case 's':
        this.DrawY++;
        break;
      case 'd':
        this.DrawX++;
        break;
      case 'a':
        this.DrawX--;
        break;

      case 'W':
        this.DrawY+= 10;
        break;
      case 'S':
        this.DrawY-= 10;
        break;
      case 'D':
        this.DrawX+= 10;
        break;
      case 'A':
        this.DrawX-= 10;
        break;
      }
    }
  }
}
