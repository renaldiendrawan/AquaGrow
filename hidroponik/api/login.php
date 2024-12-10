<?php
header("Content-Type: application/json");
require 'db.php';

// Ambil data dari POST
$username = isset($_POST['username']) ? trim($_POST['username']) : '';
$password = isset($_POST['password']) ? trim($_POST['password']) : '';

// Validasi input kosong untuk username
if (empty($username)) {
    echo json_encode(["status" => "fail", "message" => "Username tidak boleh kosong"]);
    exit();
}

// Validasi input kosong untuk password
if (empty($password)) {
    echo json_encode(["status" => "fail", "message" => "Password tidak boleh kosong"]);
    exit();
}

// Hash password input
$hashedPassword = md5($password); // Gunakan bcrypt atau password_hash() jika memungkinkan

// Cek username di database
$sql = "SELECT * FROM user WHERE username = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();

    // Validasi password
    if ($user['password'] === $hashedPassword) {
        echo json_encode(["status" => "success", "message" => "Login berhasil"]);
    } else {
        echo json_encode(["status" => "fail", "message" => "Password salah"]);
    }
} else {
    echo json_encode(["status" => "fail", "message" => "Username tidak ditemukan"]);
}

// Tutup koneksi
$stmt->close();
$conn->close();
?>
