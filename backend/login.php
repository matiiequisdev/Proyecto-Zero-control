<?php
require_once 'db.php';

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['email'], $data['password'])) {
    echo json_encode(["success" => false, "message" => "Missing data"]);
    exit;
}

$email = $conn->real_escape_string($data['email']);
$password = $data['password'];

$sql = "SELECT * FROM users WHERE email = '$email' AND password = '$password'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    if ($user['is_blocked'] == 1) {
        echo json_encode(["success" => false, "message" => "User is blocked"]);
    } else {
        echo json_encode([
            "success" => true,
            "user" => [
                "name" => $user['name'],
                "email" => $user['email'],
                "role" => (int)$user['role'],
                "isConnected" => (bool)$user['is_connected'],
                "lat" => $user['lat'] ? (double)$user['lat'] : null,
                "lng" => $user['lng'] ? (double)$user['lng'] : null
            ]
        ]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid credentials"]);
}

$conn->close();
?>
