/**
 * PhotoDev 0.7
 * Photo development controller
 **/
 
 /*
 TODOS:
 Skip to next phase on button press
 ******Display next section when switching******
 */

import processing.serial.*;

Phase currentPhase;
Process currentProcess;
String processPath;

//State machine variables
int loadStatus = 0;  // No process loaded - 0, load OK - 1, last loaded process finished - 2
int temperatureStatus = 0; //0 - Off, 1 - On, 2 - Timed-out

void setup() {
  size(800, 600);
  background(0);
  
  //This sets the whole background to black in the fullscreen version
  frame.setBackground(new java.awt.Color(0, 0, 0));
  
  frameRate(5);
  
  //Initialize the GUI
  setupGUI();
  
  //Initialize the temperature sensors
  hardwareSetup();
  
  audioSetup();
}

void draw() {
  if (loadStatus == 1) {
    int time = currentPhase.getTime();
    
    if (time == 0) {
      currentPhase = currentPhase.end();
      if (currentPhase != null)
        currentPhase.load();
      else
        loadStatus = 0;
    }
  }
  drawGUI();
  updateHW();
  processAudio();
}

/* ---------------------------------------------------------------------------- */
void mouseReleased() {
  int pX = mouseX;
  int pY = mouseY;
  
  if (pX > 10 && pX < 50 && pY > 5 && pY < 55) {
    selectInput("Select a file to process:", "fileSelected");
    while (processPath == null) {
      delay(100);
    }
    println(processPath);
    currentProcess = new Process(processPath);
    loadStatus = 1;
    currentPhase = new Phase(currentProcess);
    drawGUI();
    delay(1000);
  }
  
  if (pX > 185 && pX < 235 && pY > 5 && pY < 55)
    hardwareSetup();
    
}

void keyPressed() {
  if (loadStatus == 1)
    currentPhase.onButton();
}

  /*
  Gets the selected file from the prompt and sets its path in
   */
  public void fileSelected(File selection) {
    if (selection == null) {
      println("Window was closed or the user hit cancel.");
    } 
    else {
      processPath = selection.getAbsolutePath();
    }
  }
