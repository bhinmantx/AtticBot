//You make an array of these, they each have a x, y, width, height
//Maybe a callback?



class Pickable implements Comparable<Pickable> {

  int x, y, pWidth, pHeight;

  Pickable(int x, int y, int pWidth, int pHeight) {
    this.x = x;
    this.y = y;
    this.pWidth = pWidth;
    this.pHeight = pHeight;
  }
  
  public void WasClicked(int cx, int cy) {
    
    /*
     given x, y...
     problem is, we don't know what the frame shift was! Maybe!
     I guess grab the BaseX/BaseY for the shift when we make these. 
     if (cx >= BaseX AND cx <= BaseX + pWidth)
    */
    if (cx >= this.x && cx <= this.x + this.pWidth){
      //Might be clicked!
      if (cy >= this.y && cy <= this.y + this.pHeight) {
        println("Yes. Was Clicked");
      }
    } else {
      println("no");
    }
  }
  
    @Override //If we need to sort
    int compareTo(Pickable other) {
      return this.x - other.x;
    }
}
