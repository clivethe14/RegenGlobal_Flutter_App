import 'purchase_service.dart';
import 'mock_purchases.dart';
// import 'rc_purchases.dart'; // later when you add RevenueCat

// Toggle with: flutter run --dart-define=USE_MOCK_PURCHASES=true/false
const useMockPurchases =
bool.fromEnvironment('USE_MOCK_PURCHASES', defaultValue: true);

PurchasesService getPurchasesService() {
  if (useMockPurchases) return MockPurchasesService();
  // return RevenueCatPurchasesService(); // (later)
  return MockPurchasesService();
}
