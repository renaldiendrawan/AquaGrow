<?php
// Mengimpor koneksi database
include('db.php');

// Query untuk mendapatkan laporan terbaru
$sql = "SELECT 
            accuracy, 
            precision_baik, recall_baik, f1_score_baik, support_baik,
            precision_buruk, recall_buruk, f1_score_buruk, support_buruk,
            macro_avg_precision, macro_avg_recall, macro_avg_f1_score,
            weighted_avg_precision, weighted_avg_recall, weighted_avg_f1_score,
            total_support, created_at
        FROM model_accuracy
        ORDER BY id DESC LIMIT 1";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // Mengambil data dari hasil query
    $row = $result->fetch_assoc();

    // Menampilkan hasil dalam format JSON
    echo json_encode([
        "status" => "success",
        "data" => [
            "accuracy" => $row['accuracy'],
            "baik" => [
                "precision" => (float) $row['precision_baik'],
                "recall" => (float) $row['recall_baik'],
                "f1_score" => (float) $row['f1_score_baik'],
                "support" => (int) $row['support_baik']
            ],
            "buruk" => [
                "precision" => (float) $row['precision_buruk'],
                "recall" => (float) $row['recall_buruk'],
                "f1_score" => (float) $row['f1_score_buruk'],
                "support" => (int) $row['support_buruk']
            ],
            "macro_avg" => [
                "precision" => (float) $row['macro_avg_precision'],
                "recall" => (float) $row['macro_avg_recall'],
                "f1_score" => (float) $row['macro_avg_f1_score']
            ],
            "weighted_avg" => [
                "precision" => (float) $row['weighted_avg_precision'],
                "recall" => (float) $row['weighted_avg_recall'],
                "f1_score" => (float) $row['weighted_avg_f1_score']
            ],
            "total_support" => (int) $row['total_support'],
            "created_at" => $row['created_at']
        ]
    ]);
} else {
    // Menampilkan pesan error jika data tidak ditemukan
    echo json_encode([
        "status" => "error",
        "message" => "Tidak ada data akurasi tersedia."
    ]);
}

// Menutup koneksi
$conn->close();
?>
