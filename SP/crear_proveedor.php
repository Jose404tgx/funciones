<?php
error_reporting(0);
ini_set('display_errors', 0);
header('Content-Type: application/json');

include 'conexion.php';

$razonsocial = $_POST['razonsocial'] ?? '';
$direccion = $_POST['direccion'] ?? '';
$telefono = $_POST['telefono'] ?? '';

// Validar campos obligatorios
if (empty($razonsocial)) {
    echo json_encode(['success' => false, 'message' => 'La razón social es obligatoria.']);
    exit;
}

try {
    $stmt = $pdo->prepare("CALL sp_insertar_proveedor(?, ?, ?)");
    $stmt->execute([$razonsocial, $direccion, $telefono]);
    echo json_encode(['success' => true, 'message' => 'Proveedor insertado correctamente.']);
} catch (PDOException $e) {
    $mensaje = $e->getMessage();
    // Extraer mensaje del SIGNAL si lo hay
    if (preg_match('/1644 (.+)$/', $mensaje, $coincide)) {
        $mensaje = $coincide[1];
    }
    echo json_encode(['success' => false, 'message' => $mensaje]);
}