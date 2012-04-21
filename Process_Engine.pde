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
  
  void exec() {
    return;
  }
  
  Phase end() {
    process.goToNextStep();
    
    switch(process.getStep()) {
      case 'c':
        return new Continuous(process.getTime(), process.getNextStep(), process);
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
  
  Continuous(int time, char next, char current, Process process) {
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
