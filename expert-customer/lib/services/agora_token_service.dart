import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class AgoraTokenService {
  static const String defaultAppId = 'c9afe369772c48659610c8b6368df693';
  static const String defaultAppCertificate = 'dbc1ada8600e4541b18e42cd8542eddc';

  static int _crc32(List<int> data) {
    int crc = 0xFFFFFFFF;
    for (final byte in data) {
      crc ^= byte;
      for (int j = 0; j < 8; j++) {
        if ((crc & 1) != 0) {
          crc = (crc >>> 1) ^ 0xEDB88320;
        } else {
          crc = crc >>> 1;
        }
      }
    }
    return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }

  /// Generates a valid Agora RTC Access Token (version 006)
  static String buildToken({
    required String channelName,
    int uid = 0,
    String appId = defaultAppId,
    String appCertificate = defaultAppCertificate,
    int expireSeconds = 86400,
  }) {
    if (appCertificate.isEmpty || appCertificate.contains('dummy')) {
      return '';
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expireTs = now + expireSeconds;
    final salt = Random().nextInt(0x0FFFFFFF);

    final messages = <int, int>{
      1: expireTs, // kJoinChannel
      2: expireTs, // kPublishAudioStream
      3: expireTs, // kPublishVideoStream
      4: expireTs, // kPublishDataStream
    };

    final mBuilder = BytesBuilder();
    // salt (uint32)
    final bdSalt = ByteData(4)..setUint32(0, salt & 0xFFFFFFFF, Endian.little);
    mBuilder.add(bdSalt.buffer.asUint8List());
    // expireTs (uint32) - NOTE: In official Agora AccessToken, this is privilege expire timestamp, NOT now!
    final bdTs = ByteData(4)..setUint32(0, expireTs & 0xFFFFFFFF, Endian.little);
    mBuilder.add(bdTs.buffer.asUint8List());
    // messages map
    final bdMsgCount = ByteData(2)..setUint16(0, messages.length & 0xFFFF, Endian.little);
    mBuilder.add(bdMsgCount.buffer.asUint8List());
    final sortedKeys = messages.keys.toList()..sort();
    for (final k in sortedKeys) {
      final bdK = ByteData(2)..setUint16(0, k & 0xFFFF, Endian.little);
      mBuilder.add(bdK.buffer.asUint8List());
      final bdV = ByteData(4)..setUint32(0, messages[k]! & 0xFFFFFFFF, Endian.little);
      mBuilder.add(bdV.buffer.asUint8List());
    }
    final m = mBuilder.toBytes();

    final appIdBytes = utf8.encode(appId);
    final channelBytes = utf8.encode(channelName);
    final uidBytes = uid == 0 ? <int>[] : utf8.encode(uid.toString());

    final toSign = <int>[
      ...appIdBytes,
      ...channelBytes,
      ...uidBytes,
      ...m,
    ];

    final key = utf8.encode(appCertificate);
    final hmac = Hmac(sha256, key);
    final signature = hmac.convert(toSign).bytes;

    final crcChannel = _crc32(channelBytes);
    final crcUid = _crc32(uidBytes);

    final contentBuilder = BytesBuilder();
    // signature (bytes with length prefix uint16)
    final bdSigLen = ByteData(2)..setUint16(0, signature.length & 0xFFFF, Endian.little);
    contentBuilder.add(bdSigLen.buffer.asUint8List());
    contentBuilder.add(signature);
    // crcChannel (uint32)
    final bdCrcC = ByteData(4)..setUint32(0, crcChannel & 0xFFFFFFFF, Endian.little);
    contentBuilder.add(bdCrcC.buffer.asUint8List());
    // crcUid (uint32)
    final bdCrcU = ByteData(4)..setUint32(0, crcUid & 0xFFFFFFFF, Endian.little);
    contentBuilder.add(bdCrcU.buffer.asUint8List());
    // m (raw message bytes with length prefix uint16)
    final bdMLen = ByteData(2)..setUint16(0, m.length & 0xFFFF, Endian.little);
    contentBuilder.add(bdMLen.buffer.asUint8List());
    contentBuilder.add(m);

    final content = contentBuilder.toBytes();
    return '006$appId${base64.encode(content)}';
  }
}
