<?php
header('Content-Type: application/json');

// Memasukkan file koneksi
require_once 'db.php'; // Pastikan file db.php sudah dikonfigurasi dengan benar

try {
    // Query untuk mengambil data gambar dari tabel tanaman
    $sql = "SELECT id_tanaman, gambar FROM tanaman WHERE status_tanaman = 'Baik'";
    $result = $conn->query($sql);

    // Array untuk menyimpan hasil query
    $data = [];
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
    }

    // Mengembalikan data dalam format JSON
    echo json_encode($data);
} catch (Exception $e) {
    // Mengembalikan error dalam format JSON
    echo json_encode(["error" => $e->getMessage()]);
}

// Menutup koneksi
$conn->close();
?>
