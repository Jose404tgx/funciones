<?php
include 'conexion.php';

$id = $_GET['id'];
$stmt = $pdo->prepare("CALL eliminar_categoria(?)");
$stmt->execute([$id]);

echo "Categoría eliminada correctamente.";
?>
