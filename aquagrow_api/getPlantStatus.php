<?php
header('Content-Type: application/json');

// Include the connection file
include 'db.php'; // Pastikan file ini berisi konfigurasi koneksi database yang benar

// SQL query to get the latest values for `status`, `intensitas_cahaya`, `ketinggian_air`, and `kadar_nutrisi`
$sql = "SELECT t.status, p.intensitas_cahaya, p.ketinggian_air, p.kadar_nutrisi 
        FROM pengukuran p 
        JOIN tanaman t ON p.id_tanaman = t.id_tanaman 
        ORDER BY p.id_pengukuran DESC LIMIT 1";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // Output data of the row
    $row = $result->fetch_assoc();
    echo json_encode([
        'status' => 'success',
        'status_tanaman' => $row['status'],
        'intensitas_cahaya' => $row['intensitas_cahaya'],
        'ketinggian_air' => $row['ketinggian_air'],
        'kadar_nutrisi' => $row['kadar_nutrisi']
    ]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'No data found']);
}

// Close the database connection
$conn->close();
?>
