float centerH = 0;
float widthH = 0.7;

float minS = 0.0;
float maxS = 1.0;
float minB = 0.6;
float maxB = 1.0;

float alpha = 0.5;

float transStart = 0.35;
float transWidth = 0.01;
float transStart2 = 0.45;
float transWidth2 = 0.01;

float[] bandStart = { 0.30 , 0.33 , 0.36 , 0.50 , 0.53 , 0.56 , 0.70 , 0.73 , 0.76 , 0.90 , 0.93 , 0.96 };
float bandWidth = 0.008;

float radTransStart = 0.23;
float radTransWidth = 0.0;

float ah = 0.02;
float as = 0.055;
float ab = 0.055;
float af = 0.012;
float ag = 0.8;

float th = 0.060;
float ts = 0.030;
float tb = 0.010;
float tf = 0.005;
float tc = 0.003;
float tA = 0.4;

int numSpokes = 12;
float ang;
int w = 1;

float[] px;
float[] py;
float[] pf;
int[] pa;

int numPixels = 0;
float posX[];
float posY[];
int pixelX[];
int pixelY[];
float val0[];
float val1[];
float val2[];

int numSteps = 20;
int stepCounter = 0;
int pixPerStep;
int pixelCounter = 0;
float dt = 0.1;
float t = 0;

color[] P;

float cr = 4;
float hourWidth = 0.013;
float hourLength = 0.2;
float minuteWidth = 0.013;
float minuteLength = 0.25;
float secondWidth = 0.01;
float secondLength = 0.57;
float backEnd = 0.04;


int pressTime = 0;
int pressTimeout = 4000;
boolean mPressed = false;

int startTime;
int startSeconds;

float xRes;
float yRes;
void setup() {
  size( 800, 480 );
  xRes = float(width);
  yRes = float(height);
  centerH = random(0, 1);
  noStroke();
  background(0);
  ang = 2*PI/float(numSpokes);

  for( int x = 0 ; x < width/2 ; x++ ) {
    for( int y = 0 ; y <= x && y < height/2 ; y++ ) {
      numPixels++;
    }
  }
  pixPerStep = numPixels / numSteps;
  println( numPixels );
  posX = new float[numPixels];
  posY = new float[numPixels];
  pixelX = new int[numPixels];
  pixelY = new int[numPixels];
  val0 = new float[numPixels];
  val1 = new float[numPixels];
  val2 = new float[numPixels];
  pf = new float[numPixels];
  pa = new int[numPixels];
  P = new color[(width/2)*(height/2)];
  int indexCounter = 0;
  for( int x = 0 ; x < width/2 ; x++ ) {
    for( int y = 0 ; y <= x && y < height/2 ; y++ ) {
      pixelX[indexCounter] = x;
      pixelY[indexCounter] = y;
      
      float x2 = float(x) + 0.5;
      float y2 = float(y) + 0.5;
      PVector v = new PVector( x2, y2 );
      float a = (v.heading() + PI)%ang;
      if ( a > 0.5*ang ) { 
        a = ang - a;
      }
      float r = v.mag();
      posX[indexCounter] = r*cos(a);
      posY[indexCounter] = r*sin(a);
      if ( r < radTransStart*yRes ) {
        pf[indexCounter] = 0;
      } else if  (r >= (radTransStart)*yRes && r < (radTransStart+radTransWidth)*yRes ) {
        pf[indexCounter] = (r-(radTransStart*yRes))/(radTransWidth*yRes);
      } else {
        pf[indexCounter] = 1;
      }
      pa[indexCounter] = 0;
      P[indexCounter] = color(0, 0, 0);
      indexCounter++;
    }
  }
  
  for( int i = 0 ; i < numPixels ; i++ ) {
    float t0 = t;
    float t1 = t + dt;
    val0[i] = noise( ag*af*posX[i] , ag*af*posY[i] , t0 )*pf[i];
    val1[i] = noise( ag*af*posX[i] , ag*af*posY[i] , t1 )*pf[i];
  }
  startTime = millis();
  startSeconds = second();

  
}

