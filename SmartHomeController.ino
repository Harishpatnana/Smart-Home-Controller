#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <DHT.h>
#include <Servo.h>

#define DHTPIN D4           // DHT11 Data pin
#define DHTTYPE DHT11
#define LIGHT_PIN D1        // Light control pin
#define FAN_PIN D2          // Fan control pin
#define SERVO_PIN D5        // Servo motor pin

DHT dht(DHTPIN, DHTTYPE);
Servo doorServo;
ESP8266WebServer server(80);

bool fanState = false;
bool lightState = false;
bool doorLocked = false;

const char* ssid = "YourUserName";       // Replace with your Wi-Fi SSID
const char* password = "YourPassword";   // Replace with your Wi-Fi Password

void setup() {
  Serial.begin(115200);

  pinMode(LIGHT_PIN, OUTPUT);
  pinMode(FAN_PIN, OUTPUT);
  digitalWrite(LIGHT_PIN, LOW);
  digitalWrite(FAN_PIN, LOW);

  doorServo.attach(SERVO_PIN);
  doorServo.write(0); // Initial position = unlocked

  dht.begin();

  WiFi.begin(ssid, password);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nConnected!");
  Serial.print("NodeMCU IP Address: ");
  Serial.println(WiFi.localIP());

  // Device control routes
  server.on("/light", handleLightControl);
  server.on("/fan", handleFanControl);
  server.on("/door", handleDoorControl);
  server.on("/status", handleStatus);

  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  server.handleClient();
}

void handleLightControl() {
  if (server.hasArg("state")) {
    lightState = (server.arg("state") == "1");
    digitalWrite(LIGHT_PIN, lightState ? HIGH : LOW);
  }
  server.send(200, "text/plain", "Light updated");
}

void handleFanControl() {
  if (server.hasArg("state")) {
    fanState = (server.arg("state") == "1");
    digitalWrite(FAN_PIN, fanState ? HIGH : LOW);
  }
  server.send(200, "text/plain", "Fan updated");
}

void handleDoorControl() {
  if (server.hasArg("state")) {
    doorLocked = (server.arg("state") == "1");
    doorServo.write(doorLocked ? 90 : 0); // 90 = locked, 0 = unlocked
  }
  server.send(200, "text/plain", "Door updated");
}

void handleStatus() {
  float temp = dht.readTemperature();
  float hum = dht.readHumidity();

  if (isnan(temp) || isnan(hum)) {
    server.send(500, "text/plain", "Sensor error");
    return;
  }

  String json = "{";
  json += "\"temperature\":" + String(temp, 1) + ",";
  json += "\"humidity\":" + String(hum, 1) + ",";
  json += "\"fan\":" + String(fanState ? 1 : 0) + ",";
  json += "\"light\":" + String(lightState ? 1 : 0) + ",";
  json += "\"door\":" + String(doorLocked ? 1 : 0);
  json += "}";

  server.send(200, "application/json", json);
}
