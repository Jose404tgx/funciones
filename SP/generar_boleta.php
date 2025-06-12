<?php
ob_start(); // Evita errores por espacios antes del PDF
session_start();
require('fpdf.php');
include 'conexion.php';

if (!isset($_SESSION['carrito']) || empty($_SESSION['carrito'])) {
    die('No hay productos en el carrito.');
}

if (!isset($_SESSION['id_cliente'])) {
    die('No se ha seleccionado un cliente.');
}

// Obtener cliente desde la base de datos
$id_cliente = $_SESSION['id_cliente'];
$stmt = $pdo->prepare("CALL sp_obtener_cliente_por_id_ven(:id_cliente)");
$stmt->execute([':id_cliente' => $id_cliente]);
$cliente = $stmt->fetch(PDO::FETCH_ASSOC);
$stmt->closeCursor();

if (!$cliente) {
    die('Cliente no encontrado.');
}

// Clase personalizada PDF
class PDF extends FPDF {
    function Header() {
        $this->SetFont('Arial','B',16);
        $this->Cell(0,10,utf8_decode('Boleta de Venta'),0,1,'C');
        $this->Ln(5);
    }
    function Footer() {
        $this->SetY(-15);
        $this->SetFont('Arial','I',8);
        $this->Cell(0,10,'Página '.$this->PageNo(),0,0,'C');
    }
}

$pdf = new PDF();
$pdf->AddPage();
$pdf->SetFont('Arial','',12);

// Cliente
$nombreCompleto = $cliente['nombres'] . ' ' . $cliente['apellidos'];
$pdf->Cell(0,10,"Cliente: " . utf8_decode($nombreCompleto),0,1);
$pdf->Cell(0,10,"Fecha: " . date("d/m/Y H:i"),0,1);
$pdf->Ln(5);

// Encabezado tabla
$pdf->SetFillColor(220,220,220);
$pdf->Cell(80,10,'Producto',1,0,'C',true);
$pdf->Cell(30,10,'Precio',1,0,'C',true);
$pdf->Cell(30,10,'Cantidad',1,0,'C',true);
$pdf->Cell(40,10,'Subtotal',1,1,'C',true);

$total = 0;

foreach ($_SESSION['carrito'] as $item) {
    $subtotal = $item['precio'] * $item['cantidad'];
    $total += $subtotal;

    $pdf->Cell(80,10,utf8_decode($item['descripcion']),1);
    $pdf->Cell(30,10,'S/ '.number_format($item['precio'], 2),1,0,'R');
    $pdf->Cell(30,10,$item['cantidad'],1,0,'C');
    $pdf->Cell(40,10,'S/ '.number_format($subtotal, 2),1,1,'R');
}

// Total
$pdf->SetFont('Arial','B',12);
$pdf->Cell(140,10,'TOTAL',1);
$pdf->Cell(40,10,'S/ '.number_format($total, 2),1,1,'R');

$pdf->Output('I', 'boleta.pdf');
ob_end_flush();
?>
