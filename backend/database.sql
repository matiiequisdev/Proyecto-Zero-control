CREATE DATABASE IF NOT EXISTS zerocontrol;
USE zerocontrol;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role INT NOT NULL, -- 0: admin, 1: tecnico, 2: vendedor, 3: transportista
    is_blocked TINYINT(1) DEFAULT 0,
    is_connected TINYINT(1) DEFAULT 1,
    lat DOUBLE DEFAULT NULL,
    lng DOUBLE DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
