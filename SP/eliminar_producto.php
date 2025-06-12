<?php
include 'conexion.php';

$id = $_GET['id'];
$stmt = $pdo->prepare("CALL eliminar_producto(?)");
$stmt->execute([$id]);

echo "Producto eliminado correctamente.";
?>
