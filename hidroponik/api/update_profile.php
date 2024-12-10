<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "aquagrow";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Check if POST data is received
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id_user = $_POST['id_user'];
    $username = $_POST['username'];
    $password = $_POST['password'];

    // Check if username or password is empty
    if (empty($username) || empty($password)) {
        echo json_encode([
            "status" => "error",
            "message" => "Username or password cannot be empty"
        ]);
        exit();
    }

    // Hash the password
    $hashedPassword = md5($password);

    // Define upload directory
    $upload_dir = "images/";
    if (!is_dir($upload_dir)) {
        mkdir($upload_dir, 0777, true);
    }

    $file_path = "";
    if (isset($_FILES['foto_profil']) && $_FILES['foto_profil']['error'] == UPLOAD_ERR_OK) {
        // Handle file upload
        $file_name = basename($_FILES['foto_profil']['name']);
        $file_path = $upload_dir . time() . "_" . $file_name;
        move_uploaded_file($_FILES['foto_profil']['tmp_name'], $file_path);
    }

    // Update user profile
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
            "message" => "Profile updated successfully",
            "imageUrl" => "http://172.16.115.100/aquagrow/hidroponik/api/" . $file_path
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Failed to update profile: " . $stmt->error
        ]);
    }

    $stmt->close();
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Method not allowed"
    ]);
}

$conn->close();
?>
