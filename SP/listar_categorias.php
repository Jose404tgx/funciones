<?php
include 'conexion.php';

$stmt = $pdo->query("CALL listar_categorias()");
$categorias = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode($categorias);
?>