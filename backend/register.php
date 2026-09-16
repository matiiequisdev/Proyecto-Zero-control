<?php
require_once 'db.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['name'], $data['email'], $data['password'], $data['role'])) {
    echo json_encode(["success" => false, "message" => "Missing data"]);
    exit;
}

$name = $conn->real_escape_string($data['name']);
$email = $conn->real_escape_string($data['email']);
$password = $data['password']; // In production, use password_hash()
$role = (int)$data['role'];

$sql = "INSERT INTO users (name, email, password, role) VALUES ('$name', '$email', '$password', $role)";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "User registered successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Error: " . $conn->error]);
}

$conn->close();
?>
