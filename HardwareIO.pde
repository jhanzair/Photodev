/**
 * OO conversion?
 */

Serial myPort;
int nSensors = -1;
float temperature;
float temperatures[];
long lastRead = 0;

void hardwareSetup() 
{
  String tempPort = Serial.list()[2];
  myPort = new Serial(this, tempPort, 9600);
  /*long stopTrying;
   
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
   while (myPort.available () == 0) {
   }
   nSensors = myPort.read();
   temperatures = new float[nSensors];
   } 
   else
   nSensors = -1;
   */
}

void updateHW() {
  int MSB1 = 0;
  int LSB1 = 0;
  int MSB2 = 0;
  int LSB2 = 0;
  int foot = 0;
  char t, f, e;
  int raw1 = 0, raw2 = 0;
  float celsius1, celsius2;
  int pressed = 0;

  if (myPort.available() >= 8) {
    t = (char) myPort.read();
    if (t != 't') {
      //Invalid data, cancel update
      return;
    }
    LSB1 = myPort.read();
    MSB1 = myPort.read();
    LSB2 = myPort.read();
    MSB2 = myPort.read();
    f = (char) myPort.read();
    if (f != 'f') {
      //Invalid data, cancel update
      return;
    }
    foot = myPort.read();
    e = (char) myPort.read();
    if (e != 'e') {
      //Invalid data, cancel update
      return;
    }
    
    raw1 = (MSB1 << 8) | LSB1;
    raw2 = (MSB2 << 8) | LSB2;
    celsius1 = (float) raw1 / 16.0;
    celsius2 = (float) raw2 / 16.0;
    temperature = celsius1 + celsius2;
    temperature /= 2;
      
    if (foot == 1 && currentPhase != null) {
      currentPhase.pressed++;
    }

    lastRead = millis();
  }
  
  if ((millis() - lastRead) > 1000)
    temperatureStatus = 2;
  else
    temperatureStatus = 1;
}
