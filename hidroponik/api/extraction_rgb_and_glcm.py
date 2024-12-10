import os
import pandas as pd
from skimage.io import imread
from skimage.color import rgb2gray
from skimage.feature import graycomatrix, graycoprops
import numpy as np

# Fungsi untuk ekstraksi nilai rata-rata RGB
def extract_rgb(image):
    """Ekstrak nilai rata-rata RGB dari gambar."""
    red_mean = np.mean(image[:, :, 0])
    green_mean = np.mean(image[:, :, 1])
    blue_mean = np.mean(image[:, :, 2])
    return red_mean, green_mean, blue_mean

# Fungsi untuk ekstraksi fitur GLCM
def extract_glcm_features(gray_image):
    """Ekstrak fitur GLCM: kontras, homogenitas, energi, dan korelasi."""
    glcm = graycomatrix(gray_image, distances=[1], angles=[0], symmetric=True, normed=True)
    contrast = graycoprops(glcm, 'contrast')[0, 0]
    homogeneity = graycoprops(glcm, 'homogeneity')[0, 0]
    energy = graycoprops(glcm, 'energy')[0, 0]
    correlation = graycoprops(glcm, 'correlation')[0, 0]
    return contrast, homogeneity, energy, correlation

# Fungsi utama untuk memproses gambar dalam folder tertentu
def process_images(good_folder, bad_folder, output_file):
    """Proses gambar dalam folder 'baik' dan 'buruk' dan simpan hasil ekstraksi dalam file Excel atau CSV."""
    records = []  # Buffer untuk menyimpan semua data

    # Proses gambar pada folder "baik"
    print(f"Processing images in the '{good_folder}' folder...")
    for filename in os.listdir(good_folder):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            file_path = os.path.join(good_folder, filename)
            try:
                image = imread(file_path)

                # Jika gambar memiliki kanal alfa, gunakan hanya 3 channel pertama
                if image.shape[2] == 4:
                    image = image[:, :, :3]

                # Ekstraksi RGB
                red, green, blue = extract_rgb(image)

                # Konversi gambar menjadi grayscale untuk ekstraksi GLCM
                gray_image = rgb2gray(image)
                gray_image = (gray_image * 255).astype(np.uint8)

                # Ekstraksi fitur GLCM
                contrast, homogeneity, energy, correlation = extract_glcm_features(gray_image)

                # Tambahkan data ke buffer
                records.append({
                    "File Name": filename,
                    "Category": "baik",
                    "Average Red": red,
                    "Average Green": green,
                    "Average Blue": blue,
                    "Contrast": contrast,
                    "Homogeneity": homogeneity,
                    "Energy": energy,
                    "Correlation": correlation
                })
                print(f"Successfully processed: {filename}")
            except Exception as e:
                print(f"Error processing {file_path}: {e}")

    # Proses gambar pada folder "buruk"
    print(f"Processing images in the '{bad_folder}' folder...")
    for filename in os.listdir(bad_folder):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            file_path = os.path.join(bad_folder, filename)
            try:
                image = imread(file_path)

                # Jika gambar memiliki kanal alfa, gunakan hanya 3 channel pertama
                if image.shape[2] == 4:
                    image = image[:, :, :3]

                # Ekstraksi RGB
                red, green, blue = extract_rgb(image)

                # Konversi gambar menjadi grayscale untuk ekstraksi GLCM
                gray_image = rgb2gray(image)
                gray_image = (gray_image * 255).astype(np.uint8)

                # Ekstraksi fitur GLCM
                contrast, homogeneity, energy, correlation = extract_glcm_features(gray_image)

                # Tambahkan data ke buffer
                records.append({
                    "File Name": filename,
                    "Category": "buruk",
                    "Average Red": red,
                    "Average Green": green,
                    "Average Blue": blue,
                    "Contrast": contrast,
                    "Homogeneity": homogeneity,
                    "Energy": energy,
                    "Correlation": correlation
                })
                print(f"Successfully processed: {filename}")
            except Exception as e:
                print(f"Error processing {file_path}: {e}")

    # Setelah semua data terkumpul, buat DataFrame
    data = pd.DataFrame(records)

    # Simpan ke file Excel atau CSV
    if output_file.endswith('.xlsx'):
        data.to_excel(output_file, index=False)
    else:
        data.to_csv(output_file, index=False)

    print("Data extraction completed.")
    print(f"Results saved to: {output_file}")

# Jalankan fungsi
if __name__ == "__main__":
    good_folder = 'C:/xampp/htdocs/aquagrow/aquagrow_dataset/train/baik'  # Ganti dengan path folder gambar baik
    bad_folder = 'C:/xampp/htdocs/aquagrow/aquagrow_dataset/train/buruk'  # Ganti dengan path folder gambar buruk
    output_file = 'C:/xampp/htdocs/aquagrow/aquagrow_dataset/train/data_extraction.xlsx'  # Output file path
    process_images(good_folder, bad_folder, output_file)
