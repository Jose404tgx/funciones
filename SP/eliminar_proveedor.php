<?php
include 'conexion.php';

$id = $_GET['id'];
$stmt = $pdo->prepare("CALL eliminar_proveedor(?)");
$stmt->execute([$id]);

echo "Proveedor eliminado correctamente.";
?>
