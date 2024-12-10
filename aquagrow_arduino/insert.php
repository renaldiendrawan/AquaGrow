<?php

// Koneksi ke database
require "db_connect.php";

// Header respons JSON
header("Content-Type: application/json");

// Validasi input POST
if (isset($_POST['tds']) && isset($_POST['ldr'])) {
    $tds = $_POST['tds'];
    $ldr = $_POST['ldr'];

    // Validasi nilai input
    if (!is_numeric($tds) || !is_numeric($ldr)) {
        echo json_encode([
            "status" => "error",
            "message" => "Nilai tds atau ldr tidak valid."
        ]);
        exit;
    }

    // Mendapatkan minggu ke berdasarkan waktu tanam
    date_default_timezone_set('Asia/Jakarta'); // Sesuaikan zona waktu
    $current_date = date("Y-m-d"); // Tanggal hari ini
    $minggu_ke = 1; // Default minggu ke

    $sql_tanam = "SELECT set_waktu FROM tgl_tanam ORDER BY id_tanam DESC LIMIT 1";
    $result_tanam = $conn->query($sql_tanam);

    if ($result_tanam && $result_tanam->num_rows > 0) {
        $row_tanam = $result_tanam->fetch_assoc();
        $waktu_tanam = $row_tanam['set_waktu'];
        $diff_days = (strtotime($current_date) - strtotime($waktu_tanam)) / (60 * 60 * 24);
        $minggu_ke = ceil($diff_days / 7); // Hitung minggu ke
    }

    // Ambil data kontrol berdasarkan minggu ke
    $sql_control = "SELECT ambang_tds, uv_start_hour, uv_end_hour FROM control WHERE minggu_ke = $minggu_ke LIMIT 1";
    $result_control = $conn->query($sql_control);

    if ($result_control && $result_control->num_rows > 0) {
        $row_control = $result_control->fetch_assoc();
        $ambang_tds = $row_control['ambang_tds'];
        $uv_start_hour = $row_control['uv_start_hour'];
        $uv_end_hour = $row_control['uv_end_hour'];
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Data kontrol tidak ditemukan untuk minggu ke $minggu_ke"
        ]);
        exit;
    }

    // Menentukan status pompa (LED A)
    $status_pompa = ($tds < $ambang_tds) ? "MENYALA" : "MATI";

    // Mendapatkan jam saat ini
    $hour = date('H'); // Format jam dalam 24 jam

    // Logika untuk menentukan status lampu UV
    if ($hour >= $uv_start_hour && $hour < $uv_end_hour) {
        $status_lampu_uv = ($ldr == 1) ? "MENYALA (Gelap)" : "MATI (Terang)";
    } else {
        $status_lampu_uv = "MATI (Di luar jam kerja)";
    }

    // Query untuk menyimpan data ke dalam tabel
    $sql = "INSERT INTO pengukuran (kadar_nutrisi, intensitas_cahaya, timestamp, status_pompa, status_lampu_uv)
            VALUES ('$tds', '$ldr', NOW(), '$status_pompa', '$status_lampu_uv')";

    if ($conn->query($sql) === TRUE) {
        echo json_encode([
            "status" => "success",
            "message" => "Data berhasil disimpan",
            "data" => [
                "tds" => $tds,
                "ldr" => $ldr,
                "status_pompa" => $status_pompa,
                "status_lampu_uv" => $status_lampu_uv,
                "ambang_tds" => $ambang_tds,
                "uv_start_hour" => $uv_start_hour,
                "uv_end_hour" => $uv_end_hour,
                "minggu_ke" => $minggu_ke
            ]
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Gagal menyimpan data",
            "error" => $conn->error
        ]);
    }
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Data POST tidak lengkap"
    ]);
}

// Menutup koneksi
$conn->close();

?>
