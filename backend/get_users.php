<?php
require_once 'db.php';

$sql = "SELECT * FROM users ORDER BY created_at DESC";
$result = $conn->query($sql);

$users = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $users[] = [
            "name" => $row['name'],
            "email" => $row['email'],
            "role" => (int)$row['role'],
            "isBlocked" => (bool)$row['is_blocked'],
            "isConnected" => (bool)$row['is_connected'],
            "lat" => $row['lat'] ? (double)$row['lat'] : null,
            "lng" => $row['lng'] ? (double)$row['lng'] : null
        ];
    }
}

echo json_encode(["success" => true, "users" => $users]);

$conn->close();
?>
