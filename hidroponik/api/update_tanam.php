<?php
$host = 'localhost';
$dbname = 'aquagrow';
$user = 'root';
$pass = ''; // Ganti dengan password MySQL Anda

header("Content-Type: application/json");

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $data = json_decode(file_get_contents("php://input"));

    // Cek apakah data 'id_tanam' dan 'set_waktu' ada
    if (!isset($data->id_tanam) || !isset($data->set_waktu) || empty($data->set_waktu)) {
        echo json_encode(["success" => false, "error" => "Data 'id_tanam' atau 'set_waktu' tidak diberikan atau kosong."]);
        exit;
    }

    // Validasi format datetime
    if (!DateTime::createFromFormat('Y-m-d H:i:s', $data->set_waktu)) {
        echo json_encode(["success" => false, "error" => "Format waktu tidak valid. Gunakan format 'Y-m-d H:i:s'."]);
        exit;
    }

    // Cek apakah data dengan id_tanam sudah ada
    $stmt = $pdo->prepare("SELECT 1 FROM tgl_tanam WHERE id_tanam = :id_tanam LIMIT 1");
    $stmt->execute([':id_tanam' => $data->id_tanam]);
    $exists = $stmt->fetchColumn();

    if ($exists) {
        // Jika sudah ada, update data
        $stmt = $pdo->prepare("UPDATE tgl_tanam SET set_waktu = :set_waktu WHERE id_tanam = :id_tanam");
        $stmt->execute([
            ':set_waktu' => $data->set_waktu,
            ':id_tanam' => $data->id_tanam
        ]);

        echo json_encode(["success" => true, "message" => "Data berhasil diperbarui."]);
    } else {
        // Jika belum ada, tambahkan data baru
        $stmt = $pdo->prepare("INSERT INTO tgl_tanam (id_tanam, set_waktu) VALUES (:id_tanam, :set_waktu)");
        $stmt->execute([
            ':id_tanam' => $data->id_tanam,
            ':set_waktu' => $data->set_waktu
        ]);

        echo json_encode(["success" => true, "message" => "Data berhasil ditambahkan."]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "error" => "Terjadi kesalahan: " . $e->getMessage()]);
}
?>
