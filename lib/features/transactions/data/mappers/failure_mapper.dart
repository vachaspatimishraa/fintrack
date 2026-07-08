import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/failure_model.dart';

class FailureMapper {
  static Failure fromException(Object exception) {
    if (exception is AuthException) {
      return Failure(
        code: 'AUTH_ERROR',
        message: exception.message,
        action: 'Please log in again.',
      );
    } else if (exception is PostgrestException) {
      return Failure(
        code: 'DATABASE_ERROR',
        message: exception.message,
        action: 'Database sync failure. Retrying in background.',
        isRetryAvailable: true,
      );
    } else if (exception is SocketException) {
      return const Failure(
        code: 'NETWORK_ERROR',
        message: 'No internet connection available.',
        action: 'Saved locally. Will sync automatically.',
        isRetryAvailable: true,
      );
    }
    return Failure(
      code: 'UNKNOWN_ERROR',
      message: exception.toString(),
      action: 'An unexpected error occurred.',
    );
  }
}
