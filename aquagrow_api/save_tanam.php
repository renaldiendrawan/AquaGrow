<?php
$host = '127.0.0.1';
$dbname = 'aquagrow2';
$user = 'root';
$pass = ''; // Ganti dengan password MySQL Anda

header("Content-Type: application/json");

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $data = json_decode(file_get_contents("php://input"));

    if (!isset($data->set_waktu)) {
        echo json_encode(["success" => false, "error" => "Data waktu tidak diberikan."]);
        exit;
    }

    $stmt = $pdo->prepare("INSERT INTO tgl_tanam (id_tanam, set_waktu) VALUES (:id_tanam, :set_waktu)");
    $stmt->execute([
        ':id_tanam' => $data->id_tanam ?? null, // Jika id_tanam kosong, gunakan null
        ':set_waktu' => $data->set_waktu, // Pastikan format datetime benar
    ]);

    echo json_encode(["success" => true]);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>
