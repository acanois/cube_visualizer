class Cube {

  HighPassSP highpass;

  Minim minim;
  AudioInput in;

  FFT fftLog;

  float theta;

  // Smoothing
  float smoothing = 0.95;
  float[] fftSmooth;
  int     avgSize;

  int cutoff = 500;
  int sizeMult = 1000;

  float xPos;
  float yPos;

  Cube(float x_, float y_) {
    translate(width/2, height/2);
    minim = new Minim( this );

    // use the getLineIn method of the Minim object to get an AudioInput
    in        = minim.getLineIn(Minim.STEREO, 512);
    fftLog    = new FFT(in.bufferSize(), in.sampleRate());
    fftLog.logAverages(64, 128);
    avgSize   = fftLog.avgSize();
    fftSmooth = new float[avgSize]; 
    
    colorMode(HSB, avgSize, 100, 100);

    highpass = new HighPassSP(cutoff, in.sampleRate());
    in.addEffect(highpass);

    xPos = x_;
    yPos = y_;

    theta = 0;
    println("xPos: "+xPos+", yPos: "+yPos);
  }

  void update() {
    theta += 0.001;
  }


  void display() {
    fftLog.forward(in.mix);

    // Only draw the first so many bands because the upper bands are all red, and not interesting.
    for (int i = 1; i < (fftLog.avgSize() / 2.5); i++) {
      float band = fftLog.getBand(i);

      fftSmooth[i] *= smoothing;
      
      if (fftSmooth[i] < band) { 
        fftSmooth[i] = band;
      }

      float ellipseSize = fftSmooth[i] * sizeMult;
      float redVal = map(ellipseSize, 0, 300, 100, 255);
      float alpha  = map(ellipseSize, 0, 300, 0, 255);

      if (ellipseSize > 500) {
        alpha = 0;
      }

      pushMatrix();
      pushStyle();
        strokeWeight(2);
        noFill();
        translate(xPos, yPos);
        rotateX(PI/4);
        rotateZ(PI/4);
        stroke(i*2, 55, 50, alpha);
        box(i, i, i);
      popStyle();
      popMatrix();
      i += 10;
    }
  }
}