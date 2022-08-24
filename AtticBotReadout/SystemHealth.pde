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
  float v_neg, v_pos, shunt_volt, shunt_curr, power_calc, power_reg;
  LineGrapher cpuLoadG, cpuTempG;
  PFont dataFont;
  Chart vNegChart, shuntCurrChart;

  public PowerReadings(int BaseX, int BaseY, ArrayList<Pickable> pickables, int pickID, ControlP5 cp5, PApplet applet) {
    super(BaseX, BaseY, 100, 100, pickables, pickID);
    this.cpuLoadG = new LineGrapher(100, 100, 100);
    this.cpuTempG = new LineGrapher(100, 100, 100);
    this.dataFont = createFont("Montserrat SemiBold", 16);

    this.shuntCurrChart   = cp5.addChart("currflow")
      .setPosition(600, 730)
      .setSize(100, 100)
      .setRange(0, 5000)
      ///.setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
      .setView(Chart.AREA)
      .setStrokeWeight(1.5)
      .setColorCaptionLabel(color(20))
      .setColorValue(color(255))
      .setColorActive(color(155))
      .setColorForeground(color(155))
      .setLabel("Current Flow")
      .setColorBackground(color(0, 255, 0))
      ;
    this.shuntCurrChart.addDataSet("shunt_curr_data");
    this.shuntCurrChart.setData("shunt_curr_data", new float[100]);
  }

  public void addCharts(Chart vNegChart) {
    this.vNegChart = vNegChart;
    //this.shuntCurrChart = shuntCurrChart;
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

      text("Current Flow", 600, 720 );
      text("Bus Voltage", 750, 720 );

      this.vNegChart.getColor().setBackground(color(128, 0, 0, 255));
      this.vNegChart.setColors("incoming", color(30, 255, 20));
      this.vNegChart.push("incoming", this.v_neg);

      this.shuntCurrChart.setPosition(this.DrawX, this.DrawY);
      this.shuntCurrChart.push("shunt_curr_data", this.shunt_curr);
      popMatrix();
    }
    catch(Exception e) {
      println("Problem with system health " + e);
    }
  }
}




/*
"humidity": 41.23292896925307, "ambient": 28.936064698252835, "ambient_f": 84.0849164568551
 */



class AtmosphereReading extends Telemetry {
  float f_temp, c_temp, humidity;

  PFont dataFont;
  Chart vNegChart, shuntCurrChart;

  public AtmosphereReading(int BaseX, int BaseY, int w, int h, ArrayList<Pickable> pickables, int pickID) {
    super(BaseX, BaseY, w, h, pickables, pickID);
    this.dataFont = createFont("Montserrat SemiBold", 10);
  }


  public void update(JSONObject data) {
    try {
      this.f_temp = data.getFloat("ambient_f");
      this.c_temp = data.getFloat("ambient");
      this.humidity = data.getFloat("humidity");
    }
    catch(Exception e) {
      println("Problem with system health " + e);
    }
  }
  
  public void Tdraw() {
    push();
    textFont(this.dataFont);
    translate(this.DrawX, this.DrawY);
    this.drawBorder(this.w, this.h, color(255, 0, 255));
    fill(0);
    translate(5, 15);
    this.f_temp = setFloatto(this.f_temp, 100);
    text("Amient Temp: " + this.f_temp, 0, 0 );
    translate(0, 15);
    this.humidity = setFloatto(this.humidity, 100);
    text("Humidity: " + this.humidity, 0, 0 );
    pop();
    AdjustPosition();
  }
}
