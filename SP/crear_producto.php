<?php
error_reporting(0);
ini_set('display_errors', 0);
header('Content-Type: application/json');
include 'conexion.php';

// Capturar datos del formulario
$descripcion = $_POST['descripcion'] ?? '';
$precio = $_POST['precio'] ?? '';
$stock = $_POST['stock'] ?? '';
$id_categoria = $_POST['id_categoria'] ?? '';
$id_proveedor = $_POST['id_proveedor'] ?? '';

try {
    $stmt = $pdo->prepare("CALL sp_insertar_producto(?, ?, ?, ?, ?)");
    $stmt->execute([$descripcion, $precio, $stock, $id_categoria, $id_proveedor]);
    echo json_encode(['success' => true, 'message' => 'Producto creado correctamente.']);
} catch (PDOException $e) {
    // Extraer el mensaje personalizado del SIGNAL SQLSTATE si existe
    $mensaje = $e->getMessage();
    if (preg_match('/1644 (.+)$/', $mensaje, $coincide)) {
        $mensaje = $coincide[1];  // Extrae el mensaje del SIGNAL
    }
    echo json_encode(['success' => false, 'message' => $mensaje]);
}
