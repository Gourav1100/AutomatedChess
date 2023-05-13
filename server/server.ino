#include <WiFi.h>
#include <WebSocketsServer.h>
#include <cstring>

#define n 3
#define m 3
int PieceCount = 0;
int state[n][m];
int k[][m] = {{4, 5, 12}, {13, 14, 15}, {18, 19, 21}};

const char *ssid = "auto_chess";
const char *password = "12345678";
IPAddress IP;
WebSocketsServer webSocket = WebSocketsServer(81); // websocket running at port 81
// set end points for websocket
void onWebSocketEvent(uint8_t num, WStype_t type, uint8_t *payload, size_t length)
{
  switch (type)
  {
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
    if (payload[0] == 49)
    {
      for (int i = 0; i < n; i++)
      {
        for (int j = 0; j < n; j++)
        {
          state[i][j] = tempState[i][j];
        }
      }
      webSocket.broadcastTXT("CON");
    }
    else if (payload[0] == 48)
    {
      while (tempState != state)
      {
        for (int i = 0; i < n; i++)
        {
          for (int j = 0; j < n; j++)
          {
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
int getState(int row, int column)
{
  int position = ((column * n) + row), bitCount = sizeof(selectionPinList) / sizeof(selectionPinList[0]), enableCount = sizeof(enablePinList) / sizeof(enablePinList[0]);
  for (int selectionPointer = 0; selectionPointer < bitCount; selectionPointer++)
  {
    digitalWrite(selectionPinList[selectionPointer][0], position % 2);
    position >>= 1;
  }
  for (int enablePointer = 0; enablePointer < enableCount; enablePointer++)
  {
    digitalWrite(enablePinList[enablePointer][0], HIGH);
  }
  digitalWrite(enablePinList[position][0], LOW);
  return digitalRead(OUTPUT);
}

void initPins()
{
  int selectionPinCount = sizeof(selectionPinList) / sizeof(selectionPinList[0]), enablePinCount = sizeof(enablePinList) / sizeof(enablePinList[0]);
  Serial.println("Intiailizing Selection Pins.");
  for (int currentPinPointer = 0; currentPinPointer < selectionPinCount; currentPinPointer++)
  {
    digitalWrite(selectionPinList[currentPinPointer][0], selectionPinList[currentPinPointer][1]);
  }
  Serial.println("done.\nIntiailizing Enable Pins.");
  for (int currentPinPointer = 0; currentPinPointer < enablePinCount; currentPinPointer++)
  {
    digitalWrite(enablePinList[currentPinPointer][0], enablePinList[currentPinPointer][1]);
  }
  Serial.println("done.\nInitializing Output Pin.");
  digitalWrite(OUTPUT, OUTPUTSTATE);
  Serial.println("done.\n");
}

void initState()
{
  Serial.println("Intiailizing State.");
  int targetCount = 32, currentCount = -1;
  while (currentCount != targetCount)
  {
    int temporaryCount = 0;
    if (currentCount != -1)
    {
      Serial.println("Invalid number of pieces detected. Please retry again in 10 seconds...");
      delay(10000);
    }
    Serial.println("Checking pieces now.");
    for (int i = 0; i < n; i++)
    {
      for (int j = 0; j < n; j++)
      {
        state[i][j] = getState(i, j);
        if (state[i][j] == HIGH)
        {
          temporaryCount++;
        }
      }
    }
    currentCount = temporaryCount;
  }
  PieceCount = targetCount;
}

void initPins(int print = 1)
{
  int selectionPinCount = sizeof(selectionPinList) / sizeof(selectionPinList[0]), outputPinCount = sizeof(outputPinList) / sizeof(outputPinList[0]);
  if (print)
  {
    Serial.println("Intiailizing Selection Pins.");
  }
  for (int currentPinPointer = 0; currentPinPointer < selectionPinCount; currentPinPointer++)
  {
    pinMode(selectionPinList[currentPinPointer][0], OUTPUT);
    digitalWrite(selectionPinList[currentPinPointer][0], selectionPinList[currentPinPointer][1]);
    if (print)
    {
      Serial.println(String(selectionPinList[currentPinPointer][0]) + " - " + String(selectionPinList[currentPinPointer][1]) + " - " + String(digitalRead(selectionPinList[currentPinPointer][0])));
    }
  }
  if (print)
  {
    Serial.println("done.\nIntiailizing Output Pins.");
  }
  for (int currentPinPointer = 0; currentPinPointer < outputPinCount; currentPinPointer++)
  {
    pinMode(outputPinList[currentPinPointer][0], OUTPUT);
    digitalWrite(outputPinList[currentPinPointer][0], outputPinList[currentPinPointer][1]);
    if (print)
    {
      Serial.println(String(outputPinList[currentPinPointer][0]) + " - " + String(outputPinList[currentPinPointer][1]) + " - " + String(digitalRead(outputPinList[currentPinPointer][0])));
    }
  }
  if (print)
  {
    Serial.println("done.\n");
  }
}

int getState(int row, int column)
{
  int position = ((column * n) + row), bitCount = sizeof(selectionPinList) / sizeof(selectionPinList[0]), outputCount = sizeof(outputPinList) / sizeof(outputPinList[0]);
  for (int selectionPointer = 0; selectionPointer < bitCount; selectionPointer++)
  {
    digitalWrite(selectionPinList[selectionPointer][0], position % 2 ? HIGH : LOW);
    position >>= 1;
  }
  pinMode(outputPinList[position][0], INPUT);
  int res = digitalRead(outputPinList[position][0]);
  initPins(0);
  return res;
}

void initState()
{
  Serial.println("Intiailizing State.");
  int targetCount = 1, currentCount = -1;
  while (currentCount != targetCount)
  {
    int temporaryCount = 0;
    if (currentCount != -1)
    {
      Serial.println("Invalid number of pieces detected. Please retry again in 5 seconds...");
      delay(5000);
    }
    Serial.println("Checking pieces now.");
    for (int i = 0; i < n; i++)
    {
      for (int j = 0; j < n; j++)
      {
        state[i][j] = getState(i, j);
        if (state[i][j] == HIGH)
        {
          temporaryCount++;
        }
      }
    }
    for (int i = 0; i < n; i++)
    {
      for (int j = 0; j < n; j++)
      {
        Serial.print(state[i][j]);
      }
      Serial.println("");
    }
    currentCount = temporaryCount;
  }
  PieceCount = targetCount;
}

void setup()
{
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
}

void loop()
{
  // if disableProc is set to True then skip this itteration. (It is unset by the socket endpoint and set when request is made)
  webSocket.loop();
  int tempState[n][m];
  bool isUpdated = false;
  int currentCount = 0;
  // check the current state of board
  for (int i = 0; i < n; i++)
  {
    for (int j = 0; j < m; j++)
    {
      tempState[i][j] = digitalRead(k[i][j]);
      if (tempState[i][j] != state[i][j])
      {
        isUpdated = true;
      }
      currentCount += !tempState[j][i];
    }
  }
  if (isUpdated && currentCount == PieceCount)
  {
    Serial.print("Host IP Address (PORT 81) - ");
    Serial.println(IP);
    String updatedState = "";
    Serial.println("State Updated to ---------");
    for (int i = 0; i < n; i++)
    {
      for (int j = 0; j < m; j++)
      {
        state[i][j] = tempState[i][j];
        Serial.print(state[i][j]);
        updatedState += state[i][j] == HIGH ? "1 " : "0 ";
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
