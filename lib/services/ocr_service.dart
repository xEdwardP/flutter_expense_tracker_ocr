import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class OcrService {
  // Busca el total en el texto de la imagen usando palabras clave y regex
  Future<String?> extractTotal(File imageFile) async {
    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await textRecognizer.processImage(inputImage);

    // Palabras clave usuales para montos totales en facturas
    final keywords = [
      'total',
      'total a pagar',
      'importe',
      'saldo',
      'monto',
      'TOTAL A PAGAR:',
    ];
    // Regex para encontrar montos como 123.45, L.456.00, etc.
    final regex = RegExp(r'(\d{2,4}[.,]\d{2})');

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final textLine = line.text.toLowerCase();
        for (final keyword in keywords) {
          if (textLine.contains(keyword)) {
            final match = regex.firstMatch(textLine);
            if (match != null) {
              await textRecognizer.close();
              return match.group(0);
            }
          }
        }
      }
    }

    // Si no se encuentra por palabras clave, buscar montos grandes en todo el texto
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final match = regex.firstMatch(line.text);
        if (match != null) {
          await textRecognizer.close();
          return match.group(0);
        }
      }
    }

    await textRecognizer.close();
    return null;
  }
}
