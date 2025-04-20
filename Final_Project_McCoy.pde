import processing.sound.*;
import java.text.SimpleDateFormat;
import java.util.Date;

SoundFile song;
Amplitude amp;

ArrayList<VerletNote> notes;
GrowingDNA dna;

FloatingFrame dtrt, mookie;
PImage bgImage;
PImage imgDTRT, imgMookie, imgVerlet;

boolean showTitle = true;
int mood = 0;

color[][] dnaColors = {
  {#2980B9, #ECF0F1},
  {#D35400, #F1C40F},
  {#8E44AD, #F39C12},
  {#1ABC9C, #F7DC6F}
};

void setup() {
  size(800, 800, P3D);
  smooth(8);
  song = new SoundFile(this, "VM.mp3");
  song.loop();
  amp = new Amplitude(this);
  amp.input(song);

  imgVerlet = loadImage("Verlet.jpeg");
  imgDTRT = loadImage("DTRT.jpg");
  imgMookie = loadImage("Mookie.jpeg");

  imgVerlet.resize(width, height);
  imgDTRT.resize(100, 100);
  imgMookie.resize(100, 100);
  bgImage = imgVerlet;

  dna = new GrowingDNA(new PVector(0, 0, 0), 80, 300, 100);

  notes = new ArrayList<VerletNote>();
  for (int i = 0; i < 12; i++) {
    float x = random(width/2 - 150, width/2 + 150);
    float y = random(height/2 - 100, height/2 + 200);
    float z = random(-100, 100);
    notes.add(new VerletNote(new PVector(x, y, z)));
  }

  dtrt = new FloatingFrame(imgDTRT, new PVector(width/2 - 150, height/2, 100));
  mookie = new FloatingFrame(imgMookie, new PVector(width/2 + 150, height/2 - 100, 80));
}
void draw() {
  if (showTitle) {
    drawTitleScreen();
    return;
  }

  background(30);

  imageMode(CORNER);
  pushMatrix();
  translate(0, 0, -300);
  tint(255, 160);
  image(bgImage, 0, 0, width, height);
  noTint();
  popMatrix();

  ambientLight(80, 80, 80);
  pointLight(255, 255, 255, width/2, height/2, 300);

  drawFloor();
  drawVinyl();
  drawForwardDNA();

  for (VerletNote note : notes) {
    note.update();
    note.display();
  }

  dtrt.update();
  dtrt.display();
  mookie.update();
  mookie.display();
}

void drawTitleScreen() {
  background(30);
  tint(255, 100);
  image(bgImage, 0, 0, width, height);
  noTint();

  fill(0, 180);
  rect(0, 0, width, height);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(36);
  text("🎶 Vibes and Spike Lee Jointz 🎥", width/2, height/4);
  textSize(16);
  text("💿 Click music notes to glow\n🎞 Click images to spin\n🧬 DNA grows toward you\n🌈 Click to shift mood\n📷 Press 'S' to screenshot\n\n▶ Click or press key to start", width/2, height/2);
}

void drawFloor() {
  pushMatrix();
  fill(139, 90, 43);
  noStroke();
  translate(width/2, height, 0);
  rotateX(HALF_PI);
  rectMode(CENTER);
  rect(0, 0, width * 2, 400);
  popMatrix();
}

void drawVinyl() {
  pushMatrix();
  translate(width/2, height/2 + 150, 0);
  rotateX(HALF_PI);
  rotateZ(frameCount * 0.01);

  fill(10);
  noStroke();
  beginShape(TRIANGLE_FAN);
  vertex(0, 0);
  for (float angle = 0; angle <= TWO_PI + 0.1; angle += 0.1) {
    float x = cos(angle) * 150;
    float y = sin(angle) * 150;
    vertex(x, y);
  }
  endShape();

  fill(255);
  ellipse(0, 0, 50, 50);
  fill(200, 0, 0);
  textAlign(CENTER, CENTER);
  textSize(10);
  fill(255);
  text("DNA SOUND", 0, 0);
  popMatrix();
}

void drawForwardDNA() {
  pushMatrix();
  translate(width/2, height/2 + 150, 0);
  dna.grow();
  dna.display();
  popMatrix();
}

void mousePressed() {
  if (showTitle) {
    showTitle = false;
    return;
  }

  mood = (mood + 1) % dnaColors.length;

  for (VerletNote note : notes) {
    note.checkClick(mouseX, mouseY);
  }

  dtrt.toggleSpin();
  mookie.toggleSpin();
}

void keyPressed() {
  if (showTitle) {
    showTitle = false;
    return;
  }

  if (key == 's' || key == 'S') {
    String timestamp = new SimpleDateFormat("yyyy-MM-dd_HHmm").format(new Date());
    saveFrame("screenshot_" + timestamp + ".png");
  }
}
class VerletNote {
  PVector pos;
  float baseSize;
  float angle;
  boolean glow = false;

  VerletNote(PVector pos) {
    this.pos = pos.copy();
    this.baseSize = 20;
    this.angle = random(TWO_PI);
  }

  void update() {
    pos.y -= 0.1;
    pos.x += sin(angle) * 0.3;
    pos.z += cos(angle * 0.5) * 0.2;
    angle += 0.003;
  }

  void display() {
    float ampLevel = amp.analyze();
    float pulse = map(ampLevel, 0, 0.5, 1, 2);
    float size = baseSize * pulse;

    // Color changes with volume
    int noteColor = lerpColor(color(100, 100, 255), color(255, 100, 100), ampLevel * 2);
    strokeWeight(1.5);
    stroke(glow ? color(255, 255, 0) : noteColor);
    fill(noteColor, 180);

    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    rotateZ(angle);
    ellipse(0, 0, size, size);
    line(size/2, 0, size/2, -size * 2);
    popMatrix();
  }

  void checkClick(float mx, float my) {
    float d = dist(mx, my, screenX(pos.x, pos.y, pos.z), screenY(pos.x, pos.y, pos.z));
    if (d < 30) glow = !glow;
  }
}
class FloatingFrame {
  PImage img;
  PVector pos;
  float angle = 0;
  boolean spinning = false;

  FloatingFrame(PImage img, PVector pos) {
    this.img = img;
    this.pos = pos.copy();
  }

  void toggleSpin() {
    spinning = !spinning;
  }

  void update() {
    if (spinning) {
      angle += 0.01;
    }
  }

  void display() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    rotateY(angle);
    imageMode(CENTER);
    image(img, 0, 0, 100, 100);
    popMatrix();
  }
}

class GrowingDNA {
  PVector pos;
  float radius;
  int helixPoints;
  float currentDepth = 0;
  float growthRate = 1;

  GrowingDNA(PVector pos, float radius, float maxDepth, int helixPoints) {
    this.pos = pos.copy();
    this.radius = radius;
    this.helixPoints = helixPoints;
  }

  void grow() {
    currentDepth += growthRate;  // No stopping — keep going!
  }

  void display() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);

    float spacing = currentDepth / helixPoints;
    float[][] strandA = new float[helixPoints][3];
    float[][] strandB = new float[helixPoints][3];

    color c1 = dnaColors[mood][0];
    color c2 = dnaColors[mood][1];

    for (int i = 0; i < helixPoints; i++) {
      float angle = i * 0.3;
      float r = radius / 5;

      float x1 = cos(angle) * r;
      float y1 = sin(angle) * r;
      float z1 = i * spacing;  // Growing toward you

      float x2 = cos(angle + PI) * r;
      float y2 = sin(angle + PI) * r;
      float z2 = z1;

      strandA[i] = new float[]{x1, y1, z1};
      strandB[i] = new float[]{x2, y2, z2};

      noStroke(); fill(c1);
      pushMatrix(); translate(x1, y1, z1); sphere(3); popMatrix();

      fill(c2);
      pushMatrix(); translate(x2, y2, z2); sphere(3); popMatrix();

      if (i % 6 == 0) {
        stroke(255, 180); strokeWeight(1);
        line(x1, y1, z1, x2, y2, z2);
      }
    }

    stroke(c1); strokeWeight(1);
    for (int i = 1; i < helixPoints; i++) {
      line(strandA[i-1][0], strandA[i-1][1], strandA[i-1][2],
           strandA[i][0], strandA[i][1], strandA[i][2]);
      line(strandB[i-1][0], strandB[i-1][1], strandB[i-1][2],
           strandB[i][0], strandB[i][1], strandB[i][2]);
    }

    popMatrix();
  }
}
