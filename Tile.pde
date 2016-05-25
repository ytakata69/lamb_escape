import java.util.*;

final int baseX = 298;
final int baseY = 58;
final int unit = 103;
final int sep = 7;
final int offsetX = 14;
final int offsetY = 14;
final int WIDTH = 4;
final int HEIGHT = 5;

final int N_LAYOUT = 3;
int layout = 0;

int[][] map = new int[WIDTH][HEIGHT];
int moving = 0;
int movingId = 0;
int hoverOn = 0;
int goalOffset = 0;
int stepCount = 0;
boolean justReset = false;

/**
 * Each tile
 */
class Tile {
  final int NORTH = 1;
  final int EAST = 2;
  final int SOUTH = 4;
  final int WEST = 8;
  int x, y, width, height, id, pict;
  int t = 0;
  int dir = 0;
  Tile(int x_, int y_, int w_, int h_, int id_, int pict_) {
    x = x_;
    y = y_;
    width = w_;
    height = h_;
    id = id_;
    pict = pict_;
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        map[x + i][y + j] = id;
      }
    }
  }
  void draw() {
    int xx = baseX + x * unit - offsetX;
    int yy = baseY + y * unit - offsetY;
    if (moving > 0 && movingId == id) {
      moving -= 2;
      int targetX = x;
      int targetY = y;
      switch (dir) {
      case NORTH: targetY--; break;
      case SOUTH: targetY++; break;
      case EAST:  targetX++; break;
      case WEST:  targetX--; break;
      }
      xx = baseX + targetX * unit + (x - targetX) * moving - offsetX;
      yy = baseY + targetY * unit + (y - targetY) * moving - offsetY;
      if (moving <= 0) {
        int vx = -(targetX - x) * width;
        int vy = -(targetY - y) * height;
        x = targetX;
        y = targetY;
        for (int i = 0; i < width; i++) {
          for (int j = 0; j < height; j++) {
            if (map[x + i][y + j] <= 0) {
              tileSet.moveEmpty(x + i, y + j, vx, vy);
            }
            map[x + i][y + j] = id;
          }
        }
        dir = 0;
        movingId = 0;
        if (id == 2 && x == 1 && y == 3) {
          audioStock.playFanfare();
          goal = true;
          goalOffset = 0;
        }
      }
    }
    if (id == 2) {
      if (goal) {
        yy += goalOffset;
        if (goalOffset < 60) {
          goalOffset++;
        }
      } else {
        yy += 1.2 * sin(TWO_PI * t / 240);
        t++;
      }
    }
    image(imageStock.tile[pict], xx, yy);
  }
  void drawDir() {
    if (autoMode != null) return;
    if (moving > 0 || goal || (dir = canMove()) == 0) return;
    int xx = baseX + x * unit;
    int yy = baseY + y * unit;
    int d = 10;
    fill(255);
    stroke(255);
    if ((dir & NORTH) != 0) {
      ellipse(xx + width * unit / 2, yy + d/2, d, d);
    }
    if ((dir & SOUTH) != 0) {
      ellipse(xx + width * unit / 2, yy + height * unit - sep - d/2, d, d);
    }
    if ((dir & EAST) != 0) {
      ellipse(xx + width * unit - sep - d/2, yy + height * unit / 2, d, d);
    }
    if ((dir & WEST) != 0) {
      ellipse(xx + d/2, yy + height * unit / 2, d, d);
    }
  }
  void mousePressed() {
    if (moving > 0 || goal) return;
    if (hoverOn != id) return;
    int px = mouseX - (baseX + x * unit);
    int py = mouseY - (baseY + y * unit);
    dir = canMove();
    if (dir == 0) return;
    int qx = width  * unit - sep - px;
    int qy = height * unit - sep - py;
    if ((dir & NORTH) != 0) {
      if ((dir & SOUTH) != 0) {
        dir = (py < qy ? NORTH : SOUTH);
      } else if ((dir & EAST) != 0) {
        dir = (py < qx ? NORTH : EAST);
      } else if ((dir & WEST) != 0) {
        dir = (py < px ? NORTH : WEST);
      }
    } else if ((dir & EAST) != 0) {
      if ((dir & SOUTH) != 0) {
        dir = (qx < qy ? EAST : SOUTH);
      } else if ((dir & WEST) != 0) {
        dir = (qx < px ? EAST : WEST);
      }
    } else if ((dir & SOUTH) != 0) {
      if ((dir & WEST) != 0) {
        dir = (qy < px ? SOUTH : WEST);
      }
    }
    move(dir);
  }
  void move(int vx, int vy) {
    move(vx < 0 ? WEST :
         vx > 0 ? EAST :
         vy < 0 ? NORTH : SOUTH);
  }
  void move(int dir_) {
    dir = dir_;
    movingId = id;
    moving = unit;
    stepCount++;
    justReset = false;
  }
  int canMove() {
    int dir = 0;
    if (y > 0) {
      boolean test = true;
      for (int i = 0; i < width; i++) {
        test &= (map[x + i][y - 1] <= 0);
      }
      if (test) dir |= NORTH;
    }
    if (y + height < HEIGHT) {
      boolean test = true;
      for (int i = 0; i < width; i++) {
        test &= (map[x + i][y + height] <= 0);
      }
      if (test) dir |= SOUTH;
    }
    if (x > 0) {
      boolean test = true;
      for (int i = 0; i < height; i++) {
        test &= (map[x - 1][y + i] <= 0);
      }
      if (test) dir |= WEST;
    }
    if (x + width < WIDTH) {
      boolean test = true;
      for (int i = 0; i < height; i++) {
        test &= (map[x + width][y + i] <= 0);
      }
      if (test) dir |= EAST;
    }
    return dir;
  }
}

