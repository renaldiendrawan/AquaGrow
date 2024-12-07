import os
import requests
import pandas as pd
import numpy as np
from PIL import Image
from skimage import color, feature, measure
import cv2  # Menambahkan OpenCV untuk pengolahan gambar
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import schedule
import time

# Membaca data dari file CSV
try:
    data = pd.read_csv('C:/xampp/htdocs/api/aquagrow_dataset/train/data_extraction.csv')
    # Mapping kategori menjadi angka
    data['Category'] = data['Category'].map({'baik': 1, 'buruk': 0})
except FileNotFoundError:
    print("File data.csv tidak ditemukan. Pastikan jalurnya benar.")
    exit()

# Daftar kolom fitur yang diharapkan
available_columns = ['Average Red', 'Average Green', 'Average Blue', 'Contrast', 
                     'Homogeneity', 'Energy', 'Correlation']

# Memastikan hanya kolom yang tersedia digunakan
existing_columns = [col for col in available_columns if col in data.columns]

# Memisahkan fitur (X) dan target (y)
X = data[existing_columns]
y = data['Category']

# Membagi data menjadi data latih dan uji
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# Melatih model Decision Tree
clf = DecisionTreeClassifier(random_state=42)
clf.fit(X_train, y_train)

# Evaluasi model
y_pred = clf.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)
print(f"Accuracy model pada data uji: {accuracy * 100:.2f}%")

# Fungsi untuk menghapus latar belakang gambar menggunakan OpenCV (thresholding sederhana)
def remove_background(image):
    try:
        # Mengkonversi gambar ke grayscale
        gray_image = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        
        # Menggunakan thresholding untuk memisahkan objek dari latar belakang
        _, thresholded = cv2.threshold(gray_image, 120, 255, cv2.THRESH_BINARY)

        # Menggunakan mask untuk menghapus latar belakang
        result = cv2.bitwise_and(image, image, mask=thresholded)
        return result
    except Exception as e:
        print(f"Error removing background: {e}")
        return image

# Fungsi untuk ekstraksi fitur dari gambar
def extract_features(image_path):
    try:
        # Membuka dan memproses gambar
        image = Image.open(image_path)
        if image.mode == 'RGBA':
            image = image.convert('RGB')  # Mengonversi ke RGB jika memiliki saluran alpha
        image = image.resize((256, 256))  # Mengubah ukuran gambar menjadi 256x256
        image = np.array(image)  # Konversi ke array numpy
        
        # Menghapus latar belakang dari gambar
        image_no_bg = remove_background(image)

        # Ekstraksi fitur RGB
        avg_red = np.mean(image_no_bg[:, :, 0])
        avg_green = np.mean(image_no_bg[:, :, 1])
        avg_blue = np.mean(image_no_bg[:, :, 2])
        
        # Konversi ke grayscale
        gray_image = color.rgb2gray(image_no_bg)
        gray_image = (gray_image * 255).astype(np.uint8)  # Skala ulang ke 0-255
        
        if gray_image.size < 2:
            raise ValueError("Image has insufficient size for processing.")
        
        # Ekstraksi fitur tekstur menggunakan GLCM
        glcm = feature.graycomatrix(
            gray_image,
            distances=[1],  # Jarak antar piksel
            angles=[0],     # Arah (horizontal)
            symmetric=True,
            normed=True
        )
        
        # Ekstraksi fitur GLCM
        homogeneity = feature.graycoprops(glcm, 'homogeneity')[0, 0]
        energy = np.sum(glcm ** 2)
        contrast = measure.shannon_entropy(gray_image)  # Menghitung kontras (entropi)
        
        # Ekstraksi fitur Correlation
        correlation = feature.graycoprops(glcm, 'correlation')[0, 0]
        
        # Mengembalikan hasil ekstraksi fitur
        return [avg_red, avg_green, avg_blue, contrast, homogeneity, energy, correlation]

    except Exception as e:
        print(f"Error extracting features from image {image_path}: {e}")
        raise

# Fungsi utama untuk prediksi dan mengirim hasil ke API
def predict_and_update(api_url):
    try:
        # Mendapatkan daftar gambar dari API
        response = requests.get(f"{api_url}/get_images.php")
        if response.status_code != 200:
            print(f"Gagal mendapatkan data dari API: {response.text}")
            return
        
        images = response.json()  # Mendapatkan daftar gambar sebagai JSON
        for img in images:
            image_path = img['gambar']  # Lokasi gambar
            id_data = img['id_tanaman']  # ID tanaman
            
            try:
                # Ekstraksi fitur dan prediksi
                features = extract_features(image_path)
                print(f"Extracted features for {image_path}: {features}")  # Debug log
                if len(features) != len(existing_columns):
                    raise ValueError(f"Feature length mismatch. Expected {len(existing_columns)}, got {len(features)}")
                prediksi = clf.predict([features])[0]
                kategori = 'baik' if prediksi == 1 else 'buruk'
                
                # Mengirim hasil prediksi ke API
                update_response = requests.post(f"{api_url}/update_prediction.php", data={
                    'id_tanaman': id_data,
                    'status_tanaman': kategori
                })
                
                # Cek jika request berhasil
                if update_response.status_code == 200:
                    print(f"Berhasil mengirim prediksi untuk ID {id_data}: {kategori}")
                else:
                    print(f"Gagal mengirim prediksi untuk ID {id_data}. Respons: {update_response.text}")
            
            except Exception as e:
                print(f"Error processing image {image_path}: {e}")
    except Exception as e:
        print(f"Error accessing API: {e}")

# Menjadwalkan tugas setiap 30 detik
API_URL = "http://192.168.137.121/api"
schedule.every(30).seconds.do(predict_and_update, api_url=API_URL)

# Menjalankan loop jadwal
print("Skrip berjalan otomatis setiap 30 detik...")
while True:
    schedule.run_pending()
    time.sleep(1)  # Mengurangi beban CPU
