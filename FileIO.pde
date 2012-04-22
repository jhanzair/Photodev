/* TODO
*  Verificar se os códigos de step são válidos quando se está a ler o ficheiro logo
*/
class Process {
  int validProcess;
  BufferedReader process;
  //Process data
  float[][] tempData;
  int[][] timeData;  //[step][time in seconds, number of repetitions]
  char[] stepData;
  String[] phases;
  int nPhases;
  int nSteps;
  int phaseSteps[];
  int step;
  int phase;
  float[] processStatus;
  int[] processTimes;
  int state;

  Process() {
    tempData = new float[255][2];
    timeData = new int[1024][2];  //[time in seconds][number of repetitions]
    stepData = new char[1024];
    phases = new String[255];
    nPhases = 0;
    nSteps = 0;
    phaseSteps = new int[255];
    step = 0;
    phase = 0;
    state = 0;

    //Obtain the process data
    String processPath = selectInput();
    process = createReader (processPath);
    if (this.parseProcess() == -1)
      validProcess = -1;
    else
      validProcess = 1;
    
    processStatus = new float[nPhases+1];
    for (int i = 0; i <= nPhases; i++)
      processStatus[i] = 0;
      
    processTimes = new int[nPhases+1];
    int startPos = 0;
    for (int i = 0; i < nPhases; i++) {
      for (int j = startPos; j < startPos + phaseSteps[i]; j++)
        processTimes[i] += timeData[j][0]*timeData[j][1];
        
      startPos += phaseSteps[i];
      processTimes[nPhases] += processTimes[i];
    }
  }
  
  /* ---------------------------------------------------------------------------- */
  int parseProcess() {
    int positionStep = 0;
    int positionPhase = 0;
    String[] readBuffer = new String[2];
    String line;
    int lastPhase = 0;
    int phaseTotalTime;
    
    for (int i = 0; i < 255; i++)
      phaseSteps[i] = 0;
    
    try {
      line = process.readLine();
    } catch (IOException e) {
      e.printStackTrace();
      return -1;
    }
    
    while (line != null) {
      if (line.length() == 0) {}
      else if (line.charAt(0) != '#' && line.charAt(0) != '\n') {
         // If it's a line defining a new step
        if ((line.charAt(0) >= 'a' && line.charAt(0) <= 'z') || (line.charAt(0) >= 'A' && line.charAt(0) <= 'Z')) {
          
          phases[positionPhase] = line;
          
          // Read the temperatures for this step
          try {
            line = process.readLine();
          } catch (IOException e) {
            e.printStackTrace();
            return -1;
          }
          
          tempData[positionPhase] = float(split(line, TAB));
          if (positionPhase != 0) {
            phaseSteps[positionPhase-1] = positionStep;
          }
          positionPhase++;
          
          
        } else {
            readBuffer = split(line, ", ");
            timeData[positionStep][1] = int(readBuffer[1]);
            readBuffer = split(readBuffer[0], TAB);
            timeData[positionStep][0] = int(readBuffer[0]);
            stepData[positionStep] = readBuffer[1].charAt(0);
            positionStep++;
        }
      }
        
      
      try {
        line = process.readLine();
      } catch (IOException e) {
        e.printStackTrace();
        line = null;
      }
    }
    
    nPhases = positionPhase;
    nSteps = positionStep;
    
    phaseSteps[positionPhase-1] = positionStep;
    for (int i = nPhases-1; i > 0; i--)
      phaseSteps[i] = phaseSteps[i] - phaseSteps[i-1];
      
    
    
    return positionPhase;
  }
  
  /* ---------------------------------------------------------------------------- */
  char getStep() {
    return stepData[step];
  }
  
  String getPhase() {
    if (state == 0)
      return "Initial Setup";
    else
      return phases[phase];
  }
  
  String[] getPhaseList() {
    return phases;
  }
  
  float[] getProcessStatus() {
    int timeElapsed = 0;
    int stepsDone = step;
    
    for (int i = 0; i < nPhases; i++) {
      if (phase > i)
        processStatus[i] = 1.1;
      else if (phase == i)
        processStatus[i] = (processTimes[i]-getPhaseTimeRemaining())/processTimes[i];
      else
        processStatus[i] = 0;
    }

    processStatus[nPhases] = float(step)/float(nSteps);
    return processStatus;
  }
  
  
  float getPhaseTimeRemaining () {
    int stepsUntilPhase = 0;
    int phaseTimeRemaining = 0;
    
    for (int i = 0; i < phase; i++)
      stepsUntilPhase += phaseSteps[i];
    
    for (int i = stepsUntilPhase; i < stepsUntilPhase + phaseSteps[phase]; i++)
      if (step <= i)
        phaseTimeRemaining += timeData[i][0]*timeData[i][1];
    
    return float(phaseTimeRemaining);
  }
  
  int getStepTime() {
    return  timeData[step][0];
  }
  
  char getNextStep() {
    if (timeData[step][1] > 1 || state == 0)
      return stepData[step];
    else
      return stepData[step+1];
  }
  
  void goToNextStep() {
    if (timeData[step][1] > 1) {
        timeData[step][1]--;
      } else if (state == 0) {
          state = 1;
      } else {
          step++;
      }
  }
  
  // Steps onto the next phase. Returns -1 if the process has ended, 1 otherwise.
  int goToNextPhase() {
    phase++;
    if (phase >= nPhases)
      return -1;
    else
      return 1;
  }
  
  float getTemperature() {
    return tempData[phase][0];
  }
  
  float getTolerance() {
    return tempData[phase][1];
  }
}
