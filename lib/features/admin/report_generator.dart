import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../ventas/ventas_provider.dart';
import '../logistica/entregas_provider.dart';

enum ReportFormat { excel, pdf }

class ReportGenerator {
  static Future<void> generateReport({
    required BuildContext context,
    required List<Venta> ventas,
    required List<Entrega> entregas,
    required double totalVentas,
    required ReportFormat format,
  }) async {
    try {
      Uint8List bytes;
      String fileName;
      String extension;

      if (format == ReportFormat.excel) {
        bytes = await _generateExcelBytes(ventas, entregas, totalVentas);
        extension = 'xlsx';
        fileName = "Reporte_ZeroCONTROL_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      } else {
        bytes = await _generatePdfBytes(ventas, entregas, totalVentas);
        extension = 'pdf';
        fileName = "Reporte_ZeroCONTROL_${DateTime.now().millisecondsSinceEpoch}.pdf";
      }

      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: '¿Dónde quieres guardar el reporte?',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: [extension],
        bytes: bytes,
      );

      if (outputFile != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Reporte $extension guardado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error en ReportGenerator: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar reporte: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<Uint8List> _generateExcelBytes(List<Venta> ventas, List<Entrega> entregas, double totalVentas) async {
    final excel = Excel.createExcel();
    
    final Sheet sheetVentas = excel['Reporte Ventas'];
    sheetVentas.appendRow([
      TextCellValue('ID Venta'), TextCellValue('Cliente'), TextCellValue('Producto'),
      TextCellValue('Monto'), TextCellValue('Estado'), TextCellValue('Fecha'),
    ]);

    for (var v in ventas) {
      sheetVentas.appendRow([
        TextCellValue(v.id), TextCellValue(v.clienteNombre), TextCellValue(v.productoNombre),
        TextCellValue(v.price), TextCellValue(v.status), TextCellValue(v.fecha.toString().substring(0, 10)),
      ]);
    }

    final Sheet sheetLogistica = excel['Reporte Logistica'];
    sheetLogistica.appendRow([
      TextCellValue('ID Entrega'), TextCellValue('Cliente'), TextCellValue('Dirección'), TextCellValue('Estado'),
    ]);

    for (var e in entregas) {
      sheetLogistica.appendRow([
        TextCellValue(e.id), TextCellValue(e.cliente), TextCellValue(e.direccion), TextCellValue(e.status.name),
      ]);
    }

    if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');
    
    final List<int>? fileBytes = excel.save();
    if (fileBytes == null) throw Exception("Error al procesar Excel");
    return Uint8List.fromList(fileBytes);
  }

  static Future<Uint8List> _generatePdfBytes(List<Venta> ventas, List<Entrega> entregas, double totalVentas) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('REPORTE GLOBAL - ZeroCONTROL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                pw.Text(DateTime.now().toString().substring(0, 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('RESUMEN FINANCIERO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.Divider(),
          pw.Bullet(text: 'Ventas Totales: \$${totalVentas.toInt()}'),
          pw.Bullet(text: 'Total Pedidos: ${ventas.length}'),
          pw.SizedBox(height: 20),
          pw.Text('DETALLE DE VENTAS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.TableHelper.fromTextArray(
            headers: ['ID', 'Cliente', 'Producto', 'Precio', 'Estado'],
            data: ventas.map((v) => [v.id, v.clienteNombre, v.productoNombre, v.price, v.status]).toList(),
          ),
          pw.SizedBox(height: 30),
          pw.Text('DETALLE DE LOGISTICA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.TableHelper.fromTextArray(
            headers: ['ID', 'Cliente', 'Estado'],
            data: entregas.map((e) => [e.id, e.cliente, e.status.name]).toList(),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
