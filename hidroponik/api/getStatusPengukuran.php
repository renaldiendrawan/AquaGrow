<?php
// Konfigurasi database
$servername = "localhost";
$username = "root";
$password = ""; // Ganti dengan password database Anda
$dbname = "aquagrow";

// Membuat koneksi
$conn = new mysqli($servername, $username, $password, $dbname);

// Cek koneksi
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Koneksi gagal: " . $conn->connect_error]);
    exit;
}

// Set karakter encoding agar mendukung UTF-8
$conn->set_charset("utf8");

// Query untuk mengambil data terbaru
$sql = "SELECT * FROM pengukuran ORDER BY timestamp DESC LIMIT 1";
$result = $conn->query($sql);

// Cek apakah hasil ada
if ($result && $result->num_rows > 0) {
    // Ambil data hasil kueri
    $data = $result->fetch_assoc();
    
    // Tampilkan data dalam format JSON
    echo json_encode([
        "status" => "success",
        "data" => [
            "id_pengukuran" => $data['id_pengukuran'],
            "kadar_nutrisi" => $data['kadar_nutrisi'],
            "intensitas_cahaya" => $data['intensitas_cahaya'],
            "status_pompa" => $data['status_pompa'],
            "status_lampu_uv" => $data['status_lampu_uv'],
            "timestamp" => $data['timestamp']
        ]
    ], JSON_PRETTY_PRINT);
} else {
    // Jika tidak ada data ditemukan
    echo json_encode(["status" => "error", "message" => "Tidak ada data ditemukan"]);
}

// Debugging tambahan (opsional, hapus di produksi)
if ($result === false) {
    echo json_encode(["status" => "error", "message" => "Kueri SQL gagal: " . $conn->error]);
}

// Menutup koneksi
$conn->close();
