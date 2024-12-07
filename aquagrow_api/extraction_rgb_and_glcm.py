import os
import pandas as pd
from skimage import io, color
from skimage.feature import graycomatrix, graycoprops
import numpy as np

def extract_rgb(image):
    """Ekstrak nilai rata-rata RGB dari gambar."""
    red_mean = np.mean(image[:, :, 0])
    green_mean = np.mean(image[:, :, 1])
    blue_mean = np.mean(image[:, :, 2])
    return red_mean, green_mean, blue_mean

def extract_glcm_features(gray_image):
    """Ekstrak fitur GLCM: kontras, homogenitas, energi, dan korelasi."""
    glcm = graycomatrix(gray_image, distances=[1], angles=[0], symmetric=True, normed=True)
    contrast = graycoprops(glcm, 'contrast')[0, 0]
    homogeneity = graycoprops(glcm, 'homogeneity')[0, 0]
    energy = graycoprops(glcm, 'energy')[0, 0]
    correlation = graycoprops(glcm, 'correlation')[0, 0]
    return contrast, homogeneity, energy, correlation

def process_images(good_folder, bad_folder, output_file):
    """Proses gambar dalam folder 'baik' dan 'buruk' dan simpan hasil ekstraksi dalam file Excel atau CSV."""
    records = []  # Buffer untuk menyimpan semua data

    # Proses gambar pada folder "baik"
    for filename in os.listdir(good_folder):
        if filename.endswith(('.png', '.jpg', '.jpeg')):
            file_path = os.path.join(good_folder, filename)
            image = io.imread(file_path)

            # Jika gambar memiliki kanal alfa, gunakan hanya 3 channel pertama
            if image.shape[2] == 4:
                image = image[:, :, :3]

            # Ekstraksi RGB
            red, green, blue = extract_rgb(image)

            # Konversi gambar menjadi grayscale untuk ekstraksi GLCM
            gray_image = color.rgb2gray(image)
            gray_image = (gray_image * 255).astype(np.uint8)

            # Ekstraksi fitur GLCM
            contrast, homogeneity, energy, correlation = extract_glcm_features(gray_image)

            # Tambahkan data ke buffer
            records.append({
                "File Name": filename,
                "Category": "baik",  # Kategori baik
                "Average Red": red,
                "Average Green": green,
                "Average Blue": blue,
                "Contrast": contrast,
                "Homogeneity": homogeneity,
                "Energy": energy,
                "Correlation": correlation
            })

    # Proses gambar pada folder "buruk"
    for filename in os.listdir(bad_folder):
        if filename.endswith(('.png', '.jpg', '.jpeg')):
            file_path = os.path.join(bad_folder, filename)
            image = io.imread(file_path)

            # Jika gambar memiliki kanal alfa, gunakan hanya 3 channel pertama
            if image.shape[2] == 4:
                image = image[:, :, :3]

            # Ekstraksi RGB
            red, green, blue = extract_rgb(image)

            # Konversi gambar menjadi grayscale untuk ekstraksi GLCM
            gray_image = color.rgb2gray(image)
            gray_image = (gray_image * 255).astype(np.uint8)

            # Ekstraksi fitur GLCM
            contrast, homogeneity, energy, correlation = extract_glcm_features(gray_image)

            # Tambahkan data ke buffer
            records.append({
                "File Name": filename,
                "Category": "buruk",  # Kategori buruk
                "Average Red": red,
                "Average Green": green,
                "Average Blue": blue,
                "Contrast": contrast,
                "Homogeneity": homogeneity,
                "Energy": energy,
                "Correlation": correlation
            })

    # Setelah semua data terkumpul, buat DataFrame
    data = pd.DataFrame(records)

    # Simpan ke file Excel atau CSV
    if output_file.endswith('.xlsx'):
        data.to_excel(output_file, index=False)
    else:
        data.to_csv(output_file, index=False)

# Jalankan fungsi
good_folder = 'C:/xampp/htdocs/api/aquagrow_decisiontree/images_dataset/baik'  # Ganti dengan path folder gambar baik
bad_folder = 'C:/xampp/htdocs/api/aquagrow_decisiontree/images_dataset/buruk'  # Ganti dengan path folder gambar buruk
output_file = 'C:/xampp/htdocs/api/aquagrow_decisiontree/images_dataset/extraction.xlsx'  # Output file path
process_images(good_folder, bad_folder, output_file)
