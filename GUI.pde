/* TODO: Action  animations
*        OO conversion?
*/
//Fonts
PFont geo20;
PFont geo24;
PFont geo30;
PFont geo32;
PFont geo36;
PFont geo64;
//UI elements
PImage load;
PImage loadOK;
PImage temp;
PImage tempOK;
PImage gui;
PImage guiStart;
PImage tempBar;
PImage continuous;
PImage invertOnce;
PImage drain;
PImage water;
PImage wait;
//Progress Bars
PImage pgbar0;
PImage pgbar10;
PImage pgbar20;
PImage pgbar30;
PImage pgbar40;
PImage pgbar50;
PImage pgbar60;
PImage pgbar70;
PImage pgbar80;
PImage pgbar90;
PImage pgbar100;
PImage pgbgreen;
//Temperature Graph data
float tempGraphDB[][]; //[][temperature, process temperature, tolerance]
long nextGraphUpdate;

/* ---------------------------------------------------------------------------- */
void setupGUI() {
  smooth();
  
  geo20 = loadFont("Fonts/GeosansLight-20.vlw");
  geo24 = loadFont("Fonts/GeosansLight-24.vlw");
  geo30 = loadFont("Fonts/GeosansLight-30.vlw");
  geo32 = loadFont("Fonts/GeosansLight-32.vlw");
  geo36 = loadFont("Fonts/GeosansLight-36.vlw");
  geo64 = loadFont("Fonts/GeosansLight-64.vlw");
  textFont(geo32, 32);
  
  //Load interfaces
  guiStart = loadImage("Interface/Start Interface.png");
  gui = loadImage("Interface/Interface.png");
  
  //Load UI Elements
  load = loadImage("UI Elements/Load.png");
  loadOK = loadImage("UI Elements/Load OK.png");
  temp = loadImage("UI Elements/Temperature.png");
  tempOK = loadImage("UI Elements/Temperature OK.png");
  continuous = loadImage("UI Elements/continuous.png");
  invertOnce = loadImage("UI Elements/invert once.png");
  drain = loadImage("UI Elements/drain.png");
  water = loadImage("UI Elements/water.png");
  wait = loadImage("UI Elements/wait.png");
  
  //Load temperature interface
  tempBar = loadImage("UI Elements/Temperature Bar.png");
  
  //Load progress bars
  pgbar0 = loadImage("UI Elements/Progress Bars/pb0.png");
  pgbar10 = loadImage("UI Elements/Progress Bars/pb10.png");
  pgbar20 = loadImage("UI Elements/Progress Bars/pb20.png");
  pgbar30 = loadImage("UI Elements/Progress Bars/pb30.png");
  pgbar40 = loadImage("UI Elements/Progress Bars/pb40.png");
  pgbar50 = loadImage("UI Elements/Progress Bars/pb50.png");
  pgbar60 = loadImage("UI Elements/Progress Bars/pb60.png");
  pgbar70 = loadImage("UI Elements/Progress Bars/pb70.png");
  pgbar80 = loadImage("UI Elements/Progress Bars/pb80.png");
  pgbar90 = loadImage("UI Elements/Progress Bars/pb90.png");
  pgbar100 = loadImage("UI Elements/Progress Bars/pb100.png");
  pgbgreen = loadImage("UI Elements/Progress Bars/pbgreen.png");
  
  //Initialize the temperature graph database
  tempGraphDB = new float[190][3];
  for (int i = 0; i < 190; i++) {
    tempGraphDB[i][0] = 0;
    tempGraphDB[i][1] = 0;
    tempGraphDB[i][2] = 0;
  }
    
}

/* ---------------------------------------------------------------------------- */
void drawGUI() {
  newGUI();
  drawTopBar();
  
  if (loadStatus == 1) {
    drawActions();
    drawpgbars();
    drawTempGraph();
  } else {
    fill(225);
    textFont(geo32, 32);
    text("Load a process to begin development", 143, height/2);
  }

  if (temperatureStatus == 1) {
    drawTemp();
  }
}

