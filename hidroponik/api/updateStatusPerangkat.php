<?php
// Mengatur header untuk format JSON dan CORS
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Sertakan file koneksi database
include 'db.php'; // Pastikan file koneksi tersedia dan benar

// Mengambil data dari permintaan POST
$id_perangkat = isset($_POST['id_perangkat']) ? (int) $_POST['id_perangkat'] : null;
$status_perangkat = isset($_POST['status_perangkat']) ? $_POST['status_perangkat'] : null;

// Validasi input
if ($id_perangkat !== null && ($status_perangkat === 'hidup' || $status_perangkat === 'mati')) {
    // Query untuk mengupdate status perangkat
    $sql = "UPDATE perangkat SET status_perangkat = ? WHERE id_perangkat = ?";
    $stmt = $conn->prepare($sql);
    if ($stmt) {
        $stmt->bind_param("si", $status_perangkat, $id_perangkat);
        
        // Eksekusi statement dan periksa keberhasilannya
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Status updated successfully"]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to update status"]);
        }
        
        // Menutup statement
        $stmt->close();
    } else {
        echo json_encode(["success" => false, "message" => "Statement preparation failed"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid input data"]);
}

// Menutup koneksi
$conn->close();
?>
