/**
 * PhotoDev 0.2
 * Photo development controller 
 * by João Sousa. 
 * 
 * 

TODO:
    !!Fazer som quando disparam alarmes!!

Verificar se os códigos de step são válidos quando se está a ler o ficheiro logo
*/

import processing.serial.*;

//Process data
float[][] tempData = new float[255][2];
int[][] timeData = new int[1024][2];  //[time in seconds][number of repetitions]
char[] stepData = new char[1024];
String[] phases = new String[255];
int nPhases = 0;
int nSteps = 0;
int phaseSteps[] = new int[255];

//State machine variables
int loadStatus = 0;  // No process loaded - 0, load OK - 1, last loaded process finished - 2
boolean[] alarms = new boolean[20];
long stepEnd;
int step = 0;
int phase = -1;
int operation = -1; // 0 - waiting, 1 - changing phases, -1 - stopped
int go = 0;
int temperatureStatus = 0; //0 - Off, 1 - On, 2 - Timed-out
float temperature = 20;
float tolerance = 2;
float phaseTemp = 20;

void setup() {
  size(800, 600);
  background(0);
  
  //This sets the whole background to black in the fullscreen version
  frame.setBackground(new java.awt.Color(0, 0, 0));
  
  frameRate(4);
  
  //Initialize the alarms
  setAlarm('s');
  
  //Initialize the GUI
  setupGUI();
  
  //Initialize the temperature sensors
  tempReaderSetup();
}

void draw() {
  updateTemps();
    
  switch (operation) {
    case -1:
      if (go == 1 && loadStatus == 1) {
        //The only operation that can stop a phase mid-way is water changes
        if (!checkAlarm('w')){
          phase++;
          if (phases[phase] == null) {
            loadStatus = 2;
            break;
          }
        }
        else
          clearAlarm ('w');
          
        //Load the correct temperatures, tolerances and time for this phase
        phaseTemp = tempData[phase][0];
        tolerance = tempData[phase][1];
        stepEnd = millis() + timeData[step][0]*1000;
        
        //Got to operation 0
        operation = 0;
        go = 0;
      }
      else
        break;
    case 0:
      if (millis() > stepEnd) {
        clearAllAlarms();
        setAlarm(stepData[step]);
        operation = 1;
      } else
        //Keep setting the continuous agitation alarm, even if a button was pressed
        if (stepData[step] == 'c')
          setAlarm('c');
      break;
    case 1:
      if (timeData[step][1] > 1) {
        timeData[step][1]--;
        stepEnd = millis() + timeData[step][0]*1000;
        operation = 0;
      } else {
        step++;
          
        if (checkAlarm('d') || checkAlarm('w')){
          clearAlarm('c');
          operation = -1;
        }
        else {
          if (checkAlarm('c'))
            clearAllAlarms();
          
          if (timeData[step][0] == 0)
            setAlarm(stepData[step]);
            
          stepEnd = millis() + timeData[step][0]*1000;
          operation = 0;
        }
      }
     break;
  }
  
  drawGUI();
}

void keyPressed() {
  clearAlarm('i');
  clearAlarm('d');
  if (operation == -1)
    go = 1;
  draw();
}

//Sets an alarm
void setAlarm(char type) {
  int position = alarmTypeToPosition(type);
  
  alarms[position] = true;
}

//Clears an alarm
void clearAlarm(char type) {
  int position = alarmTypeToPosition(type);
  
  alarms[position] = false;
}

//Clears all alarms
void clearAllAlarms() {
  for (int i = 0; i<20; i++)
    alarms[i] = false;
}

//Checks if an alarm is set
boolean checkAlarm (char type) {
  int position = alarmTypeToPosition(type);
  if (alarms[position])
    return true;
  else
    return false;
}

//Checks if any alarm is set
boolean checkAlarm () {
  for (int i = 0; i<20; i++)
    if (alarms[i] == true)
      return true;
      
  return false;
}

//Converts an alarm type (for example, 'c') to a position in the alarms array
int alarmTypeToPosition (char type) {
  
  switch(type) {
    case 'c':
      return 1;
    case 'i':
      return 2;
    case 'd':
      return 3;
    case 'w':
      return 4;
    case 's':
      return 5;
    default:
      return -1;
  }
}

/* ---------------------------------------------------------------------------- */
int loadNextStep() {
   if (timeData[step][1] > 1) {
        timeData[step][1]--;
        stepEnd = millis() + timeData[step][0]*1000;
        operation = 0;
      } else {
        step++;
          
        if (checkAlarm('d') || checkAlarm('w')){
          clearAlarm('c');
          operation = -1;
        }
        else {
          if (checkAlarm('c'))
            clearAllAlarms();
          
          if (timeData[step][0] == 0)
            setAlarm(stepData[step]);
            
          stepEnd = millis() + timeData[step][0]*1000;
          operation = 0;
        }
      } 
      
      return 1;
}
