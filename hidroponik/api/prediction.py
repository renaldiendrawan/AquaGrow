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
import time

# Membaca data dari file CSV
try:
    data = pd.read_csv('C:/xampp/htdocs/aquagrow/aquagrow_dataset/dataset.csv')
    # Mapping kategori menjadi angka
    data['Category'] = data['Category'].map({'baik': 1, 'buruk': 0})
except FileNotFoundError:
    print("File dataset.csv tidak ditemukan. Pastikan jalurnya benar.")
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

# Fungsi untuk menghapus latar belakang gambar menggunakan OpenCV
def remove_background(image):
    try:
        gray_image = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        _, thresholded = cv2.threshold(gray_image, 120, 255, cv2.THRESH_BINARY)
        result = cv2.bitwise_and(image, image, mask=thresholded)
        return result
    except Exception as e:
        print(f"Error removing background: {e}")
        return image

# Fungsi untuk ekstraksi fitur dari gambar
def extract_features(image_path):
    try:
        image = Image.open(image_path)
        if image.mode == 'RGBA':
            image = image.convert('RGB')
        image = image.resize((256, 256))
        image = np.array(image)

        image_no_bg = remove_background(image)

        avg_red = np.mean(image_no_bg[:, :, 0])
        avg_green = np.mean(image_no_bg[:, :, 1])
        avg_blue = np.mean(image_no_bg[:, :, 2])

        gray_image = color.rgb2gray(image_no_bg)
        gray_image = (gray_image * 255).astype(np.uint8)

        glcm = feature.graycomatrix(
            gray_image, distances=[1], angles=[0],
            symmetric=True, normed=True
        )

        homogeneity = feature.graycoprops(glcm, 'homogeneity')[0, 0]
        energy = np.sum(glcm ** 2)
        contrast = measure.shannon_entropy(gray_image)
        correlation = feature.graycoprops(glcm, 'correlation')[0, 0]

        return [avg_red, avg_green, avg_blue, contrast, homogeneity, energy, correlation]

    except Exception as e:
        print(f"Error extracting features from image {image_path}: {e}")
        raise

# Fungsi utama untuk prediksi dan mengirim hasil ke API
def predict_and_update(api_url):
    try:
        response = requests.get(f"{api_url}/get_images.php")
        if response.status_code != 200:
            print(f"Gagal mendapatkan data dari API: {response.text}")
            return

        images = response.json()

        # Filter hanya data dengan status_tanaman NULL
        images_to_predict = [img for img in images if img.get('status_tanaman') is None]

        if not images_to_predict:
            print("Tidak ada data dengan status_tanaman NULL untuk diproses.")
            return

        for img in images_to_predict:
            image_path = img['gambar']
            id_data = img['id_tanaman']

            try:
                # Pastikan file gambar ada
                if not os.path.exists(image_path):
                    print(f"Gambar tidak ditemukan: {image_path}")
                    continue

                features = extract_features(image_path)
                if len(features) != len(existing_columns):
                    raise ValueError(f"Feature length mismatch. Expected {len(existing_columns)}, got {len(features)}")
                prediksi = clf.predict([features])[0]
                kategori = 'baik' if prediksi == 1 else 'buruk'

                update_response = requests.post(f"{api_url}/update_prediction.php", data={
                    'id_tanaman': id_data,
                    'status_tanaman': kategori
                })

                if update_response.status_code == 200:
                    print(f"Berhasil mengirim prediksi untuk ID {id_data}: {kategori}")
                else:
                    print(f"Gagal mengirim prediksi untuk ID {id_data}. Respons: {update_response.text}")

            except Exception as e:
                print(f"Error processing image {image_path}: {e}")

    except Exception as e:
        print(f"Error accessing API: {e}")

# Menjalankan loop secara terus-menerus dan menunggu 10 detik setelah setiap prediksi
API_URL = "http://172.16.115.100/aquagrow/hidroponik/api"
print("Skrip berjalan otomatis setiap 10 detik...")
while True:
    predict_and_update(API_URL)
    time.sleep(10)  # Tunggu 10 detik sebelum menjalankan prediksi berikutnya