/* ---------------------------------------------------------------------------- */
void drawpgbars() {
  float[] processStatus = currentProcess.getProcessStatus();
  String[] phaseList = currentProcess.getPhaseList();
  
  textAlign(RIGHT);
  fill(225);
  textFont(geo20, 20);
  
  for (int i = 0; i < (processStatus.length-1); i++) {
    text(phaseList[i], 780, 177+50*i); 
    drawBar(processStatus[i], i);
  }
  
  text("Total", 780, 177-60);  
  drawBar(processStatus[processStatus.length-1], -1.2);
  textAlign(LEFT);
}

/* ---------------------------------------------------------------------------- */
void drawBar(float phasePercent, float position) {
  if (phasePercent < 0.1)
      image(pgbar0, 650, 120+50*position);
    else if  (phasePercent < 0.2)
      image(pgbar10, 650, 120+50*position);
    else if  (phasePercent < 0.3)
      image(pgbar20, 650, 120+50*position);
    else if  (phasePercent < 0.4)
      image(pgbar30, 650, 120+50*position);
    else if  (phasePercent < 0.5)
      image(pgbar40, 650, 120+50*position);
    else if  (phasePercent < 0.6)
      image(pgbar50, 650, 120+50*position);
    else if  (phasePercent < 0.7)
      image(pgbar60, 650, 120+50*position);
    else if  (phasePercent < 0.8)
      image(pgbar70, 650, 120+50*position);
    else if  (phasePercent < 0.9)
      image(pgbar80, 650, 120+50*position);
    else if  (phasePercent < 1)
      image(pgbar90, 650, 120+50*position);
    else if  (phasePercent == 1.0)
      image(pgbar100, 650, 120+50*position);
    else
      image(pgbgreen, 650, 120+50*position);
}

/* ---------------------------------------------------------------------------- */
void drawTemp() {
  int tempBarPosition = 345;
  int tempBarSize = 250;
  float ratio = 0;
  int positionTriangle;
  
  if (currentProcess == null)
    return;
    
  float tempMin = currentProcess.getTemperature() - currentProcess.getTolerance();
  float tempMax = currentProcess.getTemperature() + currentProcess.getTolerance();
  
  if (temperature > tempMax)
    ratio = 1;
  else if (temperature < tempMin)
    ratio = 0;
  else
    ratio = (temperature - tempMin) / (currentProcess.getTolerance()*2);
  
  positionTriangle = tempBarPosition + int(ratio * tempBarSize);
  
  image(tempBar, 345, 480);
  
  fill(225);
  textFont(geo30, 30);
  text(nf(temperature, 2, 1) + " ºC", positionTriangle-50, 590);
  textFont(geo24, 24);
  text(nf(tempMin, 2, 1), 325, 468);
  text(nf(currentProcess.getTemperature(), 2, 1), 448, 468);
  text(nf(tempMax, 2, 1), 575, 468);
  
  noStroke();
  triangle(positionTriangle, 530, positionTriangle-11, 552, positionTriangle+11, 552);
}

/* ---------------------------------------------------------------------------- */
void drawTopBar() {
  if (loadStatus == 0)
    image(load, 10, 5);
  else
    image(loadOK, 10, 5);
  
  if (temperatureStatus == 1)
    image (tempOK, 185, 5);
  else
    image (temp, 185, 5);
  
  textFont(geo36);
  text("Photodev Beta", 570, 40);
}

void newGUI() {
  if (loadStatus == 0)
    image(guiStart, 0, 0);
  else
    image(gui, 0, 0);
}

