import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

Cube cube;

AudioInput in;

Minim minim;

float theta;

void setup() {
  size(1280, 720, OPENGL);
  frameRate(60);
  //background(20);
  cube = new Cube(width/2, height/2);
  smooth(8);
  blendMode(ADD);
  
  theta = 0;
}

void draw() {
  theta += 0.01;
  pushStyle();
  colorMode(RGB);
  background(0);
  popStyle();
  cube.update();
  cube.display();
  /* Eye XYZ, Center XYZ, Up XYZ*/
  camera(width/2.0, height/2.0, (height*0.33) / tan(PI*30.0 / 180.0), 
         width/2.0, height/2.0, 0, 0, 1, 0);
}

void stop() {
  in.close();
  
  minim.stop();
  stop();
}