<?php
$host = 'localhost';
$user = 'root';
$pass = '';
$db_name = 'aquagrow';

$conn = new mysqli($host, $user, $pass, $db_name);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = "SELECT id_tanam, set_waktu FROM tgl_tanam";
$result = $conn->query($sql);

$response = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $tanggal = date('d M Y', strtotime($row['set_waktu']));
        $jam = date('H:i', strtotime($row['set_waktu']));
        
        $response[] = [
            'id_tanam' => $row['id_tanam'],
            'tanggal' => $tanggal,
            'jam' => $jam
        ];
    }
    echo json_encode(["success" => true, "data" => $response]);
} else {
    echo json_encode(["success" => false, "message" => "No data found"]);
}

$conn->close();
?>
