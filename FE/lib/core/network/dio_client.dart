import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 12),
    headers: const {'Accept': 'application/json'},
  ));
  dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
  return dio;
});
