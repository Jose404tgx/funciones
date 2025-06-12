<?php
include 'conexion.php';

$id_categoria = $_POST['id_categoria'] ?? 0;
$descripcion = $_POST['descripcion'] ?? '';

try {
    $stmt = $pdo->prepare("CALL sp_actualizar_categoria(?, ?)");
    $stmt->execute([$id_categoria, $descripcion]);
    echo json_encode(['success' => true, 'message' => 'Categoría actualizada correctamente.']);
} catch (PDOException $e) {
    $mensaje = $e->getMessage();
    if (preg_match('/1644 (.+)$/', $mensaje, $coincide)) {
        $mensaje = $coincide[1];
    }
    echo json_encode(['success' => false, 'message' => $mensaje]);
}
