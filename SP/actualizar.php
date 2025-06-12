<?php
include 'conexion.php';

$id_cliente = $_POST['id_cliente'];
$nombres = $_POST['nombres'];
$apellidos = $_POST['apellidos'];
$direccion = $_POST['direccion'];
$telefono = $_POST['telefono'];

try {
    $stmt = $pdo->prepare("CALL sp_actualizar_cliente(?, ?, ?, ?, ?)");
    $stmt->execute([$id_cliente, $nombres, $apellidos, $direccion, $telefono]);
    echo json_encode(['success' => true, 'message' => 'Cliente actualizado correctamente.']);
} catch (PDOException $e) {
    $mensaje = $e->getMessage();

    // Extraer el mensaje personalizado enviado por SIGNAL desde el SP
    if (preg_match('/SQLSTATE\[45000\]:.*?: 1644 (.+)/', $mensaje, $coincide)) {
        $mensaje = trim($coincide[1]);
    }

    echo json_encode(['success' => false, 'message' => $mensaje]);
}
?>
