# Import library yang diperlukan
import mysql.connector
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.metrics import classification_report, accuracy_score, confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

# Membaca dataset dari file CSV
file_csv = "C:/xampp/htdocs/api/aquagrow_decisiontree/data.csv"  # Ganti dengan path file CSV Anda
data = pd.read_csv(file_csv)

# Memisahkan fitur (X) dan label (y) tanpa kolom 'Edge Mean'
X = data[['Average Red', 'Average Green', 'Average Blue', 'Contrast', 
          'Homogeneity', 'Energy', 'Correlation']].values  # Menghapus 'Edge Mean'
y = data['Category'].values  # Kolom label

# Membagi data menjadi training dan testing
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# Melatih model
model = RandomForestClassifier(random_state=42)
model.fit(X_train, y_train)

# Membuat prediksi
y_pred = model.predict(X_test)

# Definisikan nama kategori (pastikan sesuai dengan label Anda)
target_names = list(data['Category'].unique())  # Mengambil nama kategori dari dataset

# Menghasilkan laporan klasifikasi
report = classification_report(y_test, y_pred, target_names=target_names, output_dict=True)
accuracy = accuracy_score(y_test, y_pred)

# Menampilkan laporan ke terminal
print("Laporan Hasil Klasifikasi:")
print(f"Accuracy: {accuracy:.2f}")
print(f"{classification_report(y_test, y_pred, target_names=target_names)}")

# Membuat Confusion Matrix
conf_matrix = confusion_matrix(y_test, y_pred, labels=target_names)

# Visualisasi Confusion Matrix
plt.figure(figsize=(8, 6))
sns.heatmap(conf_matrix, annot=True, fmt="d", cmap="Blues", xticklabels=target_names, yticklabels=target_names)
plt.title("Confusion Matrix")
plt.xlabel("Predicted Labels")
plt.ylabel("True Labels")
plt.show()

# Menyimpan hasil ke database
try:
    # Koneksi ke database
    db = mysql.connector.connect(
        host="localhost",
        user="root",
        password="",
        database="aquagrow"
    )
    cursor = db.cursor()

    # Query untuk memasukkan data
    query = """
    INSERT INTO model_accuracy (
        accuracy, precision_baik, recall_baik, f1_score_baik, support_baik,
        precision_buruk, recall_buruk, f1_score_buruk, support_buruk,
        macro_avg_precision, macro_avg_recall, macro_avg_f1_score,
        weighted_avg_precision, weighted_avg_recall, weighted_avg_f1_score,
        total_support
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """

    # Mengambil nilai dari laporan klasifikasi
    values = (
        accuracy,
        report['baik']['precision'], report['baik']['recall'], report['baik']['f1-score'], report['baik']['support'],
        report['buruk']['precision'], report['buruk']['recall'], report['buruk']['f1-score'], report['buruk']['support'],
        report['macro avg']['precision'], report['macro avg']['recall'], report['macro avg']['f1-score'],
        report['weighted avg']['precision'], report['weighted avg']['recall'], report['weighted avg']['f1-score'],
        sum(report[label]['support'] for label in target_names)  # Total support
    )

    # Menjalankan query
    cursor.execute(query, values)
    db.commit()

    # Output ke terminal
    print("\nLaporan berhasil disimpan ke database.")

except mysql.connector.Error as e:
    print(f"Error: {e}")

finally:
    if db.is_connected():
        cursor.close()
        db.close()
