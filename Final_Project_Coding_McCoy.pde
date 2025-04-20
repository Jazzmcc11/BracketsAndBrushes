// FINAL EXAM PROJECT: LEGACY SKIES (Mandala Expanded + Color Shifts + Dynamic Rounds)

import processing.sound.*;

SoundFile bgMusic, rainSound, victorySound;

String state = "start";
Mandala mandala;
Weather weather;
PFont font;
int round = 1;

void setup() {
  size(900, 600);
  frameRate(60);

  bgMusic = new SoundFile(this, "bg_theme.mp3");
  rainSound = new SoundFile(this, "Rain.wav");
  victorySound = new SoundFile(this, "Victory.mp3");

  bgMusic.loop();

  mandala = new Mandala();
  weather = new Weather();
  font = createFont("Courier-Bold", 24);
}

void draw() {
  drawGradientBackground();
  drawSun();
  weather.displayClouds();

  if (state.equals("start")) {
    drawStartScreen();
  } else if (state.equals("playing")) {
    mandala.display();
    weather.update();
    weather.displayRain();
  } else if (state.equals("win")) {
    drawVictoryScreen();
  }
}

void keyPressed() {
  if (state.equals("start") && keyCode == ENTER) {
    state = "playing";
    rainSound.loop();
  } else if (state.equals("playing") && (key == 'v' || key == 'V')) {
    state = "win";
    rainSound.stop();
    victorySound.play();
  } else if ((state.equals("playing") || state.equals("win")) && (key == 'n' || key == 'N')) {
    round++;
    mandala.generateNew(round);
    state = "playing";
    rainSound.loop();
  }
}

void drawGradientBackground() {
  for (int i = 0; i < height; i++) {
    float inter = map(i, 0, height, 0, 1);
    color c = lerpColor(color(255, 140, 0), color(255, 255, 255), inter);
    stroke(c);
    line(0, i, width, i);
  }
}

void drawSun() {
  noStroke();
  fill(255, 204, 0, 180);
  ellipse(width - 100, 100, 120, 120);
  fill(255, 255, 255, 50);
  ellipse(width - 100, 100, 180, 180);
}

void drawStartScreen() {
  textFont(font);
  fill(255);
  textAlign(CENTER);
  textSize(36);
  text("🌅 Legacy Skies 🌅", width/2, height/2 - 40);
  textSize(18);
  fill(255);
  text("Press ENTER to Begin", width/2, height/2);
}

void drawVictoryScreen() {
  textFont(font);
  fill(255);
  textAlign(CENTER);
  textSize(32);
  text("✨ You Unlocked the Legacy ✨", width/2, height/2);
  textSize(18);
  fill(255);
  text("Press N to continue.", width/2, height/2 + 40);
}

class Mandala {
  int petals;
  float angleOffset = 0;
  float scaleFactor;
  float pulse = 0;
  color baseColor;
  float spinSpeed;
  float shapeVariance;

  Mandala() {
    generateNew(1);
  }

  void generateNew(int r) {
    petals = 12 + r * 2;
    angleOffset = random(TWO_PI);
    baseColor = color(200 + r * 5 % 55, 100 + r * 10 % 155, 255 - r * 20 % 200);
    scaleFactor = 1.6 + r * 0.2;
    pulse = 0;
    spinSpeed = 0.01 + r * 0.002;
    shapeVariance = 3 + r % 5;
  }

  void display() {
    pulse += 0.05;
    float dynamicScale = scaleFactor + 0.1 * sin(pulse);

    pushMatrix();
    translate(width/2, height/2);
    rotate(pulse * spinSpeed);
    scale(dynamicScale);
    noFill();
    stroke(baseColor);
    strokeWeight(2);
    for (int i = 0; i < petals; i++) {
      float angle = TWO_PI * i / petals + angleOffset;
      pushMatrix();
      rotate(angle);
      drawPetal();
      popMatrix();
    }
    popMatrix();
  }

  void drawPetal() {
    beginShape();
    for (float a = 0; a < TWO_PI; a += 0.2) {
      float r = 90 + 40 * sin(a * shapeVariance + frameCount * 0.05);
      float x = cos(a) * r;
      float y = sin(a) * r;
      vertex(x, y);
    }
    endShape(CLOSE);
  }
}

class Weather {
  ArrayList<PVector> drops;
  ArrayList<PVector> clouds;
  float cloudShift = 0;

  Weather() {
    drops = new ArrayList<PVector>();
    clouds = new ArrayList<PVector>();
    for (int i = 0; i < 100; i++) {
      drops.add(new PVector(random(width), random(-height, 0)));
    }
    for (int i = 0; i < 6; i++) {
      clouds.add(new PVector(random(width), random(60, 180)));
    }
  }

  void update() {
    cloudShift += 0.01;
    for (PVector d : drops) {
      d.y += 4;
      if (d.y > height) {
        d.y = random(-100, 0);
        d.x = random(width);
      }
    }
    for (PVector c : clouds) {
      c.x += 0.2;
      if (c.x > width + 60) c.x = -60;
    }
  }

  void displayRain() {
    stroke(255);
    for (PVector d : drops) {
      line(d.x, d.y, d.x, d.y + 10);
    }
  }

  void displayClouds() {
    noStroke();
    fill(255, 240);
    for (PVector c : clouds) {
      ellipse(c.x, c.y, 60, 40);
      ellipse(c.x + 20, c.y + 10, 50, 30);
      ellipse(c.x - 20, c.y + 10, 50, 30);
    }
  }
}
