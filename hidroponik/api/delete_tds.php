<?php
header("Content-Type: application/json");

$input = file_get_contents("php://input");
$data = json_decode($input, true);

if (isset($data['minggu_ke'])) {
    $minggu_ke = intval($data['minggu_ke']);

    // Hubungkan ke database
    $servername = "localhost";
    $username = "root";        // Ganti sesuai konfigurasi
    $password = "";            // Ganti sesuai konfigurasi
    $dbname = "aquagrow";      // Nama database Anda

    $conn = new mysqli($servername, $username, $password, $dbname);

    if ($conn->connect_error) {
        echo json_encode(["success" => false, "message" => "Koneksi database gagal: " . $conn->connect_error]);
        exit();
    }

    // Query untuk menghapus data dari tabel control
    $query = "DELETE FROM control WHERE minggu_ke = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $minggu_ke);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Data minggu ke-$minggu_ke berhasil dihapus."]);
    } else {
        echo json_encode(["success" => false, "message" => "Gagal menghapus data minggu ke-$minggu_ke."]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["success" => false, "message" => "Parameter 'minggu_ke' tidak ditemukan."]);
}
?>
