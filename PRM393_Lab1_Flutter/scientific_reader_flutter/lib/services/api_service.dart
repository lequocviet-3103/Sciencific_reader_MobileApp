import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  ApiService()
    : dio = Dio(
        BaseOptions(
          baseUrl: _resolveBaseUrl(),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

  final Dio dio;

  static String _resolveBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:8000";
    }

    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    }

    return "http://localhost:8000";
  }
}
