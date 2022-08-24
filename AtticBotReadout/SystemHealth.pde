class SystemHealth extends Telemetry {
  float cpu_load, cpu_temp;
  LineGrapher cpuLoadG, cpuTempG;
  PFont dataFont;

  public SystemHealth(int BaseX, int BaseY, ArrayList<Pickable> pickables, int pickID) {

    super(BaseX, BaseY, 100, 100, pickables, pickID);
    this.cpuLoadG = new LineGrapher(100, 100, 100);
    this.cpuTempG = new LineGrapher(100, 100, 100);
    this.dataFont = createFont("Montserrat SemiBold", 16);
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
      text("CPU Load", 5, 20 );  
      text(this.cpu_load, 5, 34 );      
      pushMatrix();
      translate(250, 0, 0);

      this.cpuTempG.Tdraw(this.cpu_temp);
      fill(0, 0, 0);
      text("CPU Temperature", 5, 20 );
      text(this.cpu_temp, 5, 34 );
      popMatrix();
      popMatrix();
    }
    catch(Exception e) {
      println("Problem with system health " + e);
    }
  }
}



/*
"voltage_data": 
{"V_Pos", V_Neg": 7.736, "Shunt_Volt": 0.0144, "Shunt_Curr": 0.1726, "Power_Calc": 1.33523, "Power_Regi": 1.35}
*/

class PowerReadings extends Telemetry {
  float v_neg, v_pos, shunt_volt,shunt_curr,power_calc,power_reg;
  LineGrapher cpuLoadG, cpuTempG;
  PFont dataFont;

  public PowerReadings(int BaseX, int BaseY, ArrayList<Pickable> pickables, int pickID) {

    super(BaseX, BaseY, 100, 100, pickables, pickID);
    this.cpuLoadG = new LineGrapher(100, 100, 100);
    this.cpuTempG = new LineGrapher(100, 100, 100);
    this.dataFont = createFont("Montserrat SemiBold", 16);
  }

  public void update(JSONObject data) {
    try {
      this.shunt_volt = data.getJSONObject("voltage_data").getFloat("Shunt_Volt");
      this.shunt_curr = data.getJSONObject("voltage_data").getFloat("Shunt_Curr");
      this.power_calc = data.getJSONObject("voltage_data").getFloat("Power_Calc");
      this.power_reg = data.getJSONObject("voltage_data").getFloat("Power_Reg");
      this.v_pos =  data.getJSONObject("voltage_data").getFloat("V_Pos");
      this.v_neg = data.getJSONObject("voltage_data").getFloat("V_Neg");
      pushMatrix();
      textFont(this.dataFont);
      print(data.getJSONObject("voltage_data"));
      popMatrix();
/*
      translate(this.DrawX, this.DrawY, 0);

      this.cpuLoadG.Tdraw(this.cpu_load);
      fill(0, 0, 0);
      text("CPU Load", 5, 20 );  
      text(this.cpu_load, 5, 34 );      
      pushMatrix();
      translate(250, 0, 0);

      this.cpuTempG.Tdraw(this.cpu_temp);
      fill(0, 0, 0);
      text("CPU Temperature", 5, 20 );
      text(this.cpu_temp, 5, 34 );
      popMatrix();
      popMatrix();*/
    }
    catch(Exception e) {
      println("Problem with system health " + e);
    }
  }
}