void draw() {
  loadPixels();
  float transEnd = transStart + transWidth;
  float transEnd2 = transStart2 + transWidth2;
  for ( int i = 0; i < numPixels; i++ ) {
      int x = pixelX[i];
      int y = pixelY[i];
      
      float f = lerp( val0[i] , val1[i] , float(stepCounter)/float(numSteps) ) ;
      color c;
      if ( f > transStart && f < transEnd || f > transStart2 && f < transEnd2 ) {
        c = lerpColor( P[i], color(255, 255, 255), alpha );
        pa[i] = 0;
      } else {
        if ( pa[i] < 20 ) {
          c = lerpColor( P[i], color(0, 0, 0), alpha );
          pa[i]++;
        } else { 
          c = color( 0, 0, 0 );
        }
      }
      P[i] = c;
      pixels[ (width/2+x) + (height/2+y)*width ] = c;
      pixels[ (width/2+x) + (height/2-y)*width ] = c;
      pixels[ (width/2-x) + (height/2+y)*width ] = c;
      pixels[ (width/2-x) + (height/2-y)*width ] = c;
      if ( x < height/2 ) {
        pixels[ (width/2+y) + (height/2+x)*width ] = c;
        pixels[ (width/2+y) + (height/2-x)*width ] = c;
        pixels[ (width/2-y) + (height/2+x)*width ] = c;
        pixels[ (width/2-y) + (height/2-x)*width ] = c;
      }
  }
  updatePixels();
  for( int i = stepCounter*pixPerStep ; i <  (stepCounter+1)*pixPerStep && i < numPixels ; i++ ) {
    float t2 = t + dt;
    val2[i] = noise( ag*af*posX[i] , ag*af*posY[i] , t2 )*pf[i];
  }
  stepCounter++;
  if( stepCounter > numSteps ) { 
    stepCounter = 0; 
    t += dt;
    for( int i = 0 ; i < numPixels ; i++ ) {
      val0[i] = val1[i];
      val1[i] = val2[i];
    }
  }

  // clock stuff
  float secAng = TWO_PI * float(second())/60;
  float minAng = TWO_PI * (float(minute())+float(second())/60)/60;
  float hourAng = TWO_PI * (float(hour()%12)+float(minute())/60)/12;
  translate( 0.5*xRes, 0.5*yRes );
  stroke( 255, 255, 255, 255 );
  noFill();
  fill(0,0,0,128);
  float h = (frameCount*tc*tA + centerH + widthH*(-0.5+noise( 0.1*th*t ) ) )%1;
  color c = hsbColor( h*360, 0.5, 0.5) ;
  
  strokeWeight(yRes*0.004);
  float cr = 4;
  //fill( red(c), green(c), blue(c), 255 );
  
  pushMatrix();
  rotate( PI+minAng );
  rect( -0.5*minuteWidth*yRes, -backEnd*yRes, minuteWidth*yRes, minuteLength*yRes, cr, cr, cr, cr );
  popMatrix();
  h = (frameCount*tc*tA + centerH + widthH*(-0.5+noise( -0.1*th*t ) ) )%1;
  c = hsbColor( h*360, 0.5, 0.5) ;
  //fill( red(c), green(c), blue(c), 196 );
  pushMatrix();
  rotate( PI+hourAng );
  rect( -0.5*hourWidth*yRes, -backEnd*yRes, hourWidth*yRes, hourLength*yRes, cr, cr, cr, cr );
  popMatrix();
  //ellipse( 0 , 0 , 0.5*backEnd*yRes , 0.5*backEnd*yRes );
  noStroke();


  if ( frameCount%25 == 0 ) {
    println(frameRate);
  }
  
  if( mPressed ) {
    if( pressTime + pressTimeout < millis() ) {
      println( pressTime , pressTimeout , millis() );
      exit();
    }
  }
}

void mouseClicked() { 
  noiseSeed( millis() );
}

void mouseMoved() {
}
void mouseDragged() {
}

void mousePressed() {
  pressTime = millis();
  mPressed = true;
}

void mouseReleased() {
  mPressed = false;
}

color hsbColor( float h, float s, float b ) {
  float c = b*s;
  float x = c*( 1 - abs( (h/60) % 2 - 1 ) );
  float m = b - c;
  float rp = 0;
  float gp = 0;
  float bp = 0;
  if ( 0 <= h && h < 60 ) {
    rp = c;  
    gp = x;  
    bp = 0;
  }
  if ( 60 <= h && h < 120 ) {
    rp = x;  
    gp = c;  
    bp = 0;
  }
  if ( 120 <= h && h < 180 ) {
    rp = 0;  
    gp = c;  
    bp = x;
  }
  if ( 180 <= h && h < 240 ) {
    rp = 0;  
    gp = x;  
    bp = c;
  }
  if ( 240 <= h && h < 300 ) {
    rp = x;  
    gp = 0;  
    bp = c;
  }
  if ( 300 <= h && h < 360 ) {
    rp = c;  
    gp = 0;  
    bp = x;
  }
  return color( (rp+m)*255, (gp+m)*255, (bp+m)*255 );
}