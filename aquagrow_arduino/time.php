<?php

// Koneksi ke database
require "db_connect.php";

// Inisialisasi respons
header("Content-Type: application/json");

$response = [];
try {
    // Query untuk mendapatkan waktu terbaru dari tabel
    $sql = "SELECT set_waktu FROM tgl_tanam ORDER BY id_tanam DESC LIMIT 1";
    $result = $conn->query($sql);

    if ($result && $result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $setWaktu = strtotime($row['set_waktu']); // Konversi ke UNIX timestamp
        $response = [
            "status" => "success",
            "set_waktu" => $setWaktu
        ];
        http_response_code(200);
    } else {
        http_response_code(404);
        $response = [
            "status" => "error",
            "message" => "Data waktu tidak ditemukan"
        ];
    }
} catch (Exception $e) {
    http_response_code(500);
    $response = [
        "status" => "error",
        "message" => "Terjadi kesalahan server",
        "error" => $e->getMessage()
    ];
} finally {
    // Tutup koneksi
    $conn->close();
}

// Output dalam format JSON
echo json_encode($response);

?>
