<?php
header('Content-Type: application/json');

// Database configuration
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "aquagrow2";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Database connection failed']));
}

// Check if the table has data
$check_sql = "SELECT COUNT(*) as total FROM pengukuran";
$result = $conn->query($check_sql);
$row = $result->fetch_assoc();

if ($row['total'] > 0) {
    // SQL query to delete the latest entry
    $sql = "DELETE FROM pengukuran ORDER BY id_pengukuran DESC LIMIT 1";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(['status' => 'success', 'message' => 'Data deleted successfully']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to delete data']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'No data available to delete']);
}

$conn->close();
?>
