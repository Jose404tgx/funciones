<?php
include 'conexion.php';

$nombres = $_POST['nombres'];
$apellidos = $_POST['apellidos'];
$direccion = $_POST['direccion'];
$telefono = $_POST['telefono'];

try {
    $stmt = $pdo->prepare("CALL sp_insertar_cliente(?, ?, ?, ?)");
    $stmt->execute([$nombres, $apellidos, $direccion, $telefono]);
    echo json_encode(['success' => true, 'message' => 'Cliente creado correctamente.']);
} catch (PDOException $e) {
    $mensaje = $e->getMessage();
    if (preg_match('/1644 (.+)$/', $mensaje, $coincide)) {
        $mensaje = $coincide[1];  // Extrae solo el mensaje del SIGNAL
    }
    echo json_encode(['success' => false, 'message' => $mensaje]);
}
?>
