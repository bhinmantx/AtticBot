class SystemHealth extends Telemetry {
  float cpu_load, cpu_temp;
  LineGrapher cpuLoadG, cpuTempG;
  PFont dataFont;

  public SystemHealth(int BaseX, int BaseY, ArrayList<Pickable> pickables, int pickID) {

    super(BaseX, BaseY, 100, 100, pickables, pickID);
    this.cpuLoadG = new LineGrapher(100, 100, 100);
    this.cpuTempG = new LineGrapher(100, 100, 100);
    this.dataFont = createFont("Georgia", 16);
  }

  public void update(JSONObject data) {
    try {
      this.cpu_temp = data.getJSONObject("system_stats").getFloat("cpu_temp");
      this.cpu_load =  data.getJSONObject("system_stats").getFloat("cpu_load");
      pushMatrix();
      textFont(this.dataFont);


      translate(this.DrawX, this.DrawY, 0);

      this.cpuLoadG.Tdraw(this.cpu_load);
      fill(0, 0, 0);
      text("CPU Load", 5, 0 );
      pushMatrix();
      translate(250, 0, 0);

      this.cpuTempG.Tdraw(this.cpu_temp);
      fill(0, 0, 0);
      text("CPU Temperature", 5, 0 );
      popMatrix();
      popMatrix();
    }
    catch(Exception e) {
      println("Problem with system health " + e);
    }
  }
}
