import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';

class QRDataGenerator {
  // Genera el payload hexadecimal completo para el QR
  static Future<String> generateQRPayload({
    required String userId,
    required int couponId,
    required SimpleKeyPair privateKey,
  }) async {
    // Convertir UUID a Hex (quitando guiones)
    final userIdHex = userId.replaceAll('-', '');

    // 2. ID del cupón (2 bytes -> 4 caracteres hex)
    final couponIdHex = couponId.toRadixString(16).padLeft(4, '0');

    // 3. Timestamp: Segundos desde que inició el día (3 bytes -> 6 caracteres hex)
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final secondsSinceStart = now.difference(startOfDay).inSeconds;
    final timestampHex = secondsSinceStart.toRadixString(16).padLeft(6, '0');

    // 4. Nonce: 8 bytes pseudoaleatorios -> 16 caracteres hex
    final random = Random.secure();
    final nonceBytes = Uint8List.fromList(
      List.generate(8, (_) => random.nextInt(256)),
    );
    final nonceHex = hex.encode(nonceBytes);

    // 5. Firma Digital (Ed25519)
    // Mensaje exacto: userId|couponId|timestamp|nonce
    final String message = '$userIdHex$couponIdHex$secondsSinceStart$nonceHex';

    final ed25519 = Ed25519();
    final signature = await ed25519.sign(
      utf8.encode(message),
      keyPair: privateKey,
    );

    // La firma Ed25519 es de 64 bytes -> 128 caracteres hex
    final signatureHex = hex.encode(signature.bytes);

    // 6. Concatenar todo para el QR
    // Total: 4 + 4 + 6 + 16 + 128 = 158 caracteres hexadecimales.
    // Esto entra perfectamente en un QR Versión 5 Nivel M.
    return '$userIdHex$couponIdHex$timestampHex$nonceHex$signatureHex'
        .toUpperCase();
  }
}
