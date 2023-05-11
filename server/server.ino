#include <WiFi.h>
#include <WebSocketsServer.h>
#include <cstring>
// Initialize data and assign Pins
#define n 8
#define S0 12
#define S1 14
#define S2 27
#define S3 26
#define OUTPUT 2
#define OUTPUTSTATE LOW
#define E0 5
#define E1 18
#define E2 19
#define E3 21
int PieceCount = 0;                                                         // Current Count of number of pieces on the board
int selectionPinList[][2] = {{S0, LOW}, {S1, LOW}, {S2, LOW}, {S3, LOW}};   // LOW and HIGH are used for encoding
int enablePinList[][2] = {{E0, HIGH}, {E1, HIGH}, {E2, HIGH}, {E3, HIGH}};  // High means multiplexer is disabled
int state[n][n];                                                            // State of each switch on the board

// set ssid and password for AccessPoint 
const char* ssid = "auto_chess";
const char* password = "12345678";
IPAddress IP;
WebSocketsServer webSocket = WebSocketsServer(81);                          // websocket running at port 81
// set end points for websocket
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
int getState(int row, int column) {
  int position = ((column * n) + row), bitCount = sizeof(selectionPinList) / sizeof(selectionPinList[0]), enableCount = sizeof(enablePinList) / sizeof(enablePinList[0]);
  for(int selectionPointer = 0; selectionPointer < bitCount; selectionPointer++) {
    digitalWrite(selectionPinList[selectionPointer][0], position % 2);
    position >>= 1;
  }
  for(int enablePointer = 0; enablePointer < enableCount; enablePointer++) {
    digitalWrite(enablePinList[enablePointer][0], HIGH);
  }
  digitalWrite(enablePinList[position][0], LOW);
  return digitalRead(OUTPUT);
}

void initPins() {
  int selectionPinCount = sizeof(selectionPinList) / sizeof(selectionPinList[0]), enablePinCount = sizeof(enablePinList) / sizeof(enablePinList[0]);
  Serial.println("Intiailizing Selection Pins.");
  for (int currentPinPointer = 0; currentPinPointer < selectionPinCount; currentPinPointer++) {
    digitalWrite(selectionPinList[currentPinPointer][0], selectionPinList[currentPinPointer][1]);
  }
  Serial.println("done.\nIntiailizing Enable Pins.");
  for (int currentPinPointer = 0; currentPinPointer < enablePinCount; currentPinPointer++) {
    digitalWrite(enablePinList[currentPinPointer][0], enablePinList[currentPinPointer][1]);
  }
  Serial.println("done.\nInitializing Output Pin.");
  digitalWrite(OUTPUT, OUTPUTSTATE);
  Serial.println("done.\n");
}

void initState() {
  Serial.println("Intiailizing State.");
  int targetCount = 32, currentCount = -1;
  while(currentCount != targetCount) {
    int temporaryCount = 0;
    if(currentCount != -1) {
      Serial.println("Invalid number of pieces detected. Please retry again in 10 seconds...");
      delay(10000);
    }
    Serial.println("Checking pieces now.");
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        state[i][j] = getState(i, j);
        if (state[i][j] == HIGH) {
          temporaryCount++;
        }
      }
    }
    currentCount = temporaryCount;
  }
  PieceCount = targetCount;
}

void setup() {
  Serial.begin(115200);
  // setup pins
  initPins();
  // setup state
  initState();
  // setup access point
  Serial.print("Setting Access Point - ");
  WiFi.mode(WIFI_AP);
  WiFi.softAP(ssid, password);
  Serial.println("done.");
  IP = WiFi.softAPIP();
  Serial.print("Host IP Address - ");
  Serial.println(IP);
  // start socket server
  webSocket.begin();
  webSocket.onEvent(onWebSocketEvent);
}

void loop() {
  webSocket.loop();
  int tempState[n][n];
  bool isUpdated = false;
  int currentCount = 0;
  for(int i = 0; i < n; i++) {
    for(int j = 0; j < n; j++) {
      tempState[j][i] = getState(j, i);
      if(tempState[j][i] != state[j][i]) {
        isUpdated = true;
      }
      currentCount += !tempState[j][i];
    }
  }
  if(isUpdated) {
    delay(5000);
    currentCount = 0;
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        tempState[j][i] = getState(j, i);
        if(tempState[j][i] != state[j][i]) {
          isUpdated = true;
        }
        currentCount += !tempState[j][i];
      }
    }
    if(tempState == state) {
      Serial.println("Piece put back to where it was");
    } else {
      if(PieceCount != currentCount) {
        if(currentCount == PieceCount - 1) {
          Serial.println("One piece moved out of board as it was captured. Waiting for the capturing pawn to move for 5 seconds");
          PieceCount = currentCount;
          delay(5000);
          currentCount = 0;
          for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
              tempState[j][i] = getState(j, i);
              if(tempState[j][i] != state[j][i]) {
                isUpdated = true;
              }
              currentCount += !tempState[j][i];
            }
          }
          if(currentCount == PieceCount) {
            Serial.println("Piece captured");
          } else {
            Serial.println("Invalid move. Please revert");
            while(tempState != state) {
              for(int i = 0; i < n; i++) {
                for(int j = 0; j < n; j++) {
                  tempState[j][i] = getState(j, i);
                  if(tempState[j][i] != state[j][i]) {
                    isUpdated = true;
                  }
                  currentCount += !tempState[j][i];
                }
              }
            }
          }
        } else {
            Serial.println("Invalid move. Please revert");
            while(tempState != state) {
              for(int i = 0; i < n; i++) {
                for(int j = 0; j < n; j++) {
                  tempState[j][i] = getState(j, i);
                  if(tempState[j][i] != state[j][i]) {
                    isUpdated = true;
                  }
                  currentCount += !tempState[j][i];
                }
              }
            }
          }
      } else {
        Serial.println("Valid move was made");
      }
    }
  }
  // if(isUpdated && currentCount == PieceCount) {
  //   Serial.print("Host IP Address (PORT 81) - ");
  //   Serial.println(IP);
  //   String updatedState = "";
  //   Serial.println("State Updated to ---------");
  //   for(int i = 0; i < n; i++) {
  //     for(int j = 0; j < m; j++) {
  //       state[i][j] = tempState[i][j];
  //       Serial.print(state[i][j]);
  //       updatedState += state[i][j] == HIGH ? "1 ": "0 ";
  //     }
  //     Serial.println("");
  //   }
  //   Serial.println("--------------------------");
  //   Serial.println("Brodcasting state to all devices: ");
  //   Serial.println(updatedState);
  //   webSocket.broadcastTXT(updatedState);
  // }
}