#define filterSize 3
unsigned long prevMillis = 0;

float target;
float currentValue;
char previousValue;

void setup() {
  //  Set MIDI baud rate:
  Serial.begin(31250);
  //Serial.begin(9600);
  pinMode(2, INPUT);
  attachInterrupt(0, revolution, RISING);
}

void loop() {
  unsigned long diff = millis() - prevMillis;

  currentValue = smooth(target, 0.9, currentValue);
  if((char)currentValue != previousValue){
    midiCC(5, currentValue);
  }

  // Timeout
  if(diff > 2000){
    target = 0;
  }

  previousValue = currentValue;
  delay(50);
}

void revolution(){
  unsigned long currMillis = millis();
  //Crude debounce
  if(prevMillis != currMillis){
    float diff = currMillis - prevMillis;
    target = (1.0 / diff) * 50000;
    prevMillis = currMillis;
  }
}

// This function sends a Midi CC.
void midiCC(char c_num, char c_val){
  Serial.print(0xB0, BYTE);
  Serial.print(c_num, BYTE);
  Serial.print(c_val, BYTE);
}

float smooth(float data, float filterVal, float smoothedVal){
  if (filterVal > 1){      // check to make sure param's are within range
    filterVal = .99;
  }
  else if (filterVal <= 0){
    filterVal = 0;
  }
  smoothedVal = (data * (1 - filterVal)) + (smoothedVal  *  filterVal);
  return smoothedVal;
}


