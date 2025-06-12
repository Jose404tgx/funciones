<?php
include 'conexion.php';
header('Content-Type: application/json');

if (!isset($_GET['id'])) {
  echo json_encode(['error' => 'ID no proporcionado']);
  exit;
}

$id = $_GET['id'];

$stmt = $pdo->prepare("CALL sp_obtener_categoria(?)");
$stmt->execute([$id]);

$categoria = $stmt->fetch(PDO::FETCH_ASSOC);
echo json_encode($categoria);
?>
