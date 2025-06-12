<?php
error_reporting(0);
ini_set('display_errors', 0);
header('Content-Type: application/json');

include 'conexion.php';

$id_proveedor = $_POST['id_proveedor'] ?? '';
$razonsocial = $_POST['razonsocial'] ?? '';
$direccion = $_POST['direccion'] ?? '';
$telefono = $_POST['telefono'] ?? '';

// Validar que id y razón social estén presentes
if (empty($id_proveedor)) {
    echo json_encode(['success' => false, 'message' => 'ID de proveedor es obligatorio.']);
    exit;
}
if (empty($razonsocial)) {
    echo json_encode(['success' => false, 'message' => 'La razón social es obligatoria.']);
    exit;
}

try {
    $stmt = $pdo->prepare("CALL sp_actualizar_proveedor(?, ?, ?, ?)");
    $stmt->execute([$id_proveedor, $razonsocial, $direccion, $telefono]);
    echo json_encode(['success' => true, 'message' => 'Proveedor actualizado correctamente.']);
} catch (PDOException $e) {
    $mensaje = $e->getMessage();
    if (preg_match('/1644 (.+)$/', $mensaje, $coincide)) {
        $mensaje = $coincide[1];
    }
    echo json_encode(['success' => false, 'message' => $mensaje]);
}
