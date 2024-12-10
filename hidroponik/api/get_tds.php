<?php
// Konfigurasi koneksi database
$host = "localhost";
$user = "root";
$password = "";
$dbname = "aquagrow";

$conn = new mysqli($host, $user, $password, $dbname);

// Periksa koneksi
if ($conn->connect_error) {
    die("Koneksi gagal: " . $conn->connect_error);
}

// Query untuk mengambil data
$query = "SELECT * FROM control";
$result = $conn->query($query);

$response = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $response[] = $row;
    }
    echo json_encode([
        "status" => "success",
        "data" => $response
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Tidak ada data yang ditemukan"
    ]);
}

$conn->close();
?>
