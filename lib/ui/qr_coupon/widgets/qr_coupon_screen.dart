import 'package:diakron_participant/ui/core/ui/custom_screen.dart';
import 'package:diakron_participant/ui/qr_coupon/qr_data_gen.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cryptography/cryptography.dart';

class QRCouponScreen extends StatefulWidget {
  final String userId;
  final int couponId;

  const QRCouponScreen({
    super.key,
    required this.userId,
    required this.couponId,
  });

  @override
  State<QRCouponScreen> createState() => _QRCouponScreenState();
}

class _QRCouponScreenState extends State<QRCouponScreen> {
  String? _qrData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateData();
  }

  Future<void> _generateData() async {
    // ATENCIÓN: En producción, la clave privada no debe generarse al vuelo ni
    // almacenarse en texto plano. Debería venir de un SecureStorage.
    final ed25519 = Ed25519();
    final keyPair = await ed25519.newKeyPair();

    final payload = await QRDataGenerator.generateQRPayload(
      userId: widget.userId,
      couponId: widget.couponId,
      privateKey: keyPair,
    );

    setState(() {
      _qrData = payload;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScreen(
      title: 'QR',
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Buscamos la dimensión más pequeña (ancho o alto) para mantener el QR cuadrado
            final double size = constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth * 0.9 // 90% del ancho
                : constraints.maxHeight * 0.7; // 70% del alto (para dejar espacio al texto)

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImageView(
                  data: _qrData!,
                  version: QrVersions.auto,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                  size: size,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Escanea este código",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
