/* TODO: Temperature Graph
*        Action Symbols and animations
*/

int textTop = 120;
int x = 30;

PFont geo20;
PFont geo28;
PFont geo30;
PFont geo32;
PFont geo36;

PImage load;
PImage loadOK;
PImage temp;
PImage tempOK;
PImage gui;
PImage guiStart;
PImage tempBar;

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

/* ---------------------------------------------------------------------------- */
void setupGUI() {
  smooth();
  
  geo20 = loadFont("Fonts/GeosansLight-20.vlw");
  geo28 = loadFont("Fonts/GeosansLight-28.vlw");
  geo30 = loadFont("Fonts/GeosansLight-30.vlw");
  geo32 = loadFont("Fonts/GeosansLight-32.vlw");
  geo36 = loadFont("Fonts/GeosansLight-36.vlw");
  textFont(geo32, 32);
  
  //Load interfaces
  guiStart = loadImage("Interface/Start Interface.png");
  gui = loadImage("Interface/Interface.png");
  
  //Load UI Elements
  load = loadImage("UI Elements/Load.png");
  loadOK = loadImage("UI Elements/Load OK.png");
  temp = loadImage("UI Elements/Temperature.png");
  tempOK = loadImage("UI Elements/Temperature OK.png");
  
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
}

/* ---------------------------------------------------------------------------- */
void drawGUI() {
  
  newGUI();
  drawTopBar();
  
  if (loadStatus == 1) {
    drawText();
    drawpgbars();
  } else {
    fill(225);
    textFont(geo32, 32);
    text("Load a process to begin development", 143, height/2);
  }

  if (temperatureStatus == 1)
    drawTemp();
    
}

/* ---------------------------------------------------------------------------- */
void drawpgbars() {
  float[] processStatus = currentProcess.getProcessStatus();
  
  textAlign(RIGHT);
  fill(225);
  textFont(geo20, 20);
  
  for (int i = 0; i < (processStatus.length-1); i++)
    drawBar(processStatus[i], i);
  
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
    else if  (phasePercent == 1)
      image(pgbgreen, 650, 120+50*position);
    else
      image(pgbar100, 650, 120+50*position);
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
  textFont(geo28, 28);
  text(nf(tempMin, 2, 1), 315, 468);
  text(nf(currentProcess.getTemperature(), 2, 1), 448, 468);
  text(nf(tempMax, 2, 1), 570, 468);
  
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
}

void newGUI() {
  if (loadStatus == 0)
    image(guiStart, 0, 0);
  else
    image(gui, 0, 0);
}

/* ---------------------------------------------------------------------------- */
void drawText() {
  String currentAction;
  String nextAction = " ";
  String timeLeft;
  
  //Generate timeLeft string
  if (currentPhase.getTime() <= 0)
    timeLeft = " ";
  else
    timeLeft = currentPhase.getTime() + " seconds";
    
  //Generate currentAction string
  if (currentPhase.getAction() == 'c')
    currentAction = "Invert \ncontinuously";
  else if (currentPhase.getAction() == 'i')
    currentAction = "Invert the\ntank once";
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
    nextAction = "Invert \ncontinuously";
  else if (currentPhase.getNext() == 'i')
    nextAction = "Invert the\ntank once";
  else if (currentPhase.getNext() == 's')
    nextAction = "Setting up";
  else if (currentPhase.getNext() == 'd')
    nextAction = "Drain the tank";
  else if (currentPhase.getNext() == 'w')
    nextAction = "Change water";
  else
    nextAction = "Wait";
  
  //Upper text
  fill(255);
  textFont(geo32);
  text(currentAction, x+20, textTop+100);
  
  //Lower text
  text(timeLeft, x+20, textTop + 250);
  
  fill(204);
  text(nextAction, x+350, textTop+100);
}
