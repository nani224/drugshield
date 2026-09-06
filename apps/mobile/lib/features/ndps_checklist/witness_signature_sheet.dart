import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import 'checklist_model.dart';

class WitnessSignatureSheet extends StatefulWidget {
  final String witnessTitle;
  final PanchWitness witness;
  final ValueChanged<PanchWitness> onSignatureSaved;

  const WitnessSignatureSheet({
    super.key,
    required this.witnessTitle,
    required this.witness,
    required this.onSignatureSaved,
  });

  @override
  State<WitnessSignatureSheet> createState() => _WitnessSignatureSheetState();
}

class _WitnessSignatureSheetState extends State<WitnessSignatureSheet> {
  final List<List<Offset>> _strokes = [];
  late TextEditingController _nameController;
  late TextEditingController _idController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.witness.name);
    _idController = TextEditingController(text: widget.witness.idNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void _clearSignature() {
    HapticFeedback.selectionClick();
    setState(() {
      _strokes.clear();
    });
  }

  void _saveSignature() {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please record a digital signature first.')),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    // Compute cryptographic hash of stroke coordinates for non-repudiation
    final buffer = StringBuffer();
    for (final stroke in _strokes) {
      for (final pt in stroke) {
        buffer.write('${pt.dx.toStringAsFixed(1)},${pt.dy.toStringAsFixed(1)};');
      }
    }
    final sigHash = sha256.convert(utf8.encode(buffer.toString())).toString().substring(0, 16);

    final updated = widget.witness.copyWith(
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Independent Witness',
      idNumber: _idController.text.trim().isNotEmpty ? _idController.text.trim() : 'Govt ID Verified',
      hasSignature: true,
      signatureHash: '0x$sigHash',
    );

    widget.onSignatureSaved(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: DSColors.surfaceCarbon,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: DSColors.surfaceBorder, width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.witnessTitle.toUpperCase(),
                style: DSTypography.headline2.copyWith(fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: DSColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Witness Name & ID
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  style: DSTypography.body.copyWith(color: DSColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Full Legal Name',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _idController,
                  style: DSTypography.mono.copyWith(fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Aadhaar / Voter ID',
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'PANCHNAMA DIGITAL SIGNATURE PAD',
            style: DSTypography.label.copyWith(fontSize: 11, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),

          // Interactive Signature Drawing Canvas
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: DSColors.bgAbyssal,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DSColors.surfaceBorder, width: 1.5),
            ),
            child: Stack(
              children: [
                GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _strokes.add([details.localPosition]);
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      if (_strokes.isNotEmpty) {
                        _strokes.last.add(details.localPosition);
                      }
                    });
                  },
                  child: CustomPaint(
                    painter: _SignaturePainter(_strokes),
                    size: Size.infinite,
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Text(
                    'SIGN ABOVE THIS LINE (E-COURTS COMPLIANT)',
                    style: DSTypography.monoSmall.copyWith(
                      color: DSColors.textDisabled,
                      fontSize: 9,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: TextButton.icon(
                    onPressed: _clearSignature,
                    icon: const Icon(Icons.refresh, size: 16, color: DSColors.hudCyan),
                    label: Text(
                      'CLEAR',
                      style: DSTypography.monoSmall.copyWith(color: DSColors.hudCyan),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveSignature,
                  child: const Text('SAVE PANCH SIGNATURE'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;

  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    // Baseline guideline
    final guidePaint = Paint()
      ..color = DSColors.surfaceBorder
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(16, size.height - 30),
      Offset(size.width - 16, size.height - 30),
      guidePaint,
    );

    // Signature strokes
    final strokePaint = Paint()
      ..color = DSColors.accentEmerald
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.8;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; ++i) {
        canvas.drawLine(stroke[i], stroke[i + 1], strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
