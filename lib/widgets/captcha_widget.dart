import 'dart:math';
import 'package:flutter/material.dart';

class CaptchaWidget extends StatefulWidget {
  final Function(bool) onVerified;
  final VoidCallback onRefresh;

  const CaptchaWidget({
    super.key,
    required this.onVerified,
    required this.onRefresh,
  });

  @override
  State<CaptchaWidget> createState() => _CaptchaWidgetState();
}

class _CaptchaWidgetState extends State<CaptchaWidget> {
  late String _captchaText;
  final TextEditingController _controller = TextEditingController();
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    _captchaText = List.generate(
      6,
          (index) => chars[random.nextInt(chars.length)],
    ).join();
    _controller.clear();
    setState(() {
      _isCorrect = null;
    });
  }

  void _verifyCaptcha() {
    final isCorrect = _controller.text.toUpperCase() == _captchaText;
    setState(() {
      _isCorrect = isCorrect;
    });
    widget.onVerified(isCorrect);

    if (!isCorrect) {
      Future.delayed(const Duration(seconds: 1), () {
        _generateCaptcha();
        widget.onRefresh();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCorrect == null
              ? Colors.grey[300]!
              : _isCorrect!
              ? Colors.green
              : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Verification',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // CAPTCHA Display
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: CustomPaint(
                    painter: CaptchaPainter(_captchaText),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Refresh Button
              IconButton(
                onPressed: () {
                  _generateCaptcha();
                  widget.onRefresh();
                },
                icon: const Icon(Icons.refresh),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Input Field
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter the code above',
              suffixIcon: _isCorrect == null
                  ? null
                  : Icon(
                _isCorrect! ? Icons.check_circle : Icons.cancel,
                color: _isCorrect! ? Colors.green : Colors.red,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              if (value.length == 6) {
                _verifyCaptcha();
              }
            },
          ),
        ],
      ),
    );
  }
}

class CaptchaPainter extends CustomPainter {
  final String text;

  CaptchaPainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();

    // Draw background noise lines
    final paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      paint.color = Colors.primaries[random.nextInt(Colors.primaries.length)]
          .withOpacity(0.3);
      final start = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final end = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      canvas.drawLine(start, end, paint);
    }

    // Draw text
    final textSpacing = size.width / text.length;
    for (int i = 0; i < text.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text[i],
          style: TextStyle(
            fontSize: 24 + random.nextInt(8).toDouble(),
            fontWeight: FontWeight.bold,
            color: Colors.primaries[random.nextInt(Colors.primaries.length)],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final xOffset = textSpacing * i + textSpacing / 2 - textPainter.width / 2;
      final yOffset =
          size.height / 2 -
              textPainter.height / 2 +
              (random.nextInt(10) - 5).toDouble();

      canvas.save();
      canvas.translate(
        xOffset + textPainter.width / 2,
        yOffset + textPainter.height / 2,
      );
      canvas.rotate((random.nextDouble() - 0.5) * 0.5);
      canvas.translate(
        -(xOffset + textPainter.width / 2),
        -(yOffset + textPainter.height / 2),
      );

      textPainter.paint(canvas, Offset(xOffset, yOffset));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CaptchaPainter oldDelegate) => oldDelegate.text != text;
}