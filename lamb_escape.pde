/**
 * Lamb Escape: an implementation of a classic sliding puzzle.
 * Programmed by Yoshiaki Takata, 2013.
 * See Stock.pde for the image materials and sound effects.
 */
void setup() {
  size(1000, 655);
  smooth();
  //frameRate(30);
  imageStock = new ImageStock();
  tileSet = new TileSet();
  audioStock = new AudioStock(this);
  audioStock.playBGM();
  fontStock = new FontStock();
  menuBar = new MenuBar();
  footer = new Footer();
  banner = new Banner();
}
void stop() {
  audioStock.close();
  super.stop();
}

ImageStock imageStock;
AudioStock audioStock;
FontStock  fontStock;
TileSet tileSet;
MenuBar menuBar;
Footer footer;
Banner banner;
AutoMode autoMode = null;
NopCounter nopCounter = null;
boolean goal;
boolean redrawBackground = true;
int fadeOutIn = 0;
final int FADEOUT_TIME = 60;

void draw() {
  if (goal || redrawBackground) {
    image(imageStock.background, 0, 0);
    redrawBackground = false;
  }
  image(imageStock.backboard, 250, 0);
  tileSet.draw();
  if (goal) {
    banner.draw();
    autoMode = null;
  }
  if (autoMode != null) {
    autoMode.draw();
  }
  if (fadeOutIn > 0) {
    noStroke();
    int alpha = (FADEOUT_TIME - abs(FADEOUT_TIME - fadeOutIn)) * 255 / FADEOUT_TIME;
    fill(0, alpha);
    rect(0, 0, width, height);
    if (fadeOutIn == FADEOUT_TIME) {
      tileSet = new TileSet();
    }
    redrawBackground = true;
    fadeOutIn--;
  }
  menuBar.draw();
  footer.draw();
  if ((goal || (justReset && autoMode == null)) && fadeOutIn <= 0) {
    if (nopCounter == null) {
      nopCounter = new NopCounter(120 * 60); // 2min.
    }
    if (nopCounter.justTimeUp()) {
      if (goal) {
        layout = (layout + 1) % N_LAYOUT;
        fadeOutIn = 2 * FADEOUT_TIME;
      } else {
        autoMode = new AutoMode();
      }
    }
  } else {
    nopCounter = null;
  }
}

void mousePressed() {
  if (fadeOutIn > 0) return;
  if (autoMode == null) {
    tileSet.mousePressed();
  }
  menuBar.mousePressed();
}

class MenuBar {
  final color red   = #e04040;
  final color white = #ffffff;
  void draw() {
    fill(0);
    stroke(0);
    rect(0, 0, width, 25);
    fill(white);
    textFont(fontStock.menu);
    textSize(18);
    textAlign(LEFT, TOP);
    text("Reset", 10, 3);
    textAlign(CENTER, TOP);
    fill(layout == 0 ? red : white);
    text("Easy",   100, 3);
    fill(layout == 1 ? red : white);
    text("Medium", 160, 3);
    fill(layout == 2 ? red : white);
    text("Hard",   221, 3);
    fill(white);
    if (! goal) {
      textAlign(CENTER, TOP);
      text((autoMode == null ? "Auto" : "Manual"), 300, 3);
    }
        textAlign(CENTER, TOP);
    textAlign(RIGHT, TOP);
    text("" + stepCount, width - 20, 3);
    if (autoMode != null) {
      fill(80);
      text(String.format("%,d", autoMode.solver.nReached),
           width - 100, 3);
    }
  }
  void mousePressed() {
    if (! (0 < mouseY && mouseY < 28)) return;
    boolean canReset = (autoMode == null || autoMode.canRun());

    if (10 < mouseX && mouseX < 60 && canReset) {
      if (goal || autoMode != null) {
        fadeOutIn = 2 * FADEOUT_TIME;
        autoMode = null;
      } else {
        tileSet = new TileSet();
        redrawBackground = true;
      }
    }
    if (85 < mouseX && mouseX < 115 && canReset &&
        layout != 0)
    {
      layout = 0;
      fadeOutIn = 2 * FADEOUT_TIME;
      autoMode = null;
    }
    if (125 < mouseX && mouseX < 195 && canReset &&
        layout != 1)
    {
      layout = 1;
      fadeOutIn = 2 * FADEOUT_TIME;
      autoMode = null;
    }
    if (206 < mouseX && mouseX < 236 && canReset &&
        layout != 2)
    {
      layout = 2;
      fadeOutIn = 2 * FADEOUT_TIME;
      autoMode = null;
    }
    if (270 < mouseX && mouseX < 330 && canReset &&
        ! goal)
    {
      if (autoMode == null) {
        autoMode = new AutoMode();
      } else {
        autoMode = null;
      }
    }
  }
}

class Footer {
    void draw() {
      String copyright = imageStock.copyright() + ", "
                       + audioStock.copyright();
      fill(204);
      noStroke();
      rect(0, 640, width, 15);
      fill(128);
      textFont(fontStock.menu);
      textSize(9);
      textAlign(RIGHT, CENTER);
      text(copyright,  width - 5, 640 + 5);
    }
}

class Banner {
  String banner = "CONGRATULATION!";
  int t = 0;
  float[] a = new float[banner.length()];
  float[] f = new float[banner.length()];
  Banner() {
    for (int i = 0; i < a.length; i++) {
      a[i] = random(2, 5);
      f[i] = random(90, 180);
    }
  }
  void draw() {
    textFont(fontStock.banner);
    textAlign(CENTER, CENTER);
    int n = banner.length();
    for (int i = 0; i < banner.length(); i++) {
      char c = banner.charAt(i);
      float yy = 100 + a[i] * sin(t * TWO_PI/f[i]);
      textSize(40);
      fill(0);
      text("" + c, width/2 + (i - n/2) * 45 + 4, yy + 4);
      textSize(40);
      fill(255, 50, 50);
      text("" + c, width/2 + (i - n/2) * 45, yy);
    }
    t++;
  }
}

class AutoMode {
  Solver solver;
  Trail trail;
  AutoMode() {
    trail = new Trail();
    solver = new Solver(tileSet, trail);
    new Thread(solver).start();
  }
  boolean canRun() {
    return solver.finished;
  }
  void draw() {
    drawBanner();
    if (canRun()) {
      trail.run();
    }
  }

  final String banner = "AUTOMODE";
  final float Y = 100;
  int t = 0;
  final int F = 360;
  Pinwheel pinwheel = new Pinwheel(width/2, Y + 100);
  void drawBanner() {
    textAlign(CENTER, CENTER);
    int n = banner.length();
    float alpha = 355 * sin(TWO_PI * t / F);
    for (int i = 0; i < banner.length(); i++) {
      char c = banner.charAt(i);
      textFont(fontStock.banner);
      textSize(40);
      fill(255, 50, 50, alpha);
      text("" + c, width/2 + (i - (n - 1)/2.0) * 45, Y);
    }
    if (! solver.finished && t > 60) {
      pinwheel.draw();
    }
    t++;
  }
}

class NopCounter {
  NopCounter(int max_) {
    count = max_;
  }
  int count;
  boolean justTimeUp() {
    return (--count == 0);
  }
}

