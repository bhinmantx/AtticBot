/**
 //https://discourse.processing.org/t/computing-a-moving-average/28996/16
 * Use  a circular array to store generation step impl. times
 * and calculate a moving average.
 *
 * Specify the number of values to include in the moving average when
 * using the constructor.
 *
 * The implementation time is O(1) i.e. the same whatever the number
 * of values used it takes the same amount of time to calculate the
 * moving average.
 *
 * @author Peter Lager 2021
 */
class MovingAverage {
  private float[] data;
  private float total = 0, average = 0;
  private int idx = 0, n = 0;

  /**
   * For a moving average we must have at least remember the last
   * two values.
   * @param size the size of the underlying array
   */
  public MovingAverage(int size) {
    data = new float[Math.max(2, size)];
  }

  // Include the next value in the moving average
  public float nextValue(float value) {
    total -= data[idx];
    data[idx] = value;
    total += value;
    idx = ++idx % data.length;
    if (n < data.length) n++;
    average = total / (float)n;
    return average;
  }

  public void reset() {
    for (int i = 0; i < data.length; i++)
      data[i] = 0;
    total = n = 0;
  }

  public float average() {
    return average;
  }
}
