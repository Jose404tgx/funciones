<?php
include 'conexion.php';
header('Content-Type: application/json');

$id = $_GET['id'];

$stmt = $pdo->prepare("CALL sp_obtener_cliente_por_id(?)");
$stmt->execute([$id]);
$cliente = $stmt->fetch(PDO::FETCH_ASSOC);

echo json_encode($cliente);
?>