/* ---------------------------------------------------------------------------- */
void drawActions() {
  String currentAction;
  String nextAction = " ";
  String timeLeft;
  
  //Generate timeLeft string
  if (currentPhase.getTime() <= 0)
    timeLeft = " ";
  else
    timeLeft = currentPhase.getTime() + " s";
    
  //Generate currentAction string
  if (currentPhase.getAction() == 'c')
    currentAction = "Invert continuously";
  else if (currentPhase.getAction() == 'i')
    currentAction = "Invert once";
  else if (currentPhase.getAction() == 's')
    currentAction = "Setting up";
  else if (currentPhase.getAction() == 'd')
    currentAction = "Drain the tank";
  else if (currentPhase.getAction() == 'w')
    currentAction = "Change water";
  else
    currentAction = "Wait";
    
  //Generate nextAction string
  if (currentPhase.getNext() == 'c')
    nextAction = "Invert continuously";
  else if (currentPhase.getNext() == 'i')
    nextAction = "Invert once";
  else if (currentPhase.getNext() == 's')
    nextAction = "Setting up";
  else if (currentPhase.getNext() == 'd')
    nextAction = "Drain the tank";
  else if (currentPhase.getNext() == 'w')
    nextAction = "Change water";
  else
    nextAction = "Wait";

  //Draw the actual text
  fill(255);
  textFont(geo24);
  textAlign(CENTER);
  text(currentAction, 168, 360);
  text(nextAction, 506, 360);
  textFont(geo64);
  text(timeLeft, 350, 327);
  textAlign(LEFT);
  
  //Draw the symbols
  imageMode(CENTER);
  drawSymbol(currentPhase.getAction(), 168, 231);
  drawSymbol(currentPhase.getNext(), 503, 255);
  imageMode(CORNER);
}

void drawSymbol(char symbol, int x, int y) {
  switch(symbol) {
    case 'c':
      image(continuous, x, y);
      break;
    case 'i':
      image(invertOnce, x, y);
      break;
    case 'd':
      image(drain, x, y);
      break;
    case 'w':
      image(water, x, y);
      break;
    case  ' ':
      image(wait, x, y);
      break;
  }
}

void drawTempGraph() {
    
  //dimensions: 200/65, 30-230 / 470-535
  int ty, tynext, maxy, maxynext, miny, minynext;
  
  //Update the database
  if (millis() > nextGraphUpdate) {
    nextGraphUpdate = millis() + 1000;
    for (int i = 0; i < 189; i++) {
      tempGraphDB[i][0] = tempGraphDB[i+1][0];
      tempGraphDB[i][1] = tempGraphDB[i+1][1];
      tempGraphDB[i][2] = tempGraphDB[i+1][2];
    }
    tempGraphDB[189][0] = temperature;
    tempGraphDB[189][1] = currentProcess.getTemperature();
    tempGraphDB[189][2] = currentProcess.getTolerance();
  }
  
  //Draw the graph
  stroke(225);
  line(30, 535, 230, 535);
  line(30, 535, 30, 470);
  for (int i = 0; i < 189; i++) {
    if (tempGraphDB[i][0] >= 15) {
      ty = round(map(tempGraphDB[i][0], 15, 50, 0, 65));
      maxy = round(map(tempGraphDB[i][1]+tempGraphDB[i][2], 15, 50, 0, 65));
      miny = round(map(tempGraphDB[i][1]-tempGraphDB[i][2], 15, 50, 0, 65));
      tynext = round(map(tempGraphDB[i+1][0], 15, 50, 0, 65));
      maxynext = round(map(tempGraphDB[i+1][1]+tempGraphDB[i+1][2], 15, 50, 0, 65));
      minynext = round(map(tempGraphDB[i+1][1]-tempGraphDB[i+1][2], 15, 50, 0, 65));
      stroke(225);
      //the whole maxy miny ty whatever mess is just so I can use line() instead of point() here
      //this way, when there are jumps in temperature there aren't any discontinuities in the graph
      line(i+30, 535-ty, i+31, 535-tynext);
      stroke(color(#FF33AA));
      line(i+30, 535-maxy, i+31, 535-maxynext);
      line(i+30, 535-miny, i+31, 535-minynext);
    }
  }
  noStroke();
  
}
