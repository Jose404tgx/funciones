<?php
include 'conexion.php';

try {
    $sql = "SELECT id_usuario, password FROM usuario";
    $stmt = $pdo->query($sql);
    $usuarios = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($usuarios as $usuario) {
        $passwordPlano = $usuario['password'];
        $hash = password_hash($passwordPlano, PASSWORD_DEFAULT);

        $updateStmt = $pdo->prepare("UPDATE usuario SET password = ? WHERE id_usuario = ?");
        $updateStmt->execute([$hash, $usuario['id_usuario']]);
    }

    echo "Contraseñas actualizadas a hash.";
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
