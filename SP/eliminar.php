<?php
include 'conexion.php';

$id = $_GET['id'];
$stmt = $pdo->prepare("CALL sp_eliminar_cliente(?)");
$stmt->execute([$id]);

echo "Cliente eliminado correctamente.";
?>