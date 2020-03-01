

import processing.video.*;
Capture video;
int bSize = 20, dMax = 22, xNum, yNum;
float[][] r, g, b;

class Pixels {
  int xpos, ypos, xpair, ypair;
  float deff;
  color col;
  boolean boo;
  Pixels(int y1, int x1, int x2, int y2, float d, color c, boolean b) {
    xpos = x1;
    ypos = y1;
    xpair = x2;
    ypair = y2;
    deff = d;
    col = c;
    boo = b;
  }
}

Pixels[][] p;



void setup() {
  size(1280, 720); //enter a multiple of bSize
  video = new Capture(this, width, height);
  video.start();
  frameRate(20);

  xNum = width/bSize;
  yNum = height/bSize;

  p = new Pixels[yNum][xNum];
  for (int i=0; i < yNum; i++) {
    for (int j=0; j < xNum; j++) {
      p[i][j] = new Pixels(0, 0, 0, 0, 0, 0, false);
    }
  }

  r = new float[yNum][xNum];
  g = new float[yNum][xNum];
  b = new float[yNum][xNum];  
}

void draw() {
  if (video.available()) {  
    video.read(); 
    video.loadPixels(); 
    background(0);
    for (int y = 0; y < yNum; y++) {
      for (int x = 0; x < xNum; x++) {
        p[y][x].xpos = 0;
        p[y][x].ypos = 0;
        float dr = abs( r[y][x] - red(video.pixels[y*bSize*video.width + x*bSize]) );
        float dg = abs( g[y][x] - green(video.pixels[y*bSize*video.width + x*bSize]));
        float db = abs( b[y][x] - blue(video.pixels[y*bSize*video.width + x*bSize]) );
        p[y][x].deff = sqrt(dr*dr+dg*dg+db*db);
        r[y][x] = red(video.pixels[y*bSize*video.width + x*bSize]);
        g[y][x] = green(video.pixels[y*bSize*video.width + x*bSize]);
        b[y][x] = blue(video.pixels[y*bSize*video.width + x*bSize]);
        if (p[y][x].deff > dMax) {
          p[y][x].xpos = x;
          p[y][x].ypos = y;
          p[y][x].col =  video.pixels[y*bSize*video.width + x*bSize];
        }
      }
    }
    for (int y1 = 0; y1 < yNum; y1++) {
      for (int x1 = 0; x1 < xNum; x1++) {
        for (int y2 = 0; y2 < yNum; y2++) {
          for (int x2 = 0; x2 < xNum; x2++) {
            if (dist(p[y1][x1].xpos, p[y1][x1].ypos, p[y2][x2].xpos, p[y2][x2].ypos) < 5) {
              p[y1][x1].xpair = x2;
              p[y1][x1].ypair = y2;
            }
          }
        }
      }
    }

    for (int y = 0; y < yNum; y++) {
      for (int x = 0; x < xNum; x++) {
        if (p[y][x].deff > dMax) {
          strokeWeight(p[y][x].deff/20);
          stroke(p[y][x].col);
          line(width - x*bSize, y*bSize, width - p[y][x].xpair*bSize, p[y][x].ypair*bSize);
        }
      }
    }

    for (int y = 0; y < yNum; y++) {
      for (int x = 0; x < xNum; x++) {
        if (p[y][x].deff > dMax) {
          fill(video.pixels[y*bSize*video.width + x*bSize]);
          float eSize = map(p[y][x].deff/3, dMax/3, 300, 0, 300);
          noStroke();
          ellipse(width - x*bSize, y*bSize, eSize, eSize);
        }
      }
    }
  }
}
