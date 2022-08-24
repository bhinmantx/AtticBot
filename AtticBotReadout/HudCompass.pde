class HudCompass extends Telemetry { ////assuming a top center? I guess?
  PImage compassStrip;
  MovingAverage avgHeading;
  private float heading;
  private float compass1X, compass1Y = 0;
  private float compass2X, compass2Y, compass3X, compass3Y = 0;
  /**
   *Gotta deal with a circular array/buffer
   *also a width, height, etc
   */
  public HudCompass(int BaseX, int BaseY, ArrayList<Pickable> pickables, int pickID) {

    super(BaseX, BaseY, width, 100, pickables, pickID);

    this.compassStrip =loadImage("data/compass_stripHD.png", "png");
    this.compassStrip.resize(width, 0);
    this.avgHeading = new MovingAverage(5);
  }

  public void update(JSONObject data) {
    try {
      this.setHeading( data.getJSONObject("compass_data").getFloat("heading"));
    }
    catch(Exception e) {
      println("Problem with compass heading");
    }
  }
  
  public void wasResized() {
    println("was affected?");
    this.compassStrip.resize(width, 0);
  }

  public void setHeading(float heading) { //For direct setting compass for testing
    avgHeading.nextValue(heading);
    this.heading = this.avgHeading.average();
  }

  void centerAndZoom(int newX, int newY) {
  }

  //public void draw() {
  public void Tdraw() {
    pushMatrix();
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
    popMatrix();
  }
}
