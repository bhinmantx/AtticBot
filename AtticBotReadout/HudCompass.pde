class HudCompass extends Telemetry { ////assuming a top center? I guess?
  PImage compassStrip;
  //private int stripX, stripY;
  private float heading;
  private float compass1X, compass1Y = 0;
  private float compass2X, compass2Y, compass3X, compass3Y = 0;
  /**
   *Gotta deal with a circular array/buffer
   *also a width, height, etc
   */
  public HudCompass(int BaseX, int BaseY, int a, int b, Picker picker, int pickID) {
    super(BaseX, BaseY, 100, 100, 100, picker, pickID);
    this.compassStrip =loadImage("data/smartCompassStrip.png", "png");
    compassStrip.resize(width, 0);

  }

  public void update() {
    this.setHeading(1.0);
  }
  
  public void setHeading(float heading) {
    this.heading = heading;
  }


  void centerAndZoom(int newX, int newY) {
  }

  public void draw() {
    push();
    translate(this.DrawX, this.DrawY);
    line(width/2-1, 0, width/2-1, this.compassStrip.height);
    this.compass1X =  map(this.heading, 359.99, 0, 0, this.compassStrip.width);//cheating again with that .99
    image(this.compassStrip, this.compass1X, this.compass1Y);

    if (this.compass1X< 0 && this.compass1X > 0 - this.compassStrip.width ) { 

      this.compass2X = width - abs(0-this.compass1X); 
      image(this.compassStrip, this.compass2X, this.compass2Y) ; // starting to wrap
    }

    if (this.compass1X > 0) { // image gap on the left
      this.compass3X =  0 - this.compassStrip.width + this.compass1X;
      image(this.compassStrip, this.compass3X, this.compass3Y) ; // for the other side
    }
    pop();
  }
}
