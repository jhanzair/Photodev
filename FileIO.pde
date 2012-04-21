BufferedReader process;

void loadProcess() {
  //Obtain the process data
  String processPath = selectInput();
  process = createReader (processPath);
  if (parseProcess() != -1);
    loadStatus = 1;
}

/* ---------------------------------------------------------------------------- */
int parseProcess() {
  int positionStep = 0;
  int positionPhase = 0;
  String[] readBuffer = new String[2];
  String line;
  int lastPhase = 0;
  
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
