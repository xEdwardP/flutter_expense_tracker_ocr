import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  Future<String?> extractTotal(File imageFile) async {
    final textRecognizer = TextRecognizer();

    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    // Buscar algo como 123.45 o L.456.00
    final regex = RegExp(r'(\d{2,4}\.\d{2})');

    for (var block in recognizedText.blocks) {
      for (var line in block.lines) {
        final match = regex.firstMatch(line.text);
        if (match != null) {
          return match.group(0);
        }
      }
    }

    return null;
  }
}
