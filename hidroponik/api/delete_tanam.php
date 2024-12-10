<?php
$host = 'localhost';
$dbname = 'aquagrow';
$user = 'root';
$pass = ''; // Ganti dengan password MySQL Anda

header("Content-Type: application/json");

try {
    // Koneksi ke database
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Ambil data JSON yang dikirimkan
    $data = json_decode(file_get_contents("php://input"));

    // Jika id_tanam tidak ada dalam request, hapus semua data
    if (!isset($data->id_tanam)) {
        // Query untuk menghapus semua data
        $stmt = $pdo->prepare("DELETE FROM tgl_tanam");
        $stmt->execute();

        // Cek jika ada data yang dihapus
        if ($stmt->rowCount() > 0) {
            echo json_encode(["success" => true, "message" => "Semua data berhasil dihapus."]);
        } else {
            echo json_encode(["success" => false, "error" => "Tidak ada data yang dapat dihapus."]);
        }
    } else {
        // Ambil id_tanam dari data
        $id_tanam = $data->id_tanam;

        // Cek apakah ID Tanam ada di database
        $stmtCheck = $pdo->prepare("SELECT * FROM tgl_tanam WHERE id_tanam = :id_tanam");
        $stmtCheck->execute([':id_tanam' => $id_tanam]);

        // Jika ID tidak ditemukan, tampilkan pesan error
        if ($stmtCheck->rowCount() === 0) {
            echo json_encode(["success" => false, "error" => "ID Tanam tidak ditemukan."]);
            exit;
        }

        // Hapus data berdasarkan id_tanam
        $stmt = $pdo->prepare("DELETE FROM tgl_tanam WHERE id_tanam = :id_tanam");
        $stmt->execute([':id_tanam' => $id_tanam]);

        // Cek jika ada data yang dihapus
        if ($stmt->rowCount() > 0) {
            echo json_encode(["success" => true, "message" => "Data berhasil dihapus."]);
        } else {
            echo json_encode(["success" => false, "error" => "Data tidak ditemukan atau gagal dihapus."]);
        }
    }

} catch (PDOException $e) {
    // Tangani error dan tampilkan pesan kesalahan
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>
