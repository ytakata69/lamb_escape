import ddf.minim.*;

/**
 * Image files.
 * <a href="http://foter.com/photo/spring-lamb/">"Spring Lamb"</a>: <a href="http://www.flickr.com/photos/essjay/229819241/">EssjayNZ</a> / <a href="http://foter.com">Foter</a> / <a href="http://creativecommons.org/licenses/by-nc-sa/2.0/">CC BY-NC-SA</a>
 * <a href="http://foter.com/photo/the-wild-side-of-yellowstone-3/">"The Wild Side of Yellowstone"</a>: <a href="http://www.flickr.com/photos/stuckincustoms/2951173796/">Stuck in Customs</a> / <a href="http://foter.com">Foter</a> / <a href="http://creativecommons.org/licenses/by-nc-sa/2.0/">CC BY-NC-SA</a>
 * <a href="http://www.vectorjungle.com/2010/09/free-vector-jungle-background/">"Free Vector Jungle Background"</a>: <a href="http://www.vectorjungle.com">VectorJungle.com</a>
 * <a href="http://all-silhouettes.com/vector-trees/">"Mass Vector Trees"</a>: <a href="http://all-silhouettes.com">All-silhouettes.com</a>
 * <a href="http://subtlepatterns.com/wood-pattern/">"Wood pattern"</a>: <a href="http://subtlepatterns.com">SubtlePatterns.com</a>
 */
class ImageStock {
  PImage background = loadImage("background.png");
  PImage backboard  = loadImage("backboard.png");
  PImage[] tile = {
    loadImage("woodtileVG1.png"),
    loadImage("woodtile.png"),
    loadImage("woodtileVG2.png"),
    loadImage("woodtileHW.png"),
    loadImage("woodtileSG1.png"),
    loadImage("woodtileSG2.png"),
    loadImage("woodtileSG3.png"),
    loadImage("woodtileSW.png"),
  };
  final static String copyright =
        "Lamb: EssjayNZ \"Spring lamb\", "
      + "Wolf: Stuck in Customs \"The wild side of yellowstone 3\", "
      + "Jungle: VectorJungle.com, "
      + "Trees: All-Silhouettes.com, "
      + "Wood: SubtlePatterns.com"
      ;
  String copyright() { return copyright; }
}

/**
 * Audio files.
 * "Crrect_answer3.mp3" from <a href="http://taira-komori.jpn.org/freesound.html">Free Sound Effects</a>
 */
class AudioStock {
  Minim minim;

  // audio files were downloaded from:
  // http://taira-komori.jpn.org/freesound.html
  AudioSnippet click;
  AudioSnippet fanfare;

  // Yuruyaka na azemichi de,
  // Makoto Yoshimori,
  // from Natsume Yujincho Ongaku Shu
  // Otonoke no Sasagemono,
  // Sony Music Entertainment (2008)
  AudioPlayer bgm = null;

  AudioStock(PApplet app) {
    minim = new Minim(app);
    fanfare = minim.loadSnippet("Crrect_answer3.mp3");
    copyright = "";
    try {
      bgm   = minim.loadFile("05s_azemichi.mp3");
      copyright = "BGM: Makoto Yoshimori \"Yuruyaka na azemichi de\", ";
    } catch (Exception e) {
      bgm = null;
    }
    copyright += "Chime: Taira Komori \"Crrect_answer3\"";
  }
  void playBGM() {
    if (bgm != null) bgm.loop();
  }
  void playFanfare() {
    fanfare.rewind();
    fanfare.play();
  }
  void close() {
    if (bgm != null) bgm.close();
    fanfare.close();
    minim.stop();
  }
  String copyright;
  String copyright() { return copyright; }
}

class FontStock {
  PFont menu   = loadFont("Candara-20.vlw");
  PFont banner = loadFont("GillSans-Bold-40.vlw");
}

