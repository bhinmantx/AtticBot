class LineGrapher {
  private float[] data;
  private int graphWidth, graphHeight, graphRes;
  private float warningThresh;
  private String name;
  /**
   *Gotta deal with a circular array/buffer
   *also a width, height, etc
   */
  public LineGrapher(int graphWidth, int graphHeight, int graphRes) {
    data = new float[200]; //placeholder
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
    square(0, 0, 200);
    /*  for (int i = 0; i<=graphWidth; i+=4) {
     stroke(255);
     line(i*4, 0, i*4, graphHeight*4);
     line(0, i*4, graphWidth*4, i*4);
     }*/
    noFill();
    stroke(5*gotX, 0, 0);
    strokeWeight(1);
    beginShape();

    for (int i = 0; i<data.length; i++) {
      stroke(data[i]*5, 0, 0);
      vertex(i, 150-data[i]);
    }
    endShape();
    popMatrix();
    for (int i = 1; i<data.length; i++) {
      data[i-1] = data[i];
    }
    //    data[data.length-1]=gotX*4 + graphHeight/2;
    data[data.length-1]=gotX;
  }
}


class BarGrapher {

  color gcolor;

  public BarGrapher(int BaseX, int BaseY, int graphWidth, int graphHeight) {
    
    
    
  }

  public void update() {
  }
}
