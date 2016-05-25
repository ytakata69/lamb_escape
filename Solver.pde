import java.io.*;
import java.util.Scanner;

/**
 * The interface to an external puzzle solver.
 * This interface object executes the solver and communicates with it
 * through stdin and stdout.
 * Programmed by Yoshiaki Takata, 2013.
 *
 * Note: The solver is just a Java program but we execute it in
 * a separate JVM, because it may consume much memory and interfere
 * the animation of this sketch.
 * The solver code (Solver.jar) is placed in the sketch folder
 * as like as an imported library.
 */
class Solver implements Runnable {
  public volatile boolean finished = false;
  public volatile int nReached = 0;
  private Trail trail;
  private TileSet tileSet;

  public Solver(TileSet tileSet_, Trail trail_) {
    tileSet = tileSet_;
    trail = trail_;
  }

  final String SOLVER_CLASS = "lamb_escape.Solver";
  final String CLASS_PATH = System.getProperty("java.class.path");
  final String[] CMD_SOLVER = { "java", "-cp", CLASS_PATH, SOLVER_CLASS };

  public void run() {
    try {
      run(CMD_SOLVER);
    } catch (IOException e) {
    }
    finished = true;
  }

  protected void run(String[] cmd) throws IOException
  {
    for (String c : cmd) {
      System.out.print((c.length() <= 64 ? c : c.substring(0, 64) + "...") + " ");
    }
    System.out.print("...");
    System.out.flush();

    Process proc = Runtime.getRuntime().exec(cmd);
    this.writeTo (proc.getOutputStream());
    this.readFrom(proc.getInputStream());

    try {
      proc.waitFor();
    } catch (InterruptedException e) {
    }
    System.out.println("done");
  }

  public void writeTo(OutputStream outStream) throws IOException {
    PrintWriter out = new PrintWriter(new OutputStreamWriter(outStream));
    int n = 0;
    for (Tile tile : tileSet.set) {
      if (tile.width <= 1 && tile.height <= 1) continue;
      n++;
    }
    int m = tileSet.empty.length;
    out.println("" + n + " " + m);
    for (Tile tile : tileSet.set) {
      if (tile.width <= 1 && tile.height <= 1) continue;
      out.print(""  + tile.x);
      out.print(" " + tile.y);
      out.print(" " + tile.width);
      out.print(" " + tile.height);
      out.println();
    }
    for (Tile tile : tileSet.empty) {
      out.print(""  + tile.x);
      out.print(" " + tile.y);
      out.println();
    }
    out.close();
  }

  public void readFrom(InputStream in) throws IOException {
    BufferedReader reader = new BufferedReader(new InputStreamReader(in));
    boolean solved = false;
    String line;
    while ((line = reader.readLine()) != null) {
      if (line.equals("SUCCESS")) {
        solved = true;
        continue;
      }
      Scanner scanner = new Scanner(line);
      if (solved) {
        int empty = scanner.nextInt();
        int vx    = scanner.nextInt();
        int vy    = scanner.nextInt();
        trail.add(empty, vx, vy);
      } else {
        nReached = scanner.nextInt();
      }
    }
    System.out.print(" (" + trail.size() + " steps) ");
    reader.close();
  }
}

