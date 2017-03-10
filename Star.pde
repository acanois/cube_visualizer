class Star {

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

  Star(float x_, float y_) {
    translate(width/2, height/2);
    minim = new Minim( this );

    // use the getLineIn method of the Minim object to get an AudioInput
    in        = minim.getLineIn(Minim.STEREO, 512);
    fftLog    = new FFT(in.bufferSize(), in.sampleRate());
    fftLog.logAverages(64, 128);
    avgSize   = fftLog.avgSize();
    fftSmooth = new float[avgSize];
    //fftReal   = new float[avgSize];
    // calculate averages based on a miminum octave width of 22 Hz
    // split each octave into three bands
    // this should result in 30 averages

    // uncomment this line to *hear* what is being monitored, in addition to seeing it
    // in.enableMonitoring(); 
    
    colorMode(HSB, avgSize, 100, 100);

    highpass = new HighPassSP(cutoff, in.sampleRate());
    in.addEffect(highpass);

    xPos = x_;
    yPos = y_;

    theta = 0;
    println("xPos: "+xPos+", yPos: "+yPos);
  }

  void update() {
    theta += 0.002;
  }


  void display() {

    // camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);

    fftLog.forward(in.mix);


    float sphereDet = in.left.get(100)*300;
    float stereoMix = in.left.get(100) + in.right.get(100);
    float rotation = stereoMix * 5000;
    float bangCircle = fftSmooth[100] * sizeMult;
    int iSphere = int(sphereDet);
    bangCircle += smoothing;
    // float cAlpha  = map(bangCircle, 0, 300, 0, 255);


    /* BRIGHT WHITE FFT */
    pushMatrix();
    translate(width/2, height/2);
    //strokeWeight(2);
    stroke(255, bangCircle*2);
    noFill();
    sphereDetail(iSphere/3);
    //sphere(bangCircle);
    popMatrix();

    for (int i = 1; i < fftLog.avgSize(); i++) {

      // Ripple Effect
      //int iOffset  = (i + frameCount) % fftLog.avgSize();
      int iOffset = 0;
      int iOffset2 = (i + frameCount) * 2 % fftLog.avgSize();
      int iOffset3 = (i + frameCount) * 3 % fftLog.avgSize();
      float band = fftLog.getBand(i);

      //int w = int(width/fft.avgSize());
      fftSmooth[i] *= smoothing;
      if (fftSmooth[i] < band) fftSmooth[i] = band;

      float ellipseSize = fftSmooth[i] * sizeMult;
      float redVal = map(ellipseSize, 0, 300, 100, 255);
      float alpha  = map(ellipseSize, 0, 300, 255, 100);

      if (ellipseSize < 10) {
        alpha = 0;
      }

      pushMatrix();
      pushStyle();
        strokeWeight(2);
        noFill();
        translate(xPos, yPos);
        rotateX(theta*.8 + i);
        rotateY(theta*.8 + i);
        rotateZ(theta*.8 + i);
        stroke(i*2, 55, 50, -alpha);
        box(i, i, i);
        //line(i, -i * sin(theta), 0, 0 - ellipseSize/2);
        //pushMatrix();
        //pushStyle();
        //  ////rotateY(theta);
        //  //stroke(200, alpha);
        //  //ellipse(i, 0, 0, 0 - ellipseSize);
        //  //ellipse(-i, 0, 0, 0 + ellipseSize);
        //popStyle();
        //popMatrix();
        //line(-i, i*sin(theta), 0, 0 + ellipseSize/2);
        //line(-i, -i*cos(theta), 0, 0 - ellipseSize/2);
      popStyle();
      popMatrix();
      i += 10;
    }
  }
}