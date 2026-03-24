#include <WiFi.h>
#include <HTTPClient.h>

// ================= WIFI =================
const char* ssid = "V";
const char* password = "12123434";

// ================= FIREBASE =================
String firebaseURL =
"https://ev-wireless-charging-ae877-default-rtdb.firebaseio.com/EV_001.json";

// ================= PINS =================
#define RELAY_PIN     5
#define ACS_PIN       36
#define GREEN_LED     13
#define RED_LED       12
#define BUZZER_PIN    14

// ================= ACS712 =================
#define ADC_REF       3300.0
#define ADC_RES       4096.0
#define ACS_SENS      185.0
#define ZERO_OFFSET   1650.0
#define CURRENT_TH    0.20

// ================= BATTERY =================
#define BATTERY_CAPACITY_WH   10.0

// ================= VARIABLES =================
float energy_Wh = 0;
float chargePercent = 0;
float timeRemainingMin = 0;

unsigned long lastTime = 0;

String status = "Idle";

bool charging = false;
bool fault = false;
bool fullCharge = false;


// ================= SETUP =================
void setup() {

  Serial.begin(115200);

  pinMode(RELAY_PIN, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  pinMode(RED_LED, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  digitalWrite(RELAY_PIN, HIGH);   // enable charging system

  Serial.println("Connecting WiFi");

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nWiFi Connected");
  Serial.print("IP: ");
  Serial.println(WiFi.localIP());

  lastTime = millis();
}


// ================= LOOP =================
void loop() {

  float voltage = 5.0;

  float current = readCurrent();

  float power = voltage * current;

  charging = false;
  fault = false;
  fullCharge = false;

  // ================= CHARGING DETECT =================
  if (current > CURRENT_TH) {

    charging = true;

    digitalWrite(RELAY_PIN, HIGH);

  }

  else {

    digitalWrite(RELAY_PIN, LOW);

    power = 0;
  }


  // ================= FAULT DETECT =================
  if (!charging && current > CURRENT_TH) {

    fault = true;

  }


  // ================= ENERGY CALCULATION =================
  unsigned long now = millis();

  float hours = (now - lastTime) / 3600000.0;

  lastTime = now;

  if (charging) {

    energy_Wh += power * hours;

  }


  // ================= CHARGE % =================
  chargePercent = (energy_Wh / BATTERY_CAPACITY_WH) * 100.0;

  if (chargePercent >= 100) {

    chargePercent = 100;

    fullCharge = true;

    charging = false;

    digitalWrite(RELAY_PIN, LOW);

  }


  // ================= TIME REMAINING =================
  if (power > 0 && !fullCharge) {

    float remainingEnergy =
      max(0.0, BATTERY_CAPACITY_WH - energy_Wh);

    float timeHr = remainingEnergy / power;

    timeRemainingMin = timeHr * 60.0;

  }

  else {

    timeRemainingMin = 0;

  }


  // ================= STATUS =================
  if (fault) status = "Fault";

  else if (fullCharge) status = "Fully Charged";

  else if (charging) status = "Charging";

  else status = "Idle";


  // ================= LED CONTROL =================

  if (fault) {

    digitalWrite(GREEN_LED, LOW);

    digitalWrite(RED_LED, HIGH);
    digitalWrite(BUZZER_PIN, HIGH);

    delay(200);

    digitalWrite(RED_LED, LOW);
    digitalWrite(BUZZER_PIN, LOW);

  }

  else if (charging) {

    digitalWrite(GREEN_LED, HIGH);

    digitalWrite(RED_LED, LOW);
    digitalWrite(BUZZER_PIN, LOW);

  }

  else if (fullCharge) {

    digitalWrite(GREEN_LED, HIGH);

    delay(500);

    digitalWrite(GREEN_LED, LOW);

  }

  else {

    digitalWrite(GREEN_LED, LOW);
    digitalWrite(RED_LED, LOW);
    digitalWrite(BUZZER_PIN, LOW);

  }


  // ================= SERIAL OUTPUT =================
  Serial.println("-------------");

  Serial.print("Status: ");
  Serial.println(status);

  Serial.print("Current: ");
  Serial.println(current);

  Serial.print("Power: ");
  Serial.println(power);

  Serial.print("Energy: ");
  Serial.println(energy_Wh);

  Serial.print("Charge %: ");
  Serial.println(chargePercent);

  Serial.print("Time Remaining: ");
  Serial.println(timeRemainingMin);

  Serial.print("Fault: ");
  Serial.println(fault);


  // ================= FIREBASE =================
  sendToFirebase(
    current,
    power,
    energy_Wh,
    chargePercent,
    timeRemainingMin,
    charging,
    fault,
    status
  );

  delay(2000);

}


// ================= CURRENT READ =================
float readCurrent() {

  long sum = 0;

  for (int i = 0; i < 200; i++) {

    sum += analogRead(ACS_PIN);

    delay(2);
  }

  float adc_avg = sum / 200.0;

  float voltage =
    (adc_avg * ADC_REF) / ADC_RES;

  float current =
    (voltage - ZERO_OFFSET) / ACS_SENS;

  if (abs(current) < 0.15) current = 0;

  return abs(current);
}


// ================= FIREBASE SEND =================
void sendToFirebase(
  float current,
  float power,
  float energy,
  float percent,
  float timeRemain,
  bool charging,
  bool fault,
  String status
) {

  if (WiFi.status() == WL_CONNECTED) {

    HTTPClient http;

    http.begin(firebaseURL);

    http.addHeader("Content-Type", "application/json");

    String payload = "{";

    payload += "\"current\":" + String(current,3) + ",";
    payload += "\"power\":" + String(power,3) + ",";
    payload += "\"energy\":" + String(energy,3) + ",";
    payload += "\"percentage\":" + String(percent,1) + ",";
    payload += "\"time_remaining_min\":" + String(timeRemain,1) + ",";
    payload += "\"charging\":" + String(charging ? 1 : 0) + ",";
    payload += "\"fault\":" + String(fault ? 1 : 0) + ",";
    payload += "\"status\":\"" + status + "\"";

    payload += "}";

    http.POST(payload);

    http.end();
  }
}