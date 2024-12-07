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
const char* password = "aaaaaaaa";        // Password WiFi

// Variabel untuk Timer/Millis
unsigned long previousMillis = 0;
const int Interval = 20000; // Interval untuk mengambil foto dalam milidetik (20 detik).

// Alamat server untuk pengiriman foto
String serverName = "192.168.18.7";  // Alamat IP atau domain server
String serverPath = "/aquagrow/upload_img.php"; // Path file PHP untuk upload foto
const int serverPort = 80;              // Port server

// Variabel untuk mengatur apakah LED Flash akan menyala saat mengambil foto
bool LED_Flash_ON = true;

// Inisialisasi WiFiClient
WiFiClient client;

// Fungsi untuk mengirim foto ke server
void sendPhotoToServer() {
  String AllData;
  String DataBody;

  Serial.println();
  Serial.println("-----------");

  // Proses pra-pengambilan foto untuk memastikan timing akurat
  Serial.println("Mengambil foto...");

  // Nyalakan LED Flash jika diatur ke true
  if (LED_Flash_ON == true) {
    digitalWrite(FLASH_LED_PIN, HIGH);
    delay(1000);
  }

  // Ambil beberapa frame pertama untuk menstabilkan gambar
  for (int i = 0; i <= 3; i++) {
    camera_fb_t * fb = NULL;
    fb = esp_camera_fb_get();
    if (!fb) {
      Serial.println("Gagal mengambil foto");
      Serial.println("Restart ESP32 CAM...");
      delay(1000);
      ESP.restart();
      return;
    }
    esp_camera_fb_return(fb);
    delay(200);
  }

  // Ambil foto yang sebenarnya
  camera_fb_t * fb = NULL;
  fb = esp_camera_fb_get();
  if (!fb) {
    Serial.println("Gagal mengambil foto");
    Serial.println("Restart ESP32 CAM...");
    delay(1000);
    ESP.restart();
    return;
  }

  if (LED_Flash_ON == true) digitalWrite(FLASH_LED_PIN, LOW);

  Serial.println("Berhasil mengambil foto.");

  // Koneksi ke server
  Serial.println("Menghubungkan ke server: " + serverName);

  if (client.connect(serverName.c_str(), serverPort)) {
    Serial.println("Koneksi berhasil!");

    // Header POST untuk mengirim data gambar
    String post_data = "--dataMarker\r\nContent-Disposition: form-data; name=\"imageFile\"; filename=\"ESP32CAMCap.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n";
    String head = post_data;
    String boundary = "\r\n--dataMarker--\r\n";

    uint32_t imageLen = fb->len;
    uint32_t dataLen = head.length() + boundary.length();
    uint32_t totalLen = imageLen + dataLen;

    client.println("POST " + serverPath + " HTTP/1.1");
    client.println("Host: " + serverName);
    client.println("Content-Length: " + String(totalLen));
    client.println("Content-Type: multipart/form-data; boundary=dataMarker");
    client.println();
    client.print(head);

    uint8_t *fbBuf = fb->buf;
    size_t fbLen = fb->len;
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

    esp_camera_fb_return(fb);

    // Tunggu respons dari server
    int timoutTimer = 10000; // Timeout 10 detik
    long startTimer = millis();
    boolean state = false;
    Serial.println("Respons :");
    while ((startTimer + timoutTimer) > millis()) {
      Serial.print(".");
      delay(200);

      // Skip header HTTP
      while (client.available()) {
        char c = client.read();
        if (c == '\n') {
          if (AllData.length() == 0) { state = true; }
          AllData = "";
        } else if (c != '\r') {
          AllData += String(c);
        }
        if (state == true) { DataBody += String(c); }
        startTimer = millis();
      }
      if (DataBody.length() > 0) { break; }
    }
    client.stop();
    Serial.println(DataBody);
    Serial.println("-----------");
    Serial.println();

  } else {
    client.stop();
    DataBody = "Gagal terhubung ke " + serverName;
    Serial.println(DataBody);
    Serial.println("-----------");
  }
}

// Fungsi setup
void setup() {
  // Nonaktifkan detektor brownout
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);

  Serial.begin(115200);
  Serial.println();

  pinMode(FLASH_LED_PIN, OUTPUT);

  // Atur ESP32-CAM dalam mode WiFi Station
  WiFi.mode(WIFI_STA);
  Serial.println();

  // Proses koneksi ke WiFi
  Serial.println("Menghubungkan ke: " + String(ssid));
  WiFi.begin(ssid, password);

  int timeout = 20 * 2; // Timeout 20 detik
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
    if (timeout > 0) timeout--;
    if (timeout == 0) {
      Serial.println();
      Serial.println("Gagal terhubung ke WiFi. Restart ESP32-CAM...");
      delay(1000);
      ESP.restart();
    }
  }

  Serial.println();
  Serial.println("Berhasil terhubung ke WiFi.");

  // Inisialisasi kamera ESP32-CAM
  Serial.println("Mengatur kamera ESP32-CAM...");
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

  // init with high specs to pre-allocate larger buffers
  if(psramFound()){
    config.frame_size = FRAMESIZE_UXGA;
    config.jpeg_quality = 10;  //--> 0-63 lower number means higher quality
    config.fb_count = 2;
  } else {
    config.frame_size = FRAMESIZE_SVGA;
    config.jpeg_quality = 8;  //--> 0-63 lower number means higher quality
    config.fb_count = 1;
  }
  
  // camera init
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x", err);
    Serial.println();
    Serial.println("Restarting the ESP32 CAM.");
    delay(1000);
    ESP.restart();
  }

  sensor_t * s = esp_camera_sensor_get();

  // Selectable camera resolution details :
  // -UXGA   = 1600 x 1200 pixels
  // -SXGA   = 1280 x 1024 pixels
  // -XGA    = 1024 x 768  pixels
  // -SVGA   = 800 x 600   pixels
  // -VGA    = 640 x 480   pixels
  // -CIF    = 352 x 288   pixels
  // -QVGA   = 320 x 240   pixels
  // -HQVGA  = 240 x 160   pixels
  // -QQVGA  = 160 x 120   pixels
  s->set_framesize(s, FRAMESIZE_SXGA); //--> UXGA|SXGA|XGA|SVGA|VGA|CIF|QVGA|HQVGA|QQVGA

  Serial.println();
  Serial.println("Set camera ESP32 CAM successfully.");
  //

  Serial.println();
  Serial.print("ESP32-CAM captures and sends photos to the server every 20 seconds.");
}
//________________________________________________________________________________ 

//________________________________________________________________________________ VOID LOOP()
void loop() {
  // put your main code here, to run repeatedly:

  // Timer/Millis to capture and send photos to server every 20 seconds (see Interval variable).
  unsigned long currentMillis = millis();
  if (currentMillis - previousMillis >= Interval) {
    previousMillis = currentMillis;
    
    sendPhotoToServer();
  }
  
}