class TileSet {
  Tile[] set;
  Tile[] empty;
  Tile[] layout0() {
    // new Tile(...) must be called after clearing map[][].
    return new Tile[] { // easy
      new Tile(0, 0, 1, 2, 1, 0),
      new Tile(1, 0, 2, 2, 2, 1),
      new Tile(3, 0, 1, 2, 3, 2),
      new Tile(0, 3, 2, 1, 4, 3),
      new Tile(2, 3, 2, 1, 5, 3),
      new Tile(0, 2, 1, 1, 6, 6),
      new Tile(1, 2, 1, 1, 7, 4),
      new Tile(3, 2, 1, 1, 8, 4),
      new Tile(0, 4, 1, 1, 9, 7),
      new Tile(3, 4, 1, 1, 10,7),
      new Tile(2, 2, 1, 1, 11,5),
    };
  }
  Tile[] layout1() {
    return new Tile[] { // medium
      new Tile(0, 0, 1, 2, 1, 0),
      new Tile(1, 0, 2, 2, 2, 1),
      new Tile(3, 0, 1, 2, 3, 2),
      new Tile(0, 2, 1, 2, 4, 2),
      new Tile(3, 2, 1, 2, 5, 0),
      new Tile(1, 2, 2, 1, 6, 3),
      new Tile(1, 3, 1, 1, 7, 6),
      new Tile(2, 3, 1, 1, 8, 4),
      new Tile(0, 4, 1, 1, 9, 7),
      new Tile(3, 4, 1, 1, 10,7),
    };
  }
  Tile[] layout2() {
    return new Tile[] { // hard
      new Tile(0, 0, 1, 2, 1, 0),
      new Tile(1, 0, 2, 2, 2, 1),
      new Tile(3, 0, 1, 2, 3, 2),
      new Tile(0, 3, 2, 1, 4, 3),
      new Tile(2, 3, 2, 1, 5, 3),
      new Tile(0, 2, 1, 1, 6, 6),
      new Tile(1, 2, 2, 1, 7, 3),
      new Tile(3, 2, 1, 1, 8, 4),
      new Tile(0, 4, 1, 1, 9, 7),
      new Tile(3, 4, 1, 1, 10,7),
    };
  }
  TileSet() {
    for (int i = 0; i < WIDTH; i++) {
      for (int j = 0; j < HEIGHT; j++) {
        map[i][j] = 0;
      }
    }
    moving = 0;
    movingId = 0;
    hoverOn = 0;
    goalOffset = 0;
    goal = false;
    stepCount = 0;
    justReset = true;
    set = (layout == 0 ? layout0() :
           layout == 1 ? layout1() :
           layout == 2 ? layout2() : null);
    empty = new Tile[] {
      new Tile(1, 4, 1, 1, -1, -1),
      new Tile(2, 4, 1, 1, -2, -1),
    };
  }
  void draw() {
    hoverOn = hoverOn();
    for (int i = 0; i < set.length; i++) {
      set[i].draw();
    }
    hoverOn = hoverOn();
    if (hoverOn > 0) {
      set[hoverOn - 1].drawDir();
    }
  }
  void mousePressed() {
    int i = hoverOn();
    if (i > 0) {
      set[i - 1].mousePressed();
    }
  }
  int hoverOn() {
    int px = mouseX - baseX;
    int py = mouseY - baseY;
    if (0 <= px && px < WIDTH  * unit &&
        0 <= py && py < HEIGHT * unit)
    {
      px /= unit;
      py /= unit;
      return map[px][py];
    }
    return 0;
  }
  void move(int x, int y, int vx, int vy) {
    set[map[x][y] - 1].move(vx, vy);
  }
  void moveEmpty(int x, int y, int vx, int vy) {
    int i = -1 - map[x][y];
    empty[i].x += vx;
    empty[i].y += vy;
    map[empty[i].x][empty[i].y] = -1 - i;
  }
}

class Trail {
  private List<TrailStep> list = new LinkedList<TrailStep>();
  private Iterator<TrailStep> iterator = null;
  public void add(int tile, int vx, int vy) {
    list.add(new TrailStep(tile, vx, vy));
  }
  public int size() {
    return list.size();
  }
  public void run() {
    if (moving > 0 || goal) return;
    if (iterator == null) {
      iterator = list.iterator();
    }
    if (! iterator.hasNext()) return;
    TrailStep step = iterator.next();
    int x = tileSet.empty[step.empty].x;
    int y = tileSet.empty[step.empty].y;
    tileSet.move(x + step.vx, y + step.vy, -step.vx, -step.vy);
  }
}

class TrailStep {
  int empty, vx, vy;
  TrailStep(int empty_, int vx_, int vy_) {
    empty = empty_;
    vx = vx_;
    vy = vy_;
  }
}

