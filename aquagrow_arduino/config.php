<?php
header("Content-Type: application/json");

// Koneksi ke database
require "db_connect.php";

// Mendapatkan parameter minggu_ke dari query string
$minggu_ke = isset($_GET['minggu_ke']) ? intval($_GET['minggu_ke']) : 1;

// Query untuk mendapatkan konfigurasi
$sql = "SELECT ambang_tds, uv_start_hour, uv_end_hour FROM control WHERE minggu_ke = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $minggu_ke);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $config = $result->fetch_assoc();
    echo json_encode(["status" => "success", "data" => $config]);
} else {
    echo json_encode(["status" => "error", "message" => "Konfigurasi tidak ditemukan"]);
}

$stmt->close();
$conn->close();
?>
