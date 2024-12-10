<?php
header('Content-Type: application/json');

// Memasukkan file koneksi
require_once 'db.php';

try {
    // Mendapatkan data dari request POST
    $id_tanaman = $_POST['id_tanaman'] ?? null;
    $status_tanaman = $_POST['status_tanaman'] ?? null;

    // Validasi input
    if (!$id_tanaman || !$status_tanaman) {
        throw new Exception("Invalid input. Both 'id_tanaman' and 'status_tanaman' are required.");
    }

    // Query untuk memperbarui status berdasarkan ID
    $sql = "UPDATE tanaman SET status_tanaman = ? WHERE id_tanaman = ?";
    $stmt = $conn->prepare($sql);
    
    if ($stmt === false) {
        throw new Exception("Failed to prepare statement: " . $conn->error);
    }

    // Menggunakan parameter yang benar
    $stmt->bind_param("si", $status_tanaman, $id_tanaman);

    if ($stmt->execute()) {
        echo json_encode(["message" => "Prediction updated successfully"]);
    } else {
        throw new Exception("Error updating prediction: " . $stmt->error);
    }
} catch (Exception $e) {
    echo json_encode(["error" => $e->getMessage()]);
}

// Menutup koneksi
$conn->close();
?>
