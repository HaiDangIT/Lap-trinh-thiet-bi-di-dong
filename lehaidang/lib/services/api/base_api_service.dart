import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

/// Base API Service
/// Lớp cơ sở cho tất cả các API services
abstract class BaseApiService {
  final String baseUrl = ApiConfig.baseUrl;

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final response = await http
          .get(uri, headers: headers ?? ApiConfig.defaultHeaders)
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http
          .post(
            uri,
            headers: headers ?? ApiConfig.defaultHeaders,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiConfig.sendTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http
          .put(
            uri,
            headers: headers ?? ApiConfig.defaultHeaders,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiConfig.sendTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http
          .delete(uri, headers: headers ?? ApiConfig.defaultHeaders)
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Build URI with query parameters
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final url = baseUrl + endpoint;
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return Uri.parse(url).replace(queryParameters: queryParameters);
    }
    return Uri.parse(url);
  }

  /// Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) {
          return {'success': true};
        }
        return json.decode(response.body);
      case 204:
        return {'success': true};
      case 400:
        throw BadRequestException(_getErrorMessage(response));
      case 401:
        throw UnauthorizedException(_getErrorMessage(response));
      case 403:
        throw ForbiddenException(_getErrorMessage(response));
      case 404:
        throw NotFoundException(_getErrorMessage(response));
      case 500:
      default:
        throw ServerException(_getErrorMessage(response));
    }
  }

  /// Extract error message from response
  String _getErrorMessage(http.Response response) {
    try {
      final body = json.decode(response.body);
      return body['message'] ?? body['error'] ?? ErrorMessages.unknown;
    } catch (e) {
      return ErrorMessages.unknown;
    }
  }

  /// Handle errors
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException')) {
      return NetworkException(ErrorMessages.networkError);
    }
    if (error.toString().contains('TimeoutException')) {
      return TimeoutException('Request timeout');
    }
    return UnknownException(error.toString());
  }
}

/// API Exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message, 400);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, 403);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, 404);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message, 500);
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class TimeoutException extends ApiException {
  TimeoutException(super.message);
}

class UnknownException extends ApiException {
  UnknownException(super.message);
}
