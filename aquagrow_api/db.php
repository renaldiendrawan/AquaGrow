<?php
$host = "localhost"; // Database host
$user = "root"; // Database username
$pass = ""; // Database password
$db_name = "aquagrow2"; // Replace with your database name

$conn = new mysqli($host, $user, $pass, $db_name);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
