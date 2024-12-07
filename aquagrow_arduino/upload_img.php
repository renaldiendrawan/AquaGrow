<?php
// Set timezone
date_default_timezone_set('Asia/Jakarta');

// Database connection settings
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "aquagrow";

// Target directory for uploaded images
$target_dir = "captured_images/";
$date = new DateTime(); // Current date and time
$date_string = $date->format('Y-m-d_His'); // Format for timestamped filename

// Validate if a file is uploaded
if (isset($_FILES["imageFile"]) && $_FILES["imageFile"]["error"] == UPLOAD_ERR_OK) {
    // Extract file details
    $imageFileType = strtolower(pathinfo($_FILES["imageFile"]["name"], PATHINFO_EXTENSION));
    $safeFileName = preg_replace('/[^a-zA-Z0-9_\-\.]/', '_', $_FILES["imageFile"]["name"]); // Sanitize file name
    $target_file = $target_dir . $date_string . "_" . $safeFileName;

    // Check if file is an image
    $check = getimagesize($_FILES["imageFile"]["tmp_name"]);
    if ($check === false) {
        die("File is not a valid image.<br>");
    }

    // Check file size (limit: 500 KB)
    if ($_FILES["imageFile"]["size"] > 500000) {
        die("File size exceeds the 500 KB limit.<br>");
    }

    // Check file type
    if (!in_array($imageFileType, ["jpg", "jpeg", "png", "gif"])) {
        die("Only JPG, JPEG, PNG, and GIF files are allowed.<br>");
    }

    // Attempt to move the uploaded file
    if (move_uploaded_file($_FILES["imageFile"]["tmp_name"], $target_file)) {
        echo "File uploaded successfully: " . $safeFileName . "<br>";

        // Save file information to the database
        $conn = new mysqli($servername, $username, $password, $dbname);

        // Check database connection
        if ($conn->connect_error) {
            die("Database connection failed: " . $conn->connect_error);
        }

        $upload_time = $date->format('Y-m-d H:i:s'); // Format for upload time
        $sql = "INSERT INTO tanaman (gambar, upload_time) VALUES ('$safeFileName', '$upload_time')";

        // Execute the query
        if ($conn->query($sql) === TRUE) {
            echo "File information saved to the database.<br>";
        } else {
            echo "Database error: " . $conn->error . "<br>";
        }

        // Close the connection
        $conn->close();
    } else {
        echo "Error moving the uploaded file.<br>";
    }
} else {
    echo "No file uploaded or an error occurred.<br>";
}
?>
