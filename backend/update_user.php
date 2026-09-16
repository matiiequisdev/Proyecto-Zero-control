<?php
require_once 'db.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['email'])) {
    echo json_encode(["success" => false, "message" => "Missing email"]);
    exit;
}

$email = $conn->real_escape_string($data['email']);
$updates = [];

if (isset($data['password'])) {
    $pass = $conn->real_escape_string($data['password']);
    $updates[] = "password = '$pass'";
}

if (isset($data['is_blocked'])) {
    $block = (int)$data['is_blocked'];
    $updates[] = "is_blocked = $block";
}

if (isset($data['is_connected'])) {
    $conn_status = (int)$data['is_connected'];
    $updates[] = "is_connected = $conn_status";
}

if (isset($data['role'])) {
    $role = (int)$data['role'];
    $updates[] = "role = $role";
}

if (count($updates) == 0) {
    echo json_encode(["success" => false, "message" => "Nothing to update"]);
    exit;
}

$sql = "UPDATE users SET " . implode(", ", $updates) . " WHERE email = '$email'";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "User updated successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Error updating record: " . $conn->error]);
}

$conn->close();
?>
