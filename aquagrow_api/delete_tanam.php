<?php
$host = 'localhost';
$dbname = 'aquagrow2';
$user = 'root';
$pass = ''; // Ganti dengan password MySQL Anda

header("Content-Type: application/json");

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $data = json_decode(file_get_contents("php://input"));

    if (!isset($data->id_tanam)) {
        echo json_encode(["success" => false, "error" => "ID Tanam tidak diberikan."]);
        exit;
    }

    $stmt = $pdo->prepare("DELETE FROM tgl_tanam WHERE id_tanam = :id_tanam");
    $stmt->execute([':id_tanam' => $data->id_tanam]);

    if ($stmt->rowCount() > 0) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "error" => "Data tidak ditemukan atau gagal dihapus."]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>
