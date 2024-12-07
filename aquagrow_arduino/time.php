<?php

// Koneksi ke database
require "db_connect.php";

// Query untuk mendapatkan waktu terbaru dari tabel
$sql = "SELECT set_waktu FROM tgl_tanam ORDER BY id_tanam DESC LIMIT 1";
$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo $row['set_waktu']; // Format: YYYY-MM-DD HH:MM:SS
} else {
    http_response_code(404);
    echo "Data waktu tidak ditemukan";
}

// Tutup koneksi
$conn->close();
?>
