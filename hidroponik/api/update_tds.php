<?php
header('Content-Type: application/json');

try {
    // Koneksi database
    $conn = new mysqli('localhost', 'root', '', 'aquagrow');

    if ($conn->connect_error) {
        throw new Exception('Koneksi gagal: ' . $conn->connect_error);
    }

    // Mendapatkan data JSON dari request
    $data = json_decode(file_get_contents('php://input'), true);

    $minggu_ke = $data['minggu_ke'];
    $ambang_tds = $data['ambang_tds'];
    $uv_start_hour = $data['uv_start_hour'];
    $uv_end_hour = $data['uv_end_hour'];

    // Periksa apakah data dengan minggu_ke sudah ada
    $checkQuery = "SELECT * FROM control WHERE minggu_ke = '$minggu_ke'";
    $result = $conn->query($checkQuery);

    if ($result->num_rows > 0) {
        // Data ada, lakukan UPDATE
        $updateQuery = "UPDATE control 
                        SET ambang_tds = '$ambang_tds', 
                            uv_start_hour = '$uv_start_hour', 
                            uv_end_hour = '$uv_end_hour' 
                        WHERE minggu_ke = '$minggu_ke'";
        if ($conn->query($updateQuery) === TRUE) {
            echo json_encode(['success' => true, 'message' => 'Data berhasil diperbarui']);
        } else {
            throw new Exception('Gagal memperbarui data: ' . $conn->error);
        }
    } else {
        // Data tidak ada, lakukan INSERT
        $insertQuery = "INSERT INTO control (minggu_ke, ambang_tds, uv_start_hour, uv_end_hour)
                        VALUES ('$minggu_ke', '$ambang_tds', '$uv_start_hour', '$uv_end_hour')";
        if ($conn->query($insertQuery) === TRUE) {
            echo json_encode(['success' => true, 'message' => 'Data berhasil disimpan']);
        } else {
            throw new Exception('Gagal menyimpan data: ' . $conn->error);
        }
    }

    $conn->close();
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>
