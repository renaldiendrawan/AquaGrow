<?php
// Konfigurasi Database
$host = 'localhost';  // Host database
$user = 'root';       // Username database
$pass = '';           // Password database
$db_name = 'aquagrow'; // Nama database

// Membuat koneksi
$conn = new mysqli($host, $user, $pass, $db_name);

// Memeriksa koneksi
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Query SQL untuk mengambil data
$sql = "SELECT id_tanam, set_waktu FROM tgl_tanam";
$result = $conn->query($sql);

// Menyiapkan respon
$response = [];
if ($result->num_rows > 0) {
    // Mengambil semua baris data
    while ($row = $result->fetch_assoc()) {
        // Pisahkan tanggal dan jam
        $tanggal = date('d M Y', strtotime($row['set_waktu']));
        $jam = date('H:i', strtotime($row['set_waktu']));
        
        $response[] = [
            'id_tanam' => $row['id_tanam'],
            'tanggal' => $tanggal,
            'jam' => $jam
        ];
    }
} else {
    // Jika tidak ada data
    $response['message'] = "No data found";
}

// Mengatur header respon menjadi JSON
header('Content-Type: application/json');
echo json_encode($response);

// Menutup koneksi
$conn->close();
?>
