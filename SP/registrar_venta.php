<?php
session_start();
include 'conexion.php';

if (isset($_POST['registrar_venta']) && !empty($_SESSION['carrito'])) {
    $id_cliente = $_POST['id_cliente'];
    $fecha = date('Y-m-d');

    try {
        // 1. Insertar venta usando procedimiento almacenado
        $stmt = $pdo->prepare("CALL sp_insertar_venta(:id_cliente, :fecha)");
        $stmt->execute([':id_cliente' => $id_cliente, ':fecha' => $fecha]);

        // Obtener el ID de la venta recién insertada
        $resultado = $stmt->fetch(PDO::FETCH_ASSOC);
        $id_venta = $resultado['nueva_venta_id'];
        $stmt->closeCursor();

        // 2. Insertar cada detalle usando procedimiento almacenado
        $stmt_detalle = $pdo->prepare("CALL sp_insertar_detalle_venta(:id_venta, :id_producto, :cantidad)");

        foreach ($_SESSION['carrito'] as $item) {
            $stmt_detalle->execute([
                ':id_venta' => $id_venta,
                ':id_producto' => $item['id_producto'],
                ':cantidad' => $item['cantidad']
            ]);
        }

        // 3. Limpiar carrito
        unset($_SESSION['carrito']);

        header("Location: ventas.php?mensaje=registrada");
        exit;
    } catch (PDOException $e) {
        echo "Error al registrar la venta: " . $e->getMessage();
    }
} else {
    echo "No hay productos en el carrito o falta cliente.";
}
?>
