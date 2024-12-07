<?php
$host = "localhost";
$user = "root";
$password = "";
$dbname = "aquagrow5";

// Koneksi ke database
$conn = new mysqli($host, $user, $password, $dbname);

if ($conn->connect_error) {
    die("Koneksi gagal: " . $conn->connect_error);
}

// Ambil data JSON dari Flutter
$data = json_decode(file_get_contents("php://input"), true);

$id_perangkat = $data['id_perangkat'];
$nama_perangkat = $data['nama_perangkat'];
$status_perangkat = $data['status_perangkat'];

// Query untuk memasukkan data
$sql = "INSERT INTO perangkat (id_perangkat, nama_perangkat, status_perangkat) 
        VALUES ('$id_perangkat', '$nama_perangkat', '$status_perangkat')
        ON DUPLICATE KEY UPDATE status_perangkat = '$status_perangkat'";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}

$conn->close();
?>
