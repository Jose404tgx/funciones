<?php
session_start();
include 'conexion.php';
header('Content-Type: application/json');

$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

try {
    $stmt = $pdo->prepare("CALL login_usuario(?, ?)");
    $stmt->execute([$email, $password]);
    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);
    $stmt->closeCursor();

    if ($usuario) {
        echo json_encode([
            'success' => true,
            'redirect' => $usuario['redirect']
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Usuario o contraseña incorrectos.'
        ]);
    }

}catch (PDOException $e) {
    $msg = $e->getMessage();

    // Extraer solo el mensaje después del código 1644 (o cualquier número) y espacio
    // Busca ": <número> " y devuelve lo que viene después
    if (preg_match('/: \d+\s(.+)$/', $msg, $matches)) {
        $msg = $matches[1];
    }

    echo json_encode([
        'success' => false,
        'message' => $msg
    ]);
}