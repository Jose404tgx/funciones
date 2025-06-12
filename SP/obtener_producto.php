<?php
include 'conexion.php';
header('Content-Type: application/json');

$id = $_GET['id'] ?? null;
if (!$id) {
    echo json_encode(['error' => 'ID no proporcionado']);
    exit;
}

try {
    $stmt = $pdo->prepare("CALL sp_obtener_producto(?)");
    $stmt->execute([$id]);
    $producto = $stmt->fetch(PDO::FETCH_ASSOC);
    echo json_encode($producto);
} catch (Exception $e) {
    echo json_encode(['error' => 'Error al obtener producto']);
}
?>
