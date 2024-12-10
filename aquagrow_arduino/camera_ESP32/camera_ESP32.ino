#include <WiFi.h>
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"
#include "esp_camera.h"

// Definisi pin untuk kamera AI Thinker ESP32-CAM
#define PWDN_GPIO_NUM     32
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM      0
#define SIOD_GPIO_NUM     26
#define SIOC_GPIO_NUM     27

#define Y9_GPIO_NUM       35
#define Y8_GPIO_NUM       34
#define Y7_GPIO_NUM       39
#define Y6_GPIO_NUM       36
#define Y5_GPIO_NUM       21
#define Y4_GPIO_NUM       19
#define Y3_GPIO_NUM       18
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    25
#define HREF_GPIO_NUM     23
#define PCLK_GPIO_NUM     22

// Definisi pin untuk LED Flash
#define FLASH_LED_PIN 4

// Kredensial WiFi
const char* ssid = "Rombongan Bos Reza";       // Nama SSID WiFi
const char* password = "aaaaaaaa";            // Password WiFi

// Interval pengambilan gambar (10 detik)
const unsigned long captureInterval = 20000;
// Interval pengiriman gambar ke server (2 jam)
const unsigned long uploadInterval = 7200000;

// Variabel untuk Timer/Millis
unsigned long lastCaptureTime = 0;
unsigned long lastUploadTime = 0;

// Variabel untuk menyimpan gambar terakhir
camera_fb_t *lastCapturedPhoto = NULL;

// Alamat server untuk pengiriman foto
String serverName = "192.168.18.7";  // Alamat IP atau domain server
String serverPath = "/aquagrow/upload_img.php"; // Path file PHP untuk upload foto
const int serverPort = 80;              // Port server

// Variabel untuk mengatur apakah LED Flash akan menyala saat mengambil foto
bool LED_Flash_ON = true;

// Inisialisasi WiFiClient
WiFiClient client;

// Fungsi untuk mengambil foto
void capturePhoto() {
  // Nyalakan LED Flash jika diatur ke true
  if (LED_Flash_ON) {
    digitalWrite(FLASH_LED_PIN, HIGH);
    delay(1000);
  }

  // Ambil beberapa frame pertama untuk menstabilkan gambar
  for (int i = 0; i <= 3; i++) {
    camera_fb_t *fb = esp_camera_fb_get();
    if (fb) {
      esp_camera_fb_return(fb);
    }
    delay(200);
  }

  // Ambil foto yang sebenarnya
  if (lastCapturedPhoto != NULL) {
    esp_camera_fb_return(lastCapturedPhoto);
  }
  lastCapturedPhoto = esp_camera_fb_get();
  if (!lastCapturedPhoto) {
    Serial.println("Gagal mengambil foto");
    ESP.restart();
  }

  // Matikan LED Flash setelah mengambil gambar
  if (LED_Flash_ON) digitalWrite(FLASH_LED_PIN, LOW);

  Serial.println("Foto berhasil diambil.");
}

// Fungsi untuk mengirim foto ke server
void sendPhotoToServer() {
  if (lastCapturedPhoto == NULL) {
    Serial.println("Tidak ada foto untuk dikirim.");
    return;
  }

  Serial.println("Menghubungkan ke server: " + serverName);

  if (client.connect(serverName.c_str(), serverPort)) {
    Serial.println("Koneksi berhasil!");

    // Header POST untuk mengirim data gambar
    String post_data = "--dataMarker\r\nContent-Disposition: form-data; name=\"imageFile\"; filename=\"ESP32CAMCap.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n";
    String head = post_data;
    String boundary = "\r\n--dataMarker--\r\n";

    uint32_t imageLen = lastCapturedPhoto->len;
    uint32_t dataLen = head.length() + boundary.length();
    uint32_t totalLen = imageLen + dataLen;

    client.println("POST " + serverPath + " HTTP/1.1");
    client.println("Host: " + serverName);
    client.println("Content-Length: " + String(totalLen));
    client.println("Content-Type: multipart/form-data; boundary=dataMarker");
    client.println();
    client.print(head);

    uint8_t *fbBuf = lastCapturedPhoto->buf;
    size_t fbLen = lastCapturedPhoto->len;
    for (size_t n = 0; n < fbLen; n = n + 1024) {
      if (n + 1024 < fbLen) {
        client.write(fbBuf, 1024);
        fbBuf += 1024;
      } else if (fbLen % 1024 > 0) {
        size_t remainder = fbLen % 1024;
        client.write(fbBuf, remainder);
      }
    }
    client.print(boundary);

    // Tunggu respons dari server
    Serial.println("Menunggu respons server...");
    while (client.available()) {
      String line = client.readStringUntil('\n');
      Serial.println(line);
    }
    client.stop();
    Serial.println("Foto berhasil dikirim ke server.");
  } else {
    client.stop();
    Serial.println("Gagal terhubung ke server.");
  }
}

// Fungsi setup
void setup() {
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0); // Nonaktifkan detektor brownout
  Serial.begin(115200);
  pinMode(FLASH_LED_PIN, OUTPUT);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println("Berhasil terhubung ke WiFi.");

  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;

  if (psramFound()) {
    config.frame_size = FRAMESIZE_UXGA;
    config.jpeg_quality = 10;
    config.fb_count = 2;
  } else {
    config.frame_size = FRAMESIZE_SVGA;
    config.jpeg_quality = 8;
    config.fb_count = 1;
  }

  if (esp_camera_init(&config) != ESP_OK) {
    Serial.println("Inisialisasi kamera gagal.");
    ESP.restart();
  }
}

// Fungsi loop
void loop() {
  unsigned long currentMillis = millis();

  // Ambil gambar setiap 10 detik
  if (currentMillis - lastCaptureTime >= captureInterval) {
    lastCaptureTime = currentMillis;
    capturePhoto();
  }

  // Kirim gambar ke server setiap 1 jam
  if (currentMillis - lastUploadTime >= uploadInterval) {
    lastUploadTime = currentMillis;
    sendPhotoToServer();
  }
}
