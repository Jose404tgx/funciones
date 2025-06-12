<?php
include 'conexion.php';

$descripcion = $_POST['descripcion'] ?? '';

try {
    $stmt = $pdo->prepare("CALL sp_insertar_categoria( ? )");
    $stmt->execute([$descripcion]);
    echo json_encode(['success' => true, 'message' => 'Categoría creada correctamente.']);
} catch (PDOException $e) {
    $mensaje = $e->getMessage();
    if (preg_match('/1644 (.+)$/', $mensaje, $coincide)) {
        $mensaje = $coincide[1];
    }
    echo json_encode(['success' => false, 'message' => $mensaje]);
}
