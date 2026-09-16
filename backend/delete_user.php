<?php
require_once 'db.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['email'])) {
    echo json_encode(["success" => false, "message" => "Missing email"]);
    exit;
}

$email = $conn->real_escape_string($data['email']);

$sql = "DELETE FROM users WHERE email = '$email'";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "User deleted successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Error deleting record: " . $conn->error]);
}

$conn->close();
?>
