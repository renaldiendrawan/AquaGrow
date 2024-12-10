<?php
// Konfigurasi koneksi database
$servername = "localhost";
$username = "root"; // Ganti dengan username database Anda
$password = ""; // Ganti dengan password database Anda
$dbname = "aquagrow2"; // Ganti dengan nama database Anda

// Membuat koneksi
$conn = new mysqli($servername, $username, $password, $dbname);

// Memeriksa koneksi
if ($conn->connect_error) {
    die("Koneksi gagal: " . $conn->connect_error);
}

// Mendapatkan data dari request body
$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['kadar_nutrisi'], $data['timestamp'])) {
    $kadar_nutrisi = $data['kadar_nutrisi'];
    $timestamp = $data['timestamp'];

    // Query untuk memasukkan data ke tabel `pengukuran`
    $sql = "INSERT INTO pengukuran (kadar_nutrisi, timestamp) 
            VALUES ('$kadar_nutrisi', '$timestamp')";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["success" => true, "message" => "Data berhasil dimasukkan!"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error: " . $conn->error]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap!"]);
}

// Menutup koneksi
$conn->close();
?>
