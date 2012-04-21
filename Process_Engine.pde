/* TODO:
*    Add Load Tank action
*/

/* ---------------------------------------------------------------------------- */
class Phase {
  int time;
  char nextStep;
  char action;
  char next;
  Process process;
  
  Phase(int time, char next, Process process) {
    this.time = time;
    this.nextStep = next;
    this.action = ' ';
    this.next = ' ';
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
    return;
  }
  
  int getTime() {
    return -1;
  }
  
  Phase end() {
    process.goToNextStep();
    
    switch(process.getStep()) {
      case 'c':
        return new Continuous (process.getTime(), process.getNextStep(), process);
      case 'i':
        return new InvertOnce (process.getTime(), process.getNextStep(), process);
      case 'd':
        return new Drain (process.getTime(), process.getNextStep(), process);
      case 'w':
        return new WaterChange (process.getTime(), process.getNextStep(), process);
      default:
        return null;
    }
  }
  
  Phase end(char current) {
    process.goToNextStep();
    
    switch(process.getStep()) {
      case 'c':
        return new Continuous(process.getTime(), process.getNextStep(), process);
      case 'i':
        return new InvertOnce(process.getTime(), process.getNextStep(), current, process);
      case 'd':
        return new Drain (process.getTime(), process.getNextStep(), current, process);
      case 'w':
        return new WaterChange (process.getTime(), process.getNextStep(), process);
      default:
        return null;
    }
  }
  
  void onButton() {
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
  
  Continuous(int time, char next) {
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
  
  InvertOnce(int time, char next) {
    super(time, next, process);
  }
  
  InvertOnce(int time, char next, char current, Process process) {
    super(time, next, current, process);
  }
  
  
  void load() {
    action = ' ';
    next = 'i';
    
    endTime = millis() + time*1000;
  }
  
  int getTime() {
    int timeLeft = 0;
    
    timeLeft = int(endTime-millis())/1000;
    if (timeLeft < 0) timeLeft = 0;
    
    return timeLeft;
  }
  
  Phase end() {
    super.end('i');
  }
  
  void onButton() {
    action = ' ';
  }
  
}

/* ---------------------------------------------------------------------------- */
class Drain extends Phase {
  long endTime;
  
  Drain(int time, char next) {
    super(time, next, process);
  }
  
  Drain(int time, char next, char current, Process process) {
    super(time, next, current, process);
  }
  
  void load() {
    action = ' ';
    next = 'd';
    
    endTime = millis() + time*1000;
  }
  
  int getTime() {
    
    if (alarm == 'd')
      return -1;
    else {
      int timeLeft = 0;
      
      timeLeft = int(endTime-millis())/1000;
      if (timeLeft < 0) timeLeft = 0;
      
      return timeLeft;
    }
  }
  
  Phase end() {
    action = 'd';
    next = nextStep;
  }
  
  void onButton() {
    if (action == 'd')
      super.end();
  }
  
}

/* ---------------------------------------------------------------------------- */
class WaterChange extends Phase {
  long endTime;
  
  WaterChange(int time, char next) {
    super(time, next, process);
  }
  
  void load() {
    action = 'w';
    next = nextStep;
    
    endTime = millis() + time*1000;
  }
  
  void onButton() {
      super.end();
  }
  
}
