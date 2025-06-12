<?php
include 'conexion.php';

// Listar proveedores
function listarProveedores($conn) {
    $result = $conn->query("CALL listar_proveedores()");
    $proveedores = [];
    while ($fila = $result->fetch_assoc()) {
        $proveedores[] = $fila;
    }
    $result->close();
    $conn->next_result();
    return $proveedores;
}

// Obtener proveedor por ID
function obtenerProveedor($conn, $id) {
    $stmt = $conn->prepare("CALL obtener_proveedor_por_id(?)");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $res = $stmt->get_result();
    $proveedor = $res->fetch_assoc();
    $stmt->close();
    $conn->next_result();
    return $proveedor;
}

// Crear proveedor
function crearProveedor($conn, $razonsocial, $direccion, $telefono) {
    $stmt = $conn->prepare("CALL crear_proveedor(?, ?, ?)");
    $stmt->bind_param("sss", $razonsocial, $direccion, $telefono);
    $res = $stmt->execute();
    $stmt->close();
    $conn->next_result();
    return $res;
}

// Actualizar proveedor
function actualizarProveedor($conn, $id, $razonsocial, $direccion, $telefono) {
    $stmt = $conn->prepare("CALL actualizar_proveedor(?, ?, ?, ?)");
    $stmt->bind_param("isss", $id, $razonsocial, $direccion, $telefono);
    $res = $stmt->execute();
    $stmt->close();
    $conn->next_result();
    return $res;
}

// Eliminar proveedor
function eliminarProveedor($conn, $id) {
    $stmt = $conn->prepare("CALL eliminar_proveedor(?)");
    $stmt->bind_param("i", $id);
    $res = $stmt->execute();
    $stmt->close();
    $conn->next_result();
    return $res;
}
?>
