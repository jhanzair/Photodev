/*  TODO
*
*  Add decent sounds - this sine wave thingy is annoying.
*/

import ddf.minim.*;
import ddf.minim.signals.*;

Minim minim;
AudioOutput out;
SineWave sine;
int audioTiming[];

void audioSetup() {
  minim = new Minim(this);
  // get a line out from Minim, default bufferSize is 1024, default sample rate is 44100, bit depth is 16
  out = minim.getLineOut(Minim.STEREO);
  // create a sine wave Oscillator, set to 440 Hz, at 0.5 amplitude, sample rate from line out
  sine = new SineWave(440, 0.5, out.sampleRate());
  // set the portamento speed on the oscillator to 200 milliseconds
  //sine.portamento(200);
  // add the oscillator to the line out
  out.addSignal(sine);
  out.mute();
  sine.setFreq(3000);
  audioTiming = new int[7];
}

void beep() {
  out.unmute();
  audioTiming[0] = millis()+150;
  audioTiming[1] = millis()+300;
  audioTiming[2] = millis()+450;
  audioTiming[3] = millis()+1000;
  audioTiming[4] = millis()+1150;
  audioTiming[5] = millis()+1300;
  audioTiming[6] = millis()+1450; 
}

void processAudio() {
  for (int i = 0; i < 7; i++)
    if (audioTiming[i] != 0 && millis() > audioTiming[i]) {
      audioTiming[i] = 0;
      if ( out.isMuted() )
        out.unmute();
      else
        out.mute();
    }
}

void stop() {
  out.close();
  minim.stop();
  super.stop();
}
