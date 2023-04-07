#include <WiFi.h>
#define BAUD 115200
const char* SSID = "auto_chess";
const char* PASS = "12345678";
bool isNetworkConnected = false;

// define protocol for data exchange between server and client
class Protocol {
  public:
    String instruction;
    int x1, y1;
    int x2, y2;
    Protocol() {
      instruction = "";
      x1 = y1 = x2 = y2 = -1;
    }
    String generateInstruction() {
      String Instruction = (instruction == "" ? "NUL" : instruction) + ";" + String(x1) + ";" + String(y1) + ";" + String(x2) + ";" + String(y2) + ";";
      return Instruction;      
    }
};

void setup() {
  Serial.begin(BAUD);
  // set server in station mode
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  delay(100);

}

void loop() {
  if(!isNetworkConnected) {
    Serial.println("scan start");
    // WiFi.scanNetworks will return the number of networks found
    int n = WiFi.scanNetworks();
    Serial.println("scan done");
    if (n == 0) {
        Serial.println("no networks found");
    } else {
      for (int i = 0; i < n && !isNetworkConnected; ++i) {
        // Print SSID and RSSI for each network found
        if(WiFi.SSID(i) == SSID) {
          Serial.print("Network Found! Trying to connect...");
          WiFi.begin(SSID, PASS);
          if(WiFi.status() != WL_CONNECTED) {
            Serial.println("Connected.");
            isNetworkConnected = true;
          } else {
            Serial.println("");
          }
        }
        delay(10);
      }
    }

    // Wait a bit before scanning again
    delay(5000);
  } else {
    Serial.println("Waiting for further instructions");
  }
}

/* define instructions and return response as per the instruction
    instruction set:
    1. mov;x1;y1;x2;y2;
        move motor to x1, y1 and pick the piece and leave it onto x2, y2 and change state
    2. get;?x1;?y1;
        get status for all x1, y1 (default) else get status for particular location.
    3. srt;
        start and set player bit as 1 indicating that this player starts.
    client side instruction set
    1. set;x1;y1;x2;y2;
      piece moved from x1, y1 to x2, y2 valid and respond.
    2. upd;x1;y1;x2;y2;
      update moves on device.
  mechanism server side
    wait for any new move to occur.
    broadcast to connected device and set move inside application;
    check for response by application.
    initialize wait bit with 1 and player bit with 0;
    success[1];  - successfully performed move. set wait bit to 1 (handle valid changes / give control to application), change player bit to 0.
    failed[0];   - operation was invalid or unsuccessful. wait for mov instruction. set wait bit 1 (Exception handle). Do not change player bit.
    algorithm:
    loop while player bit = 0 or wait bit = 1
      wait for instruction from application
    endloop
    loop while player = 1 and wait = 0
      wait for any piece to move and brodcast the information
    endloop

  use service bit to disable other instructions.
    0 : allow all instructions.
    1 : allow only move instruction.
  use read bit to enable and disable state checking for pieces.

  refrences for wifi.h and esp32
  https://techtutorialsx.com/2017/11/13/esp32-arduino-setting-a-socket-server/
  https://www.instructables.com/ESP32-Remote-Control-With-Sockets/
  https://randomnerdtutorials.com/esp32-useful-wi-fi-functions-arduino/
  https://techtutorialsx.com/2018/05/25/esp32-socket-server-controlling-a-relay-remotely/
  https://www.instructables.com/Steps-to-Setup-Arduino-IDE-for-NODEMCU-ESP8266-WiF/
  https://circuits4you.com/2018/11/26/esp8266-nodemcu-tcp-socket-server-arduino-example/
*/