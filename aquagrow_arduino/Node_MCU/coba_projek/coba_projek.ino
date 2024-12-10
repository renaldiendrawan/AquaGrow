#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <TimeLib.h>
#include <ArduinoJson.h>
#include <NTPClient.h>
#include <WiFiUdp.h>

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 3600 * 7, 60000);

#define pumpNutrisi D1
#define lampuUV D6
#define ldrPin D2
#define tdsPin A0

const char* ssid = "Rombongan Bos Reza";
const char* password = "aaaaaaaa";
const char* serverIP = "http://192.168.18.7";
const char* insertEndpoint = "/aquagrow/insert.php";
const char* timeEndpoint = "/aquagrow/time.php";
const char* configEndpoint = "/aquagrow/config.php";

String serverName = String(serverIP) + insertEndpoint;
String timeServer = String(serverIP) + timeEndpoint;
String configServer = String(serverIP) + configEndpoint;

int mingguKe = 1;
int tdsThreshold = 400;
int uvStartHour = 8;
int uvEndHour = 16;

time_t waktuTanam = 0; // Waktu tanam diambil dari server
WiFiClient client;

time_t lastPostTime = 0;

void setup() {
  Serial.begin(9600);

  WiFi.begin(ssid, password);
  Serial.print("Menghubungkan ke WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("Terhubung ke WiFi dengan IP: ");
  Serial.println(WiFi.localIP());

  pinMode(pumpNutrisi, OUTPUT);
  pinMode(lampuUV, OUTPUT);
  pinMode(ldrPin, INPUT);

  digitalWrite(pumpNutrisi, HIGH);
  digitalWrite(lampuUV, HIGH);

  timeClient.begin();
  if (timeClient.update()) {
    setTime(timeClient.getEpochTime());
    Serial.println("Waktu sistem berhasil disinkronkan dengan NTP.");
  } else {
    Serial.println("Gagal menyinkronkan waktu dengan NTP. Menggunakan waktu default.");
    setTime(0, 0, 0, 19, 11, 2024);
  }

  syncWaktuTanamFromServer();
  syncConfigFromServer();
}

void loop() {
  if (waktuTanam > 0) {
    mingguKe = (now() - waktuTanam) / (7 * 24 * 60 * 60) + 1;
  }

  displayMingguHari();

  if (now() - lastPostTime >= 7200) {
    if (WiFi.status() == WL_CONNECTED) {
      HTTPClient http;
      http.begin(client, serverName);
      http.addHeader("Content-Type", "application/x-www-form-urlencoded");

      int tdsValue = analogRead(tdsPin);
      int ldrValue = digitalRead(ldrPin);
      String postData = "tds=" + String(tdsValue) + "&ldr=" + String(ldrValue);

      int httpResponseCode = http.POST(postData);

      if (httpResponseCode > 0) {
        String response = http.getString();
        Serial.println("Response: " + response);
        lastPostTime = now();
      } else {
        Serial.print("Error in sending POST: ");
        Serial.println(httpResponseCode);
      }

      http.end();
    } else {
      Serial.println("WiFi Tidak Terhubung");
    }
  }

  int tdsValue = analogRead(tdsPin);
  Serial.print("Nilai TDS: ");
  Serial.println(tdsValue);

  if (tdsValue < tdsThreshold) {
    digitalWrite(pumpNutrisi, LOW);
    Serial.println("Pompa Nutrisi: MENYALA");
  } else {
    digitalWrite(pumpNutrisi, HIGH);
    Serial.println("Pompa Nutrisi: MATI");
  }

  controlLampuUV();
  delay(1000);
}

void displayMingguHari() {
  if (waktuTanam > 0) {
    int totalDays = (now() - waktuTanam) / (24 * 60 * 60);
    int weeks = totalDays / 7;
    int days = totalDays % 7;

    Serial.print("Waktu sejak tanam: ");
    Serial.print(weeks);
    Serial.print(" minggu ");
    Serial.print(days);
    Serial.println(" hari");
  } else {
    Serial.println("Waktu tanam belum diatur.");
  }
}

void syncWaktuTanamFromServer() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(client, timeServer);

    int httpResponseCode = http.GET();
    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("Response waktu tanam dari server: " + response);

      DynamicJsonDocument doc(512);
      DeserializationError error = deserializeJson(doc, response);

      if (error) {
        Serial.print("Error parsing JSON: ");
        Serial.println(error.c_str());
        waktuTanam = now(); // Default waktu tanam ke waktu sekarang jika gagal
        return;
      }

      if (doc["status"] == "success") {
        waktuTanam = doc["set_waktu"].as<time_t>();
        Serial.print("Waktu tanam berhasil diperbarui: ");
        Serial.println(waktuTanam);
      } else {
        Serial.println("Gagal mendapatkan waktu tanam dari server.");
        waktuTanam = now();
      }
    } else {
      Serial.print("Error mendapatkan waktu tanam: ");
      Serial.println(httpResponseCode);
      waktuTanam = now();
    }

    http.end();
  } else {
    Serial.println("WiFi Tidak Terhubung untuk sinkronisasi waktu tanam");
    waktuTanam = now();
  }
}

void syncConfigFromServer() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(client, configServer + "?minggu_ke=" + String(mingguKe));

    int httpResponseCode = http.GET();
    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("Response konfigurasi dari server: " + response);

      DynamicJsonDocument doc(1024);
      DeserializationError error = deserializeJson(doc, response);

      if (error) {
        Serial.print("Error parsing JSON: ");
        Serial.println(error.c_str());
        Serial.println("Menggunakan nilai default.");
        return;
      }

      if (doc["status"] == "success") {
        JsonObject data = doc["data"];

        tdsThreshold = data["ambang_tds"] | 400;
        uvStartHour = data["uv_start_hour"] | 8;
        uvEndHour = data["uv_end_hour"] | 16;

        Serial.println("Konfigurasi berhasil disinkronkan:");
        Serial.print("Ambang TDS: ");
        Serial.println(tdsThreshold);
        Serial.print("UV Start Hour: ");
        Serial.println(uvStartHour);
        Serial.print("UV End Hour: ");
        Serial.println(uvEndHour);
      } else {
        Serial.println("Konfigurasi tidak ditemukan. Menggunakan nilai default.");
      }
    } else {
      Serial.print("Gagal mendapatkan konfigurasi dari server, kode error: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  } else {
    Serial.println("WiFi Tidak Terhubung untuk sinkronisasi konfigurasi");
  }
}

void controlLampuUV() {
  int currentHour = hour();
  int ldrValue = digitalRead(ldrPin);

  Serial.print("Jam Saat Ini: ");
  Serial.println(currentHour);

  if (currentHour >= uvStartHour && currentHour < uvEndHour) {
    if (ldrValue == HIGH) {
      digitalWrite(lampuUV, LOW);
      Serial.println("Lampu UV: MENYALA (Ruangan Gelap)");
    } else {
      digitalWrite(lampuUV, HIGH);
      Serial.println("Lampu UV: MATI (Ruangan Terang)");
    }
  } else {
    digitalWrite(lampuUV, HIGH);
    Serial.println("Lampu UV: MATI (Di luar periode kerja)");
  }
}
