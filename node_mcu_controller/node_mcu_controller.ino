#include <WiFi.h>
#define BAUD 9600

// define ssid, password and set mode for esp32
#define SSID "AC-Board-01"  
#define PASSWORD "*hk6rzewj^" 
#define PORT 8080
#define MAX_CONNECTIONS 1

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
// create server at port = PORT
WiFiServer server(PORT);

void setup() {
  Serial.begin(BAUD);
  // set server as access point
  WiFi.mode(WIFI_AP);
  // create Access point with SSID and password
  WiFi.softAP(SSID, PASSWORD, 1, 0, MAX_CONNECTIONS);
  // start server
  server.begin();
  Serial.println("Server running at port " + String(PORT));
  Serial.println("SSID:\t" + String(SSID));
  Serial.println("Password:\t" + String(PASSWORD));

}

void loop() {
  // put your main code here, to run repeatedly:
  WiFiClient client = server.available();
  if(client && client.available()) {
    
    
  }
  client ? (void)client.stop() : (void)NULL;
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
