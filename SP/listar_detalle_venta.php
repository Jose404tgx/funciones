<?php
include 'conexion.php';

try {
    $stmt = $pdo->query("CALL sp_listar_detalle_venta()");
    $detalleVentas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($detalleVentas);
} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>