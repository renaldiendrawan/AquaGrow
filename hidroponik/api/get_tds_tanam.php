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

// Query untuk mengambil data TDS
$query = "SELECT minggu_ke, ambang_tds, uv_start_hour, uv_end_hour FROM control";
$result = $conn->query($query);

$response = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $response[] = [
            'minggu_ke' => $row['minggu_ke'],
            'ambang_tds' => $row['ambang_tds'],
            'uv_start_hour' => $row['uv_start_hour'],
            'uv_end_hour' => $row['uv_end_hour']
        ];
    }
    echo json_encode([
        "success" => true,
        "data" => $response
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Tidak ada data TDS yang ditemukan"
    ]);
}

$conn->close();
?>
