#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <TimeLib.h> // Library untuk menangani waktu dan tanggal

#define pumpNutrisi D1
#define lampuUV D6
#define ldrPin D2
#define tdsPin A0

const char* ssid = "Rombongan Bos Reza";
const char* password = "aaaaaaaa";
const char* serverName = "http://192.168.18.7/aquagrow/insert.php";
const char* timeServer = "http://192.168.18.7/aquagrow/time.php";

int mingguKe = 1; // Inisialisasi minggu pertama
int tdsThreshold = 400; // Ambang TDS untuk minggu pertama

int uvStartHour = 8; // Jam mulai periode kerja UV (08:00 pagi)
int uvEndHour = 16;  // Jam akhir periode kerja UV (16:00 sore)

WiFiClient client;

void setup() {
  Serial.begin(9600);

  // Koneksi ke WiFi
  WiFi.begin(ssid, password);
  Serial.print("Menghubungkan ke WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("Terhubung ke WiFi dengan IP: ");
  Serial.println(WiFi.localIP());

  // Inisialisasi pin
  pinMode(pumpNutrisi, OUTPUT);
  pinMode(lampuUV, OUTPUT);
  pinMode(ldrPin, INPUT);

  // Matikan relay di awal
  digitalWrite(pumpNutrisi, HIGH); // Relay biasanya LOW aktif
  digitalWrite(lampuUV, HIGH);

  if (!syncTimeFromServer()) {
    Serial.println("Gagal menyinkronkan waktu dari server, menggunakan waktu default.");
    setTime(0, 0, 0, 19, 11, 2024); // Waktu default
  }
}

void loop() {
  // Update minggu dan TDS threshold setiap Senin
  if (weekday() == 2) { // 2 = Senin (1 adalah Minggu)
    tdsThreshold = 400 + (mingguKe - 1) * 200; // Naik 200 tiap minggu
    mingguKe++;
    Serial.print("Minggu ke-");
    Serial.print(mingguKe);
    Serial.print(" - Ambang TDS: ");
    Serial.println(tdsThreshold);
  }

  // Membaca sensor TDS dari pin analog
  int tdsValue = analogRead(tdsPin);
  Serial.print("Nilai TDS: ");
  Serial.println(tdsValue);

  // Kontrol relay LED A berdasarkan TDS
  if (tdsValue < tdsThreshold) {
    digitalWrite(pumpNutrisi, LOW); // Menyalakan LED A (LOW aktif)
    Serial.println("Pompa Nutrisi: MENYALA");
  } else {
    digitalWrite(pumpNutrisi, HIGH); // Mematikan LED A
    Serial.println("Pompa Nutrisi: MATI");
  }

  // Kontrol Lampu UV
  controlLampuUV();

  // Mengirim data sensor ke server jika WiFi terhubung
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(client, serverName);

    // Menambahkan header untuk mengirim data sebagai form-urlencoded
    http.addHeader("Content-Type", "application/x-www-form-urlencoded");

    // Mengirim data sensor dalam format POST
    String postData = "tds=" + String(tdsValue) + "&ldr=" + String(digitalRead(ldrPin));

    int httpResponseCode = http.POST(postData);

    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("Response: " + response);
    } else {
      Serial.print("Error in sending POST: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  } else {
    Serial.println("WiFi Tidak Terhubung");
  }

  delay(20000); // Interval pengiriman data ke server
}

// Fungsi untuk menyinkronkan waktu dari server
bool syncTimeFromServer() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(client, timeServer);

    int httpResponseCode = http.GET();
    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("Response waktu dari server: " + response);

      // Parsing data waktu (contoh: "2024-11-19 08:30:00")
      int year, month, day, hour, minute, second;
      if (sscanf(response.c_str(), "%d-%d-%d %d:%d:%d", &year, &month, &day, &hour, &minute, &second) == 6) {
        setTime(hour, minute, second, day, month, year);
        Serial.println("Waktu berhasil disinkronkan.");
        return true;
      } else {
        Serial.println("Format waktu tidak valid.");
      }
    } else {
      Serial.print("Gagal mendapatkan waktu dari server, kode error: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  }
  return false;
}

// Fungsi untuk kontrol Lampu UV
void controlLampuUV() {
  int currentHour = hour();
  int ldrValue = digitalRead(ldrPin);

  // Periksa apakah saat ini dalam periode kerja UV
  if (currentHour >= uvStartHour && currentHour < uvEndHour) {
    if (ldrValue == HIGH) { // Jika ruangan gelap
      digitalWrite(lampuUV, LOW); // Menyalakan lampu UV (LOW aktif)
      Serial.println("Lampu UV: MENYALA (Ruangan Gelap)");
    } else {
      digitalWrite(lampuUV, HIGH); // Mematikan lampu UV
      Serial.println("Lampu UV: MATI (Ruangan Terang)");
    }
  } else {
    digitalWrite(lampuUV, HIGH); // Mematikan lampu UV di luar jam kerja
    Serial.println("Lampu UV: MATI (Di luar periode kerja)");
  }
}
