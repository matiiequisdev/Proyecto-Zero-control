import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardNotifier extends StateNotifier<int> {
  DashboardNotifier() : super(0);

  void setIndex(int index) => state = index;
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, int>((ref) {
  return DashboardNotifier();
});
