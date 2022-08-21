class LineGrapher {
  private float[] data;
  private int graphWidth, graphHeight, graphRes;
  /**
   *Gotta deal with a circular array/buffer
   *also a width, height, etc
   */
  public LineGrapher(int graphWidth, int graphHeight, int graphRes) {
    data = new float[400]; //placeholder
    this.graphWidth = graphWidth;
    this.graphHeight = graphHeight;
    this.graphRes = graphRes;
  }

  public void addValue() {
    for (int i = 0; i < data.length; i++) {
    }
  }

  public void Tdraw(float gotX) {
                                                                                                            pushMatrix();
    fill(0, 255, 0);
    translate(width/2, height/2);
    for (int i = 0; i<=graphWidth; i+=4) {
      stroke(255);
      line(i*4, 0, i*4, graphHeight*4);
      line(0, i*4, graphWidth*4, i*4);

    }
    noFill();
    stroke(0);
    strokeWeight(1)
    beginShape();
    for (int i = 0; i<data.length; i++) {
      vertex(i, 350-data[i]);
    }
    endShape();
                                                                                                            popMatrix();
    for (int i = 1; i<data.length; i++) {
      data[i-1] = data[i];
    }
    data[data.length-1]=gotX*400 + graphHeight/2;
  }
}
