<?php
session_start();
include 'conexion.php';

// Inicializar carrito si no existe
if (!isset($_SESSION['carrito'])) {
    $_SESSION['carrito'] = [];
}

// Guardar cliente seleccionado en sesión si se envía
if (isset($_POST['id_cliente']) && !isset($_SESSION['id_cliente'])) {
    $_SESSION['id_cliente'] = $_POST['id_cliente'];
}


// Eliminar producto del carrito
if (isset($_GET['eliminar']) && is_numeric($_GET['eliminar'])) {
    $index = $_GET['eliminar'];
    if (isset($_SESSION['carrito'][$index])) {
        unset($_SESSION['carrito'][$index]);
        $_SESSION['carrito'] = array_values($_SESSION['carrito']);
    }
    if (empty($_SESSION['carrito'])) {
        unset($_SESSION['id_cliente']);
    }
    header("Location: ventas.php");
    exit;
}

// Obtener productos
$stmt_productos = $pdo->query("CALL sp_obtener_productos_venta()");
$productos = $stmt_productos->fetchAll(PDO::FETCH_ASSOC);
$stmt_productos->closeCursor();

// Obtener clientes
$stmt_clientes = $pdo->query("CALL sp_obtener_clientes_venta()");
$clientes = $stmt_clientes->fetchAll(PDO::FETCH_ASSOC);
$stmt_clientes->closeCursor();

// Agregar producto al carrito usando SP con validación

if (isset($_POST['agregar_producto'])) {
    $id_producto = $_POST['id_producto'];
    $cantidad = $_POST['cantidad'];

    try {
        // Validar cantidad usando SP
        $stmt_validar = $pdo->prepare("CALL  registrar_venta_producto(:cantidad)");
        $stmt_validar->execute([':cantidad' => $cantidad]);
        $stmt_validar->closeCursor();

        // Si pasa la validación, obtener producto y agregar al carrito
        $stmt = $pdo->prepare("CALL sp_obtener_producto_por_id(:id_producto)");
        $stmt->execute([':id_producto' => $id_producto]);
        $producto = $stmt->fetch(PDO::FETCH_ASSOC);
        $stmt->closeCursor();

        if ($producto) {
            $_SESSION['carrito'][] = [
                'id_producto' => $id_producto,
                'descripcion' => $producto['descripcion'],
                'precio' => $producto['precio'],
                'cantidad' => $cantidad
            ];
        }

        header("Location: ventas.php");
        exit;

    } catch (PDOException $e) {
       if (preg_match('/SQLSTATE\[45000\]:.*?: 1644 (.+)/', $e->getMessage(), $match)) {
    $mensaje_error = $match[1]; // Extrae solo "La cantidad debe ser..."
} else {
    $mensaje_error = "Error al validar la cantidad.";
}// capturamos el mensaje del SP
    }}

// Obtener ventas
$stmt_ventas = $pdo->query("CALL sp_obtener_ventas()");
$ventas = $stmt_ventas->fetchAll(PDO::FETCH_ASSOC);
$stmt_ventas->closeCursor();
?>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Gestión de Ventas</title>
  <link rel="stylesheet" href="ventas.css">
</head>
<body>
<nav class="menu">
  <ul>
    <li><a href="ventas.php">Realizar Venta</a></li>
    <li><a href="logout.php" class="cerrar">Cerrar sesión</a></li>
  </ul>
</nav>
<div class="container">
  <?php if (!empty($mensaje_error)): ?>
  <div style="color: red; font-weight: bold; margin-bottom: 10px;">
    <?= htmlspecialchars($mensaje_error) ?>
  </div>
<?php endif; ?>

  <h2>Registrar Nueva Venta</h2>
  <form method="POST" action="ventas.php">
    <select name="id_cliente"  <?= !empty($_SESSION['carrito']) ? 'disabled' : '' ?>>
        <option value="">Seleccione un cliente</option>
        <?php foreach ($clientes as $cliente): ?>
            <option value="<?= $cliente['id_cliente'] ?>"
                <?= (isset($_SESSION['id_cliente']) && $_SESSION['id_cliente'] == $cliente['id_cliente']) ? 'selected' : '' ?>
            >
                <?= $cliente['nombre_cliente'] ?>
            </option>
        <?php endforeach; ?>
    </select>

    <label for="id_producto">Producto</label>
    <select name="id_producto" >
      <option value="">Seleccione un producto</option>
      <?php foreach ($productos as $producto): ?>
        <option value="<?= $producto['id_producto'] ?>"><?= $producto['descripcion'] ?> - S/ <?= $producto['precio'] ?></option>
      <?php endforeach; ?>
    </select>

    <input type="number" name="cantidad" min="1" placeholder="Cantidad" >
    <button type="submit" name="agregar_producto">Agregar al Carrito</button>
  </form>

  <?php if (!empty($_SESSION['carrito'])): ?>
    <h3>Carrito de Venta</h3>
    <table>
      <tr>
        <th>Producto</th>
        <th>Precio Unitario</th>
        <th>Cantidad</th>
        <th>Subtotal</th>
        <th>Acción</th>
      </tr>
      <?php
        $total = 0;
        foreach ($_SESSION['carrito'] as $i => $item):
 $subtotal = floatval($item['precio']) * intval($item['cantidad']);

          $total += $subtotal;
      ?>
        <tr>
          <td><?= $item['descripcion'] ?></td>
          <td>S/ <?= number_format($item['precio'], 2) ?></td>
          <td><?= $item['cantidad'] ?></td>
          <td>S/ <?= number_format($subtotal, 2) ?></td>
          <td><a href="ventas.php?eliminar=<?= $i ?>" onclick="return confirm('¿Eliminar este producto del carrito?')">Eliminar</a></td>
        </tr>
      <?php endforeach; ?>
      <tr>
        <td colspan="3"><strong>Total:</strong></td>
        <td colspan="2"><strong>S/ <?= number_format($total, 2) ?></strong></td>
      </tr>
    </table>

   
    <form method="POST" action="registrar_venta.php">
      <input type="hidden" name="id_cliente" value="<?= $_SESSION['id_cliente'] ?>">
      <button type="submit" name="registrar_venta">Registrar Venta</button>
     
    </form>
     <form method="GET" action="generar_boleta.php" target="_blank">
    <button type="submit">Generar Boleta PDF</button>
</form>
  <?php endif; ?>

  <h3>Ventas Realizadas</h3>
  <table>
    <tr>
      <th>ID</th>
      <th>Fecha</th>
      <th>ID Cliente</th>
    </tr>
    <?php foreach ($ventas as $venta): ?>
      <tr>
        <td><?= $venta['id_venta'] ?></td>
        <td><?= $venta['fecha'] ?></td>
        <td><?= $venta['id_cliente'] ?></td>
      </tr>
    <?php endforeach; ?>
  </table>

  <?php if (isset($_GET['mensaje']) && $_GET['mensaje'] == 'registrada'): ?>
    <p style="color:green;">Venta registrada exitosamente.</p>
  <?php endif; ?>
</div>
</body>
</html>
