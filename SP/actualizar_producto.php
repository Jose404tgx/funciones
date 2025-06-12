<?php
header('Content-Type: application/json');
include 'conexion.php';

// Recibir datos desde POST
$id_producto = $_POST['id_producto'] ?? '';
$descripcion = $_POST['descripcion'] ?? '';
$precio = $_POST['precio'] ?? '';
$stock = $_POST['stock'] ?? '';
$id_categoria = $_POST['id_categoria'] ?? '';
$id_proveedor = $_POST['id_proveedor'] ?? '';


try {
    $stmt = $pdo->prepare("CALL sp_actualizar_producto(?, ?, ?, ?, ?, ?)");
    $stmt->execute([
        $id_producto,
        $descripcion,
        $precio,
        $stock,
        $id_categoria,
        $id_proveedor
    ]);
    echo json_encode(['success' => true, 'message' => 'Producto actualizado correctamente.']);
} catch (PDOException $e) {
    $mensaje = $e->getMessage();
    // Captura mensaje SIGNAL personalizado
    if (preg_match('/45000: (.+)$/', $mensaje, $coincide)) {
        $mensaje = $coincide[1];
    }
    echo json_encode(['success' => false, 'message' => $mensaje]);
}
?>
