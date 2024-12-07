<?php
header("Content-Type: application/json");
require 'db.php';

$username = isset($_POST['username']) ? trim($_POST['username']) : '';
$password = isset($_POST['password']) ? trim($_POST['password']) : '';

if (empty($username) || empty($password)) {
    echo json_encode(["status" => "fail", "message" => "Nama tidak boleh kosong"]);
    exit();
}

// Hash password input dengan MD5
$hashedPassword = md5($password);

$sql = "SELECT * FROM user WHERE username = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();

    // Bandingkan hash password
    if ($user['password'] === $hashedPassword) {
        echo json_encode(["status" => "success", "message" => "Login berhasil"]);
    } else {
        echo json_encode(["status" => "fail", "message" => "Password salah"]);
    }
} else {
    echo json_encode(["status" => "fail", "message" => "Nama tidak ditemukan"]);
}

$stmt->close();
$conn->close();
?>
