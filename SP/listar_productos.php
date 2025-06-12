<?php
include 'conexion.php';

$stmt = $pdo->query("CALL sp_listar_productos()");
$productos = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode($productos);
?>
