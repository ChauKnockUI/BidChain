import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/signers/ecdsa_signer.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/api.dart';

/// EIP-712 Bid Signer for blockchain transparency
/// Signs bid data according to EIP-712 standard
class BidSigner {
  static const String DOMAIN_NAME = 'BidChain';
  static const String DOMAIN_VERSION = '1.0';
  static const int CHAIN_ID = 1337; // Ganache local chain

  /// Keccak256 hash function
  static Uint8List keccak256(Uint8List data) {
    // Note: Dart doesn't have native keccak256, using SHA256 as placeholder
    // In production, use proper keccak256 implementation
    final digest = SHA256Digest();
    return digest.process(data);
  }

  /// Encode string to bytes32
  static Uint8List stringToBytes32(String str) {
    final bytes = utf8.encode(str);
    final hash = keccak256(Uint8List.fromList(bytes));
    return hash;
  }

  /// Encode uint256
  static Uint8List uint256ToBytes(BigInt value) {
    final hex = value.toRadixString(16).padLeft(64, '0');
    return Uint8List.fromList(hexDecode(hex));
  }

  /// Encode address
  static Uint8List addressToBytes(String address) {
    // Remove 0x prefix if present
    final cleanAddress = address.startsWith('0x')
        ? address.substring(2)
        : address;
    final padded = cleanAddress.padLeft(64, '0');
    return Uint8List.fromList(hexDecode(padded));
  }

  /// Concatenate byte arrays
  static Uint8List concat(List<Uint8List> arrays) {
    int totalLength = arrays.fold(0, (sum, arr) => sum + arr.length);
    final result = Uint8List(totalLength);
    int offset = 0;
    for (var arr in arrays) {
      result.setRange(offset, offset + arr.length, arr);
      offset += arr.length;
    }
    return result;
  }

  /// Hex decode helper
  static List<int> hexDecode(String hexString) {
    return hex.decode(hexString);
  }

  /// Sign bid with EIP-712
  static Future<String> signBid({
    required String auctionId,
    required BigInt amountWei,
    required int nonce,
    required int timestamp,
    required String privateKeyHex,
    required String contractAddress,
  }) async {
    try {
      // 1. Build EIP-712 Domain Separator
      final domainTypeHash = stringToBytes32(
        'EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)',
      );
      final nameHash = stringToBytes32(DOMAIN_NAME);
      final versionHash = stringToBytes32(DOMAIN_VERSION);
      final chainIdBytes = uint256ToBytes(BigInt.from(CHAIN_ID));
      final contractBytes = addressToBytes(contractAddress);

      final domainSeparator = keccak256(
        concat([
          domainTypeHash,
          nameHash,
          versionHash,
          chainIdBytes,
          contractBytes,
        ]),
      );

      // 2. Build Bid Struct Hash
      final bidTypeHash = stringToBytes32(
        'Bid(string auctionId,uint256 amount,uint256 nonce,uint256 timestamp)',
      );
      final auctionIdHash = stringToBytes32(auctionId);
      final amountBytes = uint256ToBytes(amountWei);
      final nonceBytes = uint256ToBytes(BigInt.from(nonce));
      final timestampBytes = uint256ToBytes(BigInt.from(timestamp));

      final structHash = keccak256(
        concat([
          bidTypeHash,
          auctionIdHash,
          amountBytes,
          nonceBytes,
          timestampBytes,
        ]),
      );

      // 3. Build final digest: keccak256("\x19\x01" + domainSeparator + structHash)
      final prefix = Uint8List.fromList([0x19, 0x01]);
      final digest = keccak256(concat([prefix, domainSeparator, structHash]));

      // 4. Sign with private key
      final signature = _signDigest(digest, privateKeyHex);

      return signature;
    } catch (e) {
      print('Error signing bid: $e');
      rethrow;
    }
  }

  /// Sign digest with ECDSA secp256k1
  static String _signDigest(Uint8List digest, String privateKeyHex) {
    try {
      // Remove 0x prefix if present
      final cleanKey = privateKeyHex.startsWith('0x')
          ? privateKeyHex.substring(2)
          : privateKeyHex;

      // Parse private key
      final privateKeyInt = BigInt.parse(cleanKey, radix: 16);
      final params = ECCurve_secp256k1();
      final privateKey = ECPrivateKey(privateKeyInt, params);

      // Sign
      final signer = ECDSASigner(null, HMac(SHA256Digest(), 64));
      final keyParam = PrivateKeyParameter<ECPrivateKey>(privateKey);
      signer.init(true, keyParam);

      final sig = signer.generateSignature(digest) as ECSignature;

      // Encode signature as hex (r + s + v format)
      final r = sig.r.toRadixString(16).padLeft(64, '0');
      final s = sig.s.toRadixString(16).padLeft(64, '0');
      final v = '1b'; // Recovery ID (27 in hex)

      return '0x$r$s$v';
    } catch (e) {
      print('Error in _signDigest: $e');
      rethrow;
    }
  }

  /// Get user's nonce from backend
  static Future<int> getUserNonce(String userId) async {
    // TODO: Implement API call to get user's current nonce
    // For now, return timestamp-based nonce
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// Get current Unix timestamp
  static int getCurrentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
}
