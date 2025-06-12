<?php
include 'conexion.php';

$stmt = $pdo->query("CALL sp_listar_clientes()");
$clientes = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode($clientes);
?>