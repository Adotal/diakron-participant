import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final _logger = Logger();

class QRDataGenerator {    

  //----------------------------------------------------
  // NO MORE NEEDED, DELETE WHEN THIS CODE IS NOT MORE USEFUL FOR OTHER IMPLEMENTATION

  static Uint8List _uuidToBytes(String uuid) {
    final hexString = uuid.replaceAll('-', '');
    return Uint8List.fromList(hex.decode(hexString));
  }
  static Future<String> generateSecureQRPayload({
    required String userId,
    required int couponId,
  }) async {
    final builder = BytesBuilder();

    // UUID de usuario (16 bytes)
    builder.add(_uuidToBytes(userId));

    // ID del cupón (2 bytes)
    final couponBuffer = ByteData(2)..setInt16(0, couponId);
    builder.add(couponBuffer.buffer.asUint8List());

    // Timestamp (3 bytes - Segundos del día)
    final now = DateTime.now();
    final seconds = now
        .difference(DateTime(now.year, now.month, now.day))
        .inSeconds;
    final tsBuffer = ByteData(4)..setInt32(0, seconds);
    builder.add(tsBuffer.buffer.asUint8List().sublist(1));

    // Nonce (8 bytes aleatorios)
    final randomBytes = Uint8List.fromList(
      List.generate(8, (_) => Random.secure().nextInt(256)),
    );
    builder.add(randomBytes);

    // PAYLOAD INICIAL: 29 Bytes
    final Uint8List initialPayload = builder.toBytes();

    _logger.d('''
    ID: ${_uuidToBytes(userId)}
    coupon: ${couponBuffer.buffer.asUint8List()}
    timestamp: ${tsBuffer.buffer.asUint8List().sublist(1)}
    nonce: $randomBytes
    ${initialPayload.toList()}

    ''');

    //  Enviar a Node.js para que firme
    const url = 'http://localhost:3000/sign-qr';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/octet-stream'},
      body: initialPayload,
    );

    if (response.statusCode == 200) {
      _logger.i('binary sent success');
      return _processSignatureResponse(response.body, initialPayload);
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

  static String _processSignatureResponse(
    String responseBody,
    Uint8List initialPayload,
  ) {
    // Extraer la firma en hexadecimal del JSON
    final jsonRes = jsonDecode(responseBody);
    final signatureHex = jsonRes['signature'];

    // Convertir de Hex a Bytes (64 Bytes)
    final signatureBytes = Uint8List.fromList(hex.decode(signatureHex));

    // Crear el Payload Final uniendo ambos arrays
    final finalBuilder = BytesBuilder();
    finalBuilder.add(initialPayload); // 29 bytes
    finalBuilder.add(signatureBytes); // 64 bytes

    // TOTAL: 93 Bytes
    final completePayloadBytes = finalBuilder.toBytes();

    // Convertir todo a Base64 para mostrar en el QrImageView
    return base64.encode(completePayloadBytes);
  }
}
