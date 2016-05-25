package lamb_escape;

import java.util.*;
import java.io.*;

/**
 * A solver for a lamb-escape (a classic tile sliding) puzzle.
 * The initial layout is read from stdin, and the answer is
 * written to stdout.
 * Note that a very simple breadth-first search algorithm is adopted,
 * and thus there is the possibility of an OutOfMemoryError.
 * Programmed by Yoshiaki Takata, 2013.
 *
 * Input format:
 * n is the number of tiles larger than the unit square.
 * m is the number of empty spaces.
 *   n m
 *   x_0 y_0 w_0 h_0
 *   x_1 y_1 w_1 h_1
 *   ...
 *   x_(n-1) y_(n-1) w_(n-1) h_(n-1)
 *   empty_x_0 empty_y_0
 *   ...
 *   empty_x_(m-1) empty_y_(m-1)
 *
 * Output format:
 * empty_i is the index (0..m-1) of the moving space.
 * vx_i and vy_i is the moving direction of that space.
 *   num_of_reached_states
 *   ...
 *   SUCCESS
 *   empty_0 vx_0 vy_0
 *   empty_1 vx_1 vy_1
 *   empty_2 vx_2 vy_2
 *   ...
 */
public class Solver implements Runnable {
  public static void main(String[] arg) {
    new Thread(new Solver()).start();
  }

  public void run() {
    State start = State.initialState();
    State goal  = search(start);
    goal.generateTrail();
  }

  /**
   * Run a breadth-first search.
   */
  protected State search(State initialState) {
    Set<State> prev  = new HashSet<State>(); // (n-1)-th generation of states
    Set<State> queue = new HashSet<State>(); // n-th generation of states
    queue.add(initialState);
    int nState = 1;

    while (! queue.isEmpty()) {
      Set<State> next = new HashSet<State>(); // (n+1)-th generation
      for (State state : queue) {
        if (state.isGoal()) {
          System.out.println("SUCCESS");
          return state;
        }

        // Add new states, which are not in prev, to next.
        // Note: in this puzzle, from a state of the n-th generation,
        // only states of (n-1)-th or (n+1)-th generation can be the next.
        for (State s : state.next()) {
          if (! prev.contains(s)) next.add(s);
        }
      }
      prev  = queue;
      queue = next;
      nState += next.size();
      System.out.println(nState);
    }
    return null;
  }
}

/**
 * The class of the states of this game.
 * We assume that the number of the empty tiles is two.
 * We only keep the positions of empty tiles as well as
 * the tiles that are larger than the unit square,
 * for reducing the state space.
 */
class State {
  final private static int WIDTH  = 4;
  final private static int HEIGHT = 5;
  final private static int GOAL_X = 1;
  final private static int GOAL_Y = 3;
  final private static int GOAL_TILE = 1;

  final private static int[] vx = {  0, -1, 0, 1 };
  final private static int[] vy = { -1,  0, 1, 0 };

  private static int[] width;
  private static int[] height;
  private static int EMPTY1, EMPTY2;

  private byte[] x, y;
  private State prev = null;  // used for generating the trail to the goal

  /**
   * Factory method for creating the initial state.
   */
  public static State initialState() {
    State state = new State();
    state.new Loader().load(System.in);
    return state;
  }

  private State() {}

  /**
   * Constructor for creating a copy of a State.
   */
  private State(State s) {
    x = new byte[s.x.length];
    y = new byte[s.x.length];
    for (int i = 0; i < x.length; i++) {
      this.x[i] = s.x[i];
      this.y[i] = s.y[i];
    }
    this.prev = s;
  }

  public boolean equals(Object o) {
    if (! (o instanceof State)) return false;
    State that = (State)o;
    for (int i = 0; i < x.length; i++) {
      if (x[i] != that.x[i] || y[i] != that.y[i]) return false;
    }
    return true;
  }
  public int hashCode() {
    int codeX = 0;
    int codeY = 0;
    for (int i = 0; i < x.length; i++) {
      codeX = (codeX << 4) + x[i];
      codeY = (codeY << 4) + y[i];
    }
    return codeX + codeY * 7;
  }
  public String toString() {
    StringBuffer buf = new StringBuffer("[");
    for (int i = 0; i < x.length; i++) {
      buf.append("(" + x[i] + "," + y[i] + ")");
    }
    buf.append("]");
    if (prev != null) {
      buf.append("\n" + prev.toString());
    }
    return buf.toString();
  }

  public boolean isGoal() {
    return x[GOAL_TILE] == GOAL_X && y[GOAL_TILE] == GOAL_Y;
  }

  /**
   * The next states of this state.
   */
  public Set<State> next() {
    Set<State> next = new HashSet<State>();
    for (int i = 0; i < EMPTY1; i++) {
      tryMove(i, width[i], height[i], next);
    }
    tryMoveEmpty(EMPTY1, EMPTY2, next);
    tryMoveEmpty(EMPTY2, EMPTY1, next);
    return next;
  }

