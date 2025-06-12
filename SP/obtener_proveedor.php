<?php
include 'conexion.php';
header('Content-Type: application/json');

$id = $_GET['id'] ?? null;
if (!$id) {
  echo json_encode(['error' => 'ID no proporcionado']);
  exit;
}

$stmt = $pdo->prepare("CALL sp_obtener_proveedor(?)");
$stmt->execute([$id]);
$proveedor = $stmt->fetch(PDO::FETCH_ASSOC);
echo json_encode($proveedor);
?>
