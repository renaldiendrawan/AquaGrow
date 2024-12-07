<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "aquagrow2";

// Membuat koneksi
$conn = new mysqli($servername, $username, $password, $dbname);

// Cek koneksi
if ($conn->connect_error) {
    die("Koneksi gagal: " . $conn->connect_error);
}

// Mengecek apakah ada data yang diterima
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id_user = $_POST['id_user'];
    $username = $_POST['username'];
    $password = $_POST['password'];

    // Cek apakah username atau password kosong
    if (empty($username) || empty($password)) {
        echo json_encode([
            "status" => "error",
            "message" => "Username atau password tidak boleh kosong"
        ]);
        exit();
    }

    // Hash password menggunakan MD5
    $hashedPassword = md5($password);

    // Menyimpan file gambar ke folder 'images' jika ada
    $upload_dir = "images/";
    if (!is_dir($upload_dir)) {
        mkdir($upload_dir, 0777, true);
    }

    $file_path = "";
    if (isset($_FILES['foto_profil']) && $_FILES['foto_profil']['error'] == UPLOAD_ERR_OK) {
        $file_name = basename($_FILES['foto_profil']['name']);
        $file_path = $upload_dir . time() . "_" . $file_name;
        move_uploaded_file($_FILES['foto_profil']['tmp_name'], $file_path);
    }

    // SQL untuk update data pengguna dengan prepared statements
    $sql = "UPDATE user SET username = ?, password = ?";
    $params = [$username, $hashedPassword];

    if ($file_path) {
        $sql .= ", foto_profil = ?";
        $params[] = $file_path;
    }
    $sql .= " WHERE id_user = ?";
    $params[] = $id_user;

    $stmt = $conn->prepare($sql);
    $stmt->bind_param(str_repeat("s", count($params)), ...$params);

    if ($stmt->execute()) {
        echo json_encode([
            "status" => "success",
            "message" => "Profil berhasil diperbarui",
            "imageUrl" => "http://192.168.1.14/api/" . $file_path
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Gagal memperbarui profil: " . $stmt->error
        ]);
    }
    $stmt->close();
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Metode tidak diizinkan"
    ]);
}

$conn->close();
?>