  private boolean canMove1(int i, int vx, int vy, int emp) {
    return (x[i] + vx == x[emp] && y[i] + vy == y[emp]);
  }
  private boolean canMove2(int i, int vx0, int vx1, int vy0, int vy1,
                           int emp1, int emp2)
  {
    return (x[i] + vx0 == x[emp1] && y[i] + vy0 == y[emp1]
         && x[i] + vx1 == x[emp2] && y[i] + vy1 == y[emp2]);
  }
  private void move1(int i, int vx, int vy, int emp, int evx, int evy) {
    x[i] += vx;
    y[i] += vy;
    x[emp] += evx;
    y[emp] += evy;
  }
  private void move2(int i, int vx, int vy, int evx, int evy) {
    x[i] += vx;
    y[i] += vy;
    x[EMPTY1] += evx;
    y[EMPTY1] += evy;
    x[EMPTY2] += evx;
    y[EMPTY2] += evy;
  }
  private void tryMove(int i, int w, int h, Set<State> next) {
    for (int dir = 0; dir < 4; dir++) {
      int vx0 = (vx[dir] == 1 ? w : vx[dir]);
      int vy0 = (vy[dir] == 1 ? h : vy[dir]);
      if ((vx0 == 0 && w == 1) || (vy0 == 0 && h == 1)) {
        for (int emp = EMPTY1; emp <= EMPTY2; emp++) {
	  if (canMove1(i, vx0, vy0, emp)) {
	    State nstate = new State(this);
	    nstate.move1(i, vx[dir], vy[dir], emp, -vx[dir]*w, -vy[dir]*h);
	    next.add(nstate);
	  }
	}
      } else {
	int vx1 = (vx0 == 0 ? 1 : vx0);
	int vy1 = (vy0 == 0 ? 1 : vy0);
	if (canMove2(i, vx0, vx1, vy0, vy1, EMPTY1, EMPTY2) ||
	    canMove2(i, vx0, vx1, vy0, vy1, EMPTY2, EMPTY1))
	{
          State nstate = new State(this);
          nstate.move2(i, vx[dir], vy[dir], -vx[dir]*w, -vy[dir]*h);
          next.add(nstate);
        }
      }
    }
  }
  private boolean emptyCanMove(int emp, int vx, int vy, int emp2) {
    int nx = x[emp] + vx;
    int ny = y[emp] + vy;
    if (nx < 0 || nx >= WIDTH ||
	ny < 0 || ny >= HEIGHT) return false;
    if (nx == x[emp2] && ny == y[emp2]) return false;
    for (int i = 0; i < EMPTY1; i++) {
      if (x[i] <= nx && nx < x[i] + width [i] &&
          y[i] <= ny && ny < y[i] + height[i]) return false;
    }
    return true;
  }
  private void tryMoveEmpty(int emp, int emp2, Set<State> next) {
    for (int dir = 0; dir < 4; dir++) {
      if (emptyCanMove(emp, vx[dir], vy[dir], emp2)) {
        State nstate = new State(this);
	nstate.x[emp] += vx[dir];
	nstate.y[emp] += vy[dir];
        next.add(nstate);
      }
    }
  }

  /**
   * Generate the sequence of moves from the start state to this state.
   */
  public void generateTrail() {
    new TrailGenerator().generate(System.out);
  }

  /**
   * A utility class for loading the initial state from the stdin.
   */
  class Loader {
    /**
     * Input format:
     * n m
     * x1 y1 w1 h1
     * x2 y2 w2 h2
     * ...
     * xn yn wn hn
     * ex1 ey1
     * ex2 ey2
     * ...
     * exm eym
     */
    public void load(InputStream in) {
      State state = State.this;
      Scanner scanner = new Scanner(in);
      int n = scanner.nextInt();
      int m = scanner.nextInt();
      width  = new int[n];
      height = new int[n];
      state.x = new byte[n + m];
      state.y = new byte[n + m];
      for (int i = 0; i < n; i++) {
        state.x[i] = scanner.nextByte();
        state.y[i] = scanner.nextByte();
        width  [i] = scanner.nextInt();
        height [i] = scanner.nextInt();
      }
      for (int i = 0; i < m; i++) {
        state.x[n + i] = scanner.nextByte();
        state.y[n + i] = scanner.nextByte();
      }
      EMPTY1 = n;
      EMPTY2 = n + 1;
    }
  }

  /**
   * A utility class for writing the trail to the stdout.
   */
  class TrailGenerator {
    public void generate(PrintStream out) {
      // Reverse the sequence.
      LinkedList<State> deque = new LinkedList<State>();
      for (State s = State.this; s != null; s = s.prev) {
        deque.addFirst(s);
      }

      // Translate the sequence of state to the sequence of moves.
      for (State s : deque) {
        if (s.prev == null) continue;
        int emp = EMPTY1;
        int vx = s.x[emp] - s.prev.x[emp];
        int vy = s.y[emp] - s.prev.y[emp];
        if (vx == 0 && vy == 0) {
          emp++;
          vx = s.x[emp] - s.prev.x[emp];
          vy = s.y[emp] - s.prev.y[emp];
        }
        if (vx == 2 || vx == -2) vx /= 2;
        if (vy == 2 || vy == -2) vy /= 2;
        out.println("" + (emp - EMPTY1) + " " + vx + " " + vy);
      }
      out.flush();
    }
  }
}
