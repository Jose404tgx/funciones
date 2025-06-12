<?php
include 'conexion.php';

$stmt = $pdo->query("CALL listar_proveedores()");
$proveedores = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode($proveedores);
?>

