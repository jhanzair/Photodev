/**
 * OO conversion?
 */

Serial myPort;
int nSensors = -1;
float temperature;
float temperatures[];
long lastRead = 0;

void tempReaderSetup() 
{
  String tempPort = Serial.list()[0];
  myPort = new Serial(this, tempPort, 115200);
  long stopTrying;
  
  stopTrying = millis() + 1000;
  while (nSensors != 'c') {
    myPort.write('c');
    nSensors = myPort.read();
    if (millis() > stopTrying) {
      println ("Temperature sensor search timeout.");
      stopTrying = -1;
      break;
    }
  }
  if (stopTrying != -1) {
    while (myPort.available() == 0) {}
    nSensors = myPort.read();
    temperatures = new float[nSensors];
  } else
    nSensors = -1;
}

void updateTemps() {
  float tempBuffer = 0;
  
  if (nSensors == -1) 
    temperature = 25;
  else for (int i = 0; i < nSensors; i++) {
    temperatures[i] = readTemp();
    tempBuffer = tempBuffer + temperatures[i];
  }
  
  temperature = tempBuffer / (float) nSensors;
  
  if ((millis() - lastRead) > 1000)
    temperatureStatus = 2;
  else
    temperatureStatus = 1;
}

float readTemp() {
  int MSB = 0;
  int LSB = 0;
  int cfg = 0;
  int raw;
  int check = 0;
  float celsius;
  
  if (myPort.available() >= 5) {
    check = myPort.read();
    while (check != 0xFF) {
      check = myPort.read();
    }
    MSB = myPort.read();
    LSB = myPort.read();
    cfg = myPort.read();
    raw = (MSB << 8) | LSB;
    
   
    // default is 12 bit resolution, 750 ms conversion time
    celsius = (float) raw / 16.0;
    lastRead = millis();
    
    return celsius;
  } else return temperature;
}
