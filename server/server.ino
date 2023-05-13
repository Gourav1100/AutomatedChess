#include <WiFi.h>
#include <WebSocketsServer.h>
#include <cstring>
// Initialize data and assign Pins
#define n 8
#define S0 27
#define S1 26
#define S2 25
#define S3 33
#define O0 32
#define O1 18
#define O2 19
#define O3 21
// Initial configuration of pins
int selectionPinList[][2] = {{S0, LOW}, {S1, LOW}, {S2, LOW}, {S3, LOW}};   // LOW and HIGH are used for encoding
int outputPinList[][2] = {{O0, LOW}, {O1, LOW}, {O2, LOW}, {O3, LOW}};      // High means multiplexer is disabled
int PieceCount = 0;                                                         // Current Count of number of pieces on the board
int state[n][n], tempState[n][n];                                           // State of each switch on the board
int disableProc = 0;                                                        // flag to enable / disable loop processing
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
      if (payload[0] == 49) {
        for(int i = 0; i < n; i++) {
          for(int j = 0; j < n; j++) {
            state[i][j] = tempState[i][j];
          }
        }
        webSocket.broadcastTXT("CON");
      } else if (payload[0] == 48) {
        while(tempState != state) {
          for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
              tempState[j][i] = getState(j, i);
            }
          }
        }
        webSocket.broadcastTXT("CON");
      }
      disableProc = 0;
      webSocket.sendTXT(num, "Message Sent from client.");
      break;

    default:
      break;
  }
}

void initPins(int print = 1) {
  int selectionPinCount = sizeof(selectionPinList) / sizeof(selectionPinList[0]), outputPinCount = sizeof(outputPinList) / sizeof(outputPinList[0]);
  if(print) {
    Serial.println("Intiailizing Selection Pins.");
  }
  for (int currentPinPointer = 0; currentPinPointer < selectionPinCount; currentPinPointer++) {
    pinMode(selectionPinList[currentPinPointer][0], OUTPUT);
    digitalWrite(selectionPinList[currentPinPointer][0], selectionPinList[currentPinPointer][1]);
    if(print) {
      Serial.println(String(selectionPinList[currentPinPointer][0]) + " - " + String(selectionPinList[currentPinPointer][1]) + " - " + String(digitalRead(selectionPinList[currentPinPointer][0])));
    }
  }
  if(print) {
    Serial.println("done.\nIntiailizing Output Pins.");
  }
  for (int currentPinPointer = 0; currentPinPointer < outputPinCount; currentPinPointer++) {
    pinMode(outputPinList[currentPinPointer][0], OUTPUT);
    digitalWrite(outputPinList[currentPinPointer][0], outputPinList[currentPinPointer][1]);
    if(print) {
      Serial.println(String(outputPinList[currentPinPointer][0]) + " - " + String(outputPinList[currentPinPointer][1]) + " - " + String(digitalRead(outputPinList[currentPinPointer][0])));
    }
  }
  if(print) {
    Serial.println("done.\n");
  }
}

int getState(int row, int column) {
  int position = ((column * n) + row), bitCount = sizeof(selectionPinList) / sizeof(selectionPinList[0]), outputCount = sizeof(outputPinList) / sizeof(outputPinList[0]);
  for(int selectionPointer = 0; selectionPointer < bitCount; selectionPointer++) {
    digitalWrite(selectionPinList[selectionPointer][0], position % 2 ? HIGH : LOW);
    position >>= 1;
  }
  pinMode(outputPinList[position][0], INPUT);
  int res = digitalRead(outputPinList[position][0]);
  initPins(0);
  return res;
}

void initState() {
  Serial.println("Intiailizing State.");
  int targetCount = 1, currentCount = -1;
  while(currentCount != targetCount) {
    int temporaryCount = 0;
    if(currentCount != -1) {
      Serial.println("Invalid number of pieces detected. Please retry again in 5 seconds...");
      delay(5000);
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
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        Serial.print(state[i][j]);
      }
      Serial.println("");
    }
    currentCount = temporaryCount;
  }
  PieceCount = targetCount;
}

void setup() {
  Serial.begin(115200);
  delay(2000);
  // setup pins
  initPins();
  delay(2000);
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
  // if disableProc is set to True then skip this itteration. (It is unset by the socket endpoint and set when request is made)
  webSocket.loop();
  if (disableProc){
    return;
  }
  bool isUpdated = false;
  int currentCount = 0;
  // check the current state of board
  for(int i = 0; i < n; i++) {
    for(int j = 0; j < n; j++) {
      tempState[i][j] = getState(i, j);
      if(tempState[i][j] != state[i][j]) {
        isUpdated = true;
      }
      currentCount += !tempState[i][j];
    }
  }
  // if the state was updated then check for the all cases of piece movement.
  if(isUpdated) {
    delay(5000);
    currentCount = 0;
    // check if the peice was placed back from where it was picked.
    int middleState[n][n];
    int X, Y, X_Dash, Y_Dash;
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        middleState[i][j] = getState(i, j);
        currentCount += !middleState[j][i];
      }
    }
    // if true then continue execution.
    if(middleState == state) {
      Serial.println("Piece put back to where it was");
    } else {
      // if the piece was not placed back within 5 seconds, then it is assumed to be placed outside the box.
      if(PieceCount != currentCount) {
        // if the number of peices was only decreased by one then the piece is removed from the board.
        if(currentCount == PieceCount - 1) {
          // check again after 5 second whether any other piece was moved. If some other piece was moved then send a rmv signal, else consider it an invalid move.
          Serial.println("One piece moved out of board as it was captured. Waiting for the capturing pawn to move for 5 seconds");
          PieceCount = currentCount;
          currentCount = 0;
          delay(5000);
          for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
              tempState[j][i] = getState(j, i);
              if(tempState[j][i] != state[j][i]) {
                isUpdated = true;
              }
              currentCount += !tempState[j][i];
            }
          }
          if(currentCount == PieceCount && tempState != middleState) {
            Serial.println("Piece captured. Validating move on mobile application.");
            for(int i = 0; i < n; i++) {
              for(int j = 0; j < n; j++) {
                if(middleState[i][j] && middleState[i][j] != tempState[i][j]) {
                  X = i;
                  Y = j;
                } else if(tempState[i][j] && middleState[i][j] != tempState[i][j]){
                  X_Dash = i;
                  Y_Dash = j;
                }
              }
            }
            webSocket.broadcastTXT("RMV " + String(X) + " " + String(Y) + " " + String(X_Dash) + " " + String(Y_Dash));
            disableProc = 1;
          } else {
            // An invalid move is made ask user to revert back to original state.
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
            PieceCount = currentCount;
          }
        } else {
            // An invalid move is made ask user to revert back to original state.
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
            PieceCount = currentCount;
          }
      } else {
        // else if it is placed somewhere else then it is considered a move and validated on the mobile app.
        Serial.println("Validating move on application.");
        for(int i = 0; i < n; i++) {
          for(int j = 0; j < n; j++) {
            if(state[i][j] && tempState[i][j] != state[i][j]) {
              X = i;
              Y = j;
            } else if(tempState[i][j] && state[i][j] != tempState[i][j]){
              X_Dash = i;
              Y_Dash = j;
            }
          }
        }
        webSocket.broadcastTXT("MOV " + String(X) + " " + String(Y) + " " + String(X_Dash) + " " + String(Y_Dash));
        disableProc = 1;
      }
    }
  }
}