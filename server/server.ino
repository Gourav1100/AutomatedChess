#include <WiFi.h>
#include <WebSocketsServer.h>
#include <cstring>

#define n 3
#define m 3
int PieceCount = 0;
int state[n][m];
int k[][m] = {{4, 5, 12}, {13, 14, 15}, {18, 19, 21}};

const char* ssid = "auto_chess";
const char* password = "12345678";
IPAddress IP;
WebSocketsServer webSocket = WebSocketsServer(81);

void onWebSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
  switch(type) {
    case WStype_DISCONNECTED:
      Serial.printf("[%u] Disconnected!\n", num);
      break;

    case WStype_CONNECTED:
      {
        IPAddress ip = webSocket.remoteIP(num);
        Serial.printf("[%u] Connection from %s\n", num, ip.toString().c_str());
      }
      break;

    case WStype_TEXT:
      Serial.printf("[%u] Text: %s\n", num, payload);
      webSocket.sendTXT(num, "Message Sent from client.");
      break;

    default:
      break;
  }
}

void setup() {
  Serial.begin(115200);
  Serial.print("Setting AP - ");
  WiFi.mode(WIFI_AP);
  WiFi.softAP(ssid, password);
  Serial.println("done.");
  IP = WiFi.softAPIP();
  Serial.print("Host IP Address - ");
  Serial.println(IP);
  // start socket server
  webSocket.begin();
  webSocket.onEvent(onWebSocketEvent);
  // initialize state
  for(int i = 0; i < n; i++) {
    for(int j = 0; j < m; j++) {
      pinMode(k[i][j], OUTPUT);
      digitalWrite(k[i][j], HIGH);
      state[i][j] = digitalRead(k[i][j]);;
      PieceCount += !state[i][j];
    }
  } 
}

void loop() {
  webSocket.loop();
  int tempState[n][m];
  bool isUpdated = false;
  int currentCount = 0;
  for(int i = 0; i < n; i++) {
    for(int j = 0; j < m; j++) {
      tempState[i][j] = digitalRead(k[i][j]);
      if(tempState[i][j] != state[i][j]) {
        isUpdated = true;
      }
      currentCount += !tempState[i][j];
    }
  }
  if(isUpdated && currentCount == PieceCount) {
    Serial.print("Host IP Address (PORT 81) - ");
    Serial.println(IP);
    String updatedState = "";
    Serial.println("State Updated to ---------");
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < m; j++) {
        state[i][j] = tempState[i][j];
        Serial.print(state[i][j]);
        updatedState += state[i][j] == HIGH ? "1 ": "0 ";
      }
      Serial.println("");
    }
    Serial.println("--------------------------");
    Serial.println("Brodcasting state to all devices: ");
    Serial.println(updatedState);
    webSocket.broadcastTXT(updatedState);
  }
}