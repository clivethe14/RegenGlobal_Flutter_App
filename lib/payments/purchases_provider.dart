import 'purchase_service.dart';
import 'mock_purchases.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Toggle with: flutter run --dart-define=USE_MOCK_PURCHASES=true/false
const useMockPurchases =
    bool.fromEnvironment('USE_MOCK_PURCHASES', defaultValue: true);

/// Provides the app's `PurchaseService` implementation.
/// In debug (or when `USE_MOCK_PURCHASES=true`) we return the in-repo mock
/// implementation. In release builds we return the real RevenueCat adapter.
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  if (useMockPurchases || kDebugMode) {
    return MockPurchaseService();
  }
  return RevenueCatPurchaseService();
});
