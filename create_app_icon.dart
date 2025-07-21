import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() async {
  // Pastikan Flutter binding diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Buat ikon dengan ukuran 1024x1024 (ukuran terbesar yang dibutuhkan)
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = const Size(1024, 1024);

  // Background gradient
  final paint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.blue[600]!,
        Colors.indigo[700]!,
        Colors.purple[800]!,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

  // Gambar ikon kunci pas (wrench)
  final wrenchPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 80;

  // Gambar kunci pas
  final path = Path();
  path.moveTo(300, 400);
  path.lineTo(500, 600);
  path.lineTo(600, 500);
  path.lineTo(400, 300);
  path.close();

  canvas.drawPath(path, wrenchPaint);

  // Gambar lingkaran untuk kepala kunci pas
  canvas.drawCircle(const Offset(350, 350), 100, wrenchPaint);

  // Tambahkan teks "MB" (MyBengkel)
  final textPainter = TextPainter(
    text: TextSpan(
      text: 'MB',
      style: TextStyle(
        color: Colors.white,
        fontSize: 200,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2 + 200,
      ));

  final picture = recorder.endRecording();
  final image = await picture.toImage(1024, 1024);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();

  // Simpan file
  final file = File('assets/icons/app_icon.png');
  await file.create(recursive: true);
  await file.writeAsBytes(bytes);

  print('Ikon aplikasi berhasil dibuat di: assets/icons/app_icon.png');
}
