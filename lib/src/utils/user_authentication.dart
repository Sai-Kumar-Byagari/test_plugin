import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../screens/mpin_login_page.dart';

class UserAuthentication {
  static final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  static Future<String?> isLoggedIn(BuildContext context) async {
    String? token = await secureStorage.read(key: 'jwt_token');
    if (token == null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MPinLoginPage())
      );
    } else {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      int expirationTimestamp = decodedToken['exp'];

      DateTime expirationDate = DateTime.fromMillisecondsSinceEpoch(
          expirationTimestamp * 1000);

      bool isTokenAlive = expirationDate.isAfter(DateTime.now());
      if (isTokenAlive) {
        return token;
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MPinLoginPage())
        );
      }
    }
  }
}