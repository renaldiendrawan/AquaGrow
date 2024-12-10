<?php
// Konfigurasi database
$host = "localhost"; // Ganti sesuai konfigurasi server Anda
$user = "root";      // Ganti sesuai username database Anda
$password = "";      // Ganti sesuai password database Anda
$database = "aquagrow"; // Nama database Anda

// Membuat koneksi
$conn = new mysqli($host, $user, $password, $database);

// Cek koneksi
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => $conn->connect_error]));
}

// Query untuk mendapatkan data dari tabel 'tanaman'
$sql = "SELECT id_tanaman, gambar, status_tanaman, id_pengukuran FROM tanaman";
$result = $conn->query($sql);

$data = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = [
            "id_tanaman" => $row["id_tanaman"],
            "gambar" => "http://172.16.115.100/aquagrow/hidroponik/api/images/" . basename($row["gambar"]),
            "status_tanaman" => $row["status_tanaman"], // Status tanaman
            "id_pengukuran" => $row["id_pengukuran"],
        ];
    }
    echo json_encode(["status" => "success", "data" => $data]);
} else {
    echo json_encode(["status" => "error", "message" => "Tidak ada data."]);
}

// Menutup koneksi
$conn->close();
?>
