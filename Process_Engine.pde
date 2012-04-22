/* TODO:
*    Add Load Tank phase
*/

/* ---------------------------------------------------------------------------- */
class Phase {
  int time;
  char nextStep;
  char action;
  char next;
  int pressed;
  Process process;
  
  Phase(Process process) {
    this.time = 0;
    this.nextStep = process.getNextStep();
    this.action = 's';
    this.next = nextStep;
    this.pressed = 0;
    this.process = process;
  }
  
  Phase(int time, char next, Process process) {
    this.time = time;
    this.nextStep = next;
    this.action = ' ';
    this.next = ' ';
    this.pressed = 0;
    this.process = process;
  }
  
  Phase(int time, char next, char current, Process process) {
    this.time = time;
    this.nextStep = next;
    this.action = current;
    this.next = ' ';
    this.process = process;
  }
  
  void load() {
    action = 's';
    next = process.getNextStep();
    return;
  }
  
  int getTime() {
    if (pressed > 0)
      return 0;
    else
      return -1;
  }
  
  Phase end() {
    process.goToNextStep();
    switch(process.getStep()) {
      case 'c':
        return new Continuous (process.getStepTime(), process.getNextStep(), process);
      case 'i':
        return new InvertOnce (process.getStepTime(), process.getNextStep(), process);
      case 'd':
        return new Drain (process.getStepTime(), process.getNextStep(), process);
      case 'w':
        return new WaterChange (process.getStepTime(), process.getNextStep(), process);
      default:
        return null;
    }
  }
  
  Phase end(char current) {
    process.goToNextStep();
    
    switch(process.getStep()) {
      case 'c':
        return new Continuous(process.getStepTime(), process.getNextStep(), process);
      case 'i':
        return new InvertOnce(process.getStepTime(), process.getNextStep(), current, process);
      case 'd':
        return new Drain (process.getStepTime(), process.getNextStep(), current, process);
      case 'w':
        return new WaterChange (process.getStepTime(), process.getNextStep(), process);
      default:
        return null;
    }
  }
  
  void onButton() {
    pressed++;
    return;
  }
  
  char getAction() {
    return action;
  }
  
  char getNext() {
    return next;
  }
}

/* ---------------------------------------------------------------------------- */
class Continuous extends Phase {
  long endTime;
  
  Continuous(int time, char next, Process process) {
    super(time, next, process);
  }
  
  void load() {
    action = 'c';
    if (nextStep == 'c' && nextStep == 'w' )
      next = nextStep;
    else
      next = ' ';
      
    endTime = millis() + time*1000;
  }
  
  int getTime() {
    int timeLeft = 0;
    
    timeLeft = int(endTime-millis())/1000;
    if (timeLeft < 0) timeLeft = 0;
    
    return timeLeft;
  }
}

/* ---------------------------------------------------------------------------- */
class InvertOnce extends Phase {
  long endTime;
  
  InvertOnce(int time, char next, Process process) {
    super(time, next, process);
  }
  
  InvertOnce(int time, char next, char current, Process process) {
    super(time, next, current, process);
  }
  
  
  void load() {
    if (action == 'i') {
      action = 'i';
      next = ' ';
    } else {
      action = ' ';
      next = 'i';
    }
    endTime = millis() + time*1000;
  }
  
  int getTime() {
    int timeLeft = 0;
    
    timeLeft = int(endTime-millis())/1000;
    if (timeLeft < 0) timeLeft = 0;
    
    return timeLeft;
  }
  
  Phase end() {
    beep();
    return super.end('i');
  }
  
  void onButton() {
    action = ' ';
    next = 'i';
  }
  
}

/* ---------------------------------------------------------------------------- */
class Drain extends Phase {
  long endTime;
  int timeLeft;
  
  Drain(int time, char next, Process process) {
    super(time, next, process);
  }
  
  Drain(int time, char next, char current, Process process) {
    super(time, next, current, process);
  }
  
  void load() {
    next = 'd';
    
    endTime = millis() + time*1000;
  }
  
  int getTime() {
    if (timeLeft != -1) {
      timeLeft = int(endTime-millis())/1000;
      if (timeLeft < 0) timeLeft = 0;
    }
    
    if (timeLeft == 0 && action != 'd') {
      timeLeft = -1;
      action = 'd';
      next = nextStep;
      beep();
    }

    return timeLeft;
  }
  
  void onButton() {
    if (action == 'i')
      action = ' ';
    if (timeLeft == -1)
      timeLeft = 0;
  }
  
  Phase end() {
    if (process.goToNextPhase() == 1)
      return super.end();
    else
      return null;
  }
}

/* ---------------------------------------------------------------------------- */
class WaterChange extends Phase {
  int state;
  
  WaterChange(int time, char next, Process process) {
    super(time, next, process);
  }
  
  void load() {
    action = 'w';
    next = nextStep;
    state = -1;
  }
  
  void onButton() {
      state = 0;
  }
  
  int getTime() {
    return state;
  }
  
}
