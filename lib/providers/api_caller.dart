import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/config.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = Config.apiUrl;

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    final trace = FirebasePerformance.instance.newTrace('post_request');
    await trace.start();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    final idToken = await user.getIdToken();
    final url = '$baseUrl/$path';
    AppLogger.info("Hitting $url in POST request");

    final response = await _dio.post(
      url,
      options: Options(
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      ),
      data: data,
    );

    // FIX: Wrap stop in try-catch to prevent web crashes
    try {
      await trace.stop();
    } catch (e) {
      // trace.stop() often fails on Flutter Web with a SyntaxError/Performance mark error.
      // We swallow this error so the actual app flow continues.
    }

    return response;
  }

  Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    final trace = FirebasePerformance.instance.newTrace('put_request');
    await trace.start();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    final idToken = await user.getIdToken();
    final url = '$baseUrl/$path';
    AppLogger.info("Hitting $url in PUT request");

    final response = await _dio.put(
      url,
      options: Options(
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      ),
      data: data,
    );

    // FIX: Wrap stop in try-catch to prevent web crashes
    try {
      await trace.stop();
    } catch (e) {
      // Swallow error
    }

    return response;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final trace = FirebasePerformance.instance.newTrace('get_request');
    await trace.start();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    final idToken = await user.getIdToken();
    final url = '$baseUrl/$path';
    AppLogger.info("Hitting $url in GET request");

    final response = await _dio.get(
      url,
      options: Options(
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      ),
      queryParameters: queryParameters,
    );

    // FIX: Wrap stop in try-catch to prevent web crashes
    try {
      await trace.stop();
    } catch (e) {
      // Swallow error
    }

    return response;
  }
}
