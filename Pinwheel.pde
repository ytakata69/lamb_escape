/**
 * A "Please wait"-sign.
 * Programmed by Yoshiaki Takata, 2013.
 */
class Pinwheel {
  final int COLOR = 255;
  int[] v = new int[12];
  int t = 0;
  float x, y;
  Pinwheel(float x_, float y_) {
    x = x_;
    y = y_;
  }
  final int r1 = 8;
  final int r2 = 15;
  void draw() {
    strokeWeight(2);
    int ti = (t / 5) % v.length;
    v[ti] = 255;
    for (int i = 0; i < v.length; i++) {
      float tt = TWO_PI * i / v.length - HALF_PI;
      float x1 = r1 * cos(tt) + x;
      float y1 = r1 * sin(tt) + y;
      float x2 = r2 * cos(tt) + x;
      float y2 = r2 * sin(tt) + y;
      stroke(COLOR, v[i]);
      line(x1, y1, x2, y2);
      if (v[i] > 0) v[i] -= 6;
    }
    t++;
  }
}

