<?php

// Koneksi ke database
require "db_connect.php";

// Mengambil data dari POST request
$tds = $_POST['tds'];
$ldr = $_POST['ldr'];

// Menentukan status pompa (LED A)
$status_pompa = ($tds < 400) ? "MENYALA" : "MATI";

// Logika untuk menentukan status lampu UV
$hour = date('H'); // Mendapatkan jam saat ini dalam format 24 jam
$uv_start_hour = 8; // Jam mulai kerja lampu UV
$uv_end_hour = 16;  // Jam akhir kerja lampu UV

if ($hour >= $uv_start_hour && $hour < $uv_end_hour) {
    // Dalam periode kerja UV
    $status_lampu_uv = ($ldr == 1) ? "MENYALA (Gelap)" : "MATI (Terang)";
} else {
    // Di luar periode kerja UV
    $status_lampu_uv = "MATI (Di luar jam kerja)";
}

// Query untuk menyimpan data ke dalam tabel
$sql = "INSERT INTO pengukuran (kadar_nutrisi, intensitas_cahaya, timestamp, status_pompa, status_lampu_uv)
        VALUES ('$tds', '$ldr', NOW(), '$status_pompa', '$status_lampu_uv')";

if ($conn->query($sql) === TRUE) {
    echo "Data berhasil disimpan";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

// Menutup koneksi
$conn->close();
?>
