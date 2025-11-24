/// Error handler for RevenueCat operations
class PurchaseErrorHandler {
  /// Get user-friendly error message
  static String getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('cancelled') || errorString.contains('user')) {
      return 'Purchase was cancelled';
    } else if (errorString.contains('invalid')) {
      return 'Invalid purchase. Please try again.';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your connection.';
    } else if (errorString.contains('unauthorized') ||
        errorString.contains('not authorized')) {
      return 'Unauthorized. Please try again.';
    } else if (errorString.contains('product')) {
      return 'Product not found or unavailable';
    } else if (errorString.contains('store')) {
      return 'Store error. Please try again later.';
    }

    return 'An error occurred. Please try again.';
  }

  /// Check if error is a user cancellation
  static bool isCancelledError(dynamic error) {
    return error.toString().toLowerCase().contains('cancelled');
  }

  /// Check if error is a network error
  static bool isNetworkError(dynamic error) {
    return error.toString().toLowerCase().contains('network') ||
        error.toString().toLowerCase().contains('connection');
  }

  /// Handle purchase errors and return appropriate message
  static String handlePurchaseError(dynamic error) {
    print('Purchase error: $error');

    if (isCancelledError(error)) {
      return 'Purchase cancelled by user';
    }

    if (isNetworkError(error)) {
      return 'Network error - please check your connection';
    }

    return getErrorMessage(error);
  }
}

/// Result wrapper for purchase operations
class PurchaseResult<T> {
  final bool success;
  final T? data;
  final String? error;

  PurchaseResult({
    required this.success,
    this.data,
    this.error,
  });

  factory PurchaseResult.success(T data) {
    return PurchaseResult(success: true, data: data);
  }

  factory PurchaseResult.failure(String error) {
    return PurchaseResult(success: false, error: error);
  }
}
