//You make an array of these, they each have a x, y, width, height
//Maybe a callback?



class Pickable implements Comparable<Pickable> {

  int x, y, pWidth, pHeight, id;

  Pickable(int x, int y, int pWidth, int pHeight, int id) {
    this.x = x;
    this.y = y;
    this.pWidth = pWidth;
    this.pHeight = pHeight;
    this.id = id;
  }
  
  public boolean WasClicked(int cx, int cy) {
    
    /*
     given x, y...
     problem is, we don't know what the frame shift was! Maybe!
     I guess grab the BaseX/BaseY for the shift when we make these. 
     if (cx >= BaseX AND cx <= BaseX + pWidth)
    */
    if (cx >= this.x && cx <= this.x + this.pWidth){
      //Might be clicked!
      if (cy >= this.y && cy <= this.y + this.pHeight) {
        println("Yes. Was Clicked: " + this.id);
        return true;
      }
    } else {
      println("no");
    }
    return false;
  }
  
    @Override //If we need to sort
    int compareTo(Pickable other) {
      return this.x - other.x;
    }
}
