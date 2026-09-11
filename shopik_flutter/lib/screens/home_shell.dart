import 'package:flutter/material.dart';
import 'account_screen.dart';
import 'payment_screen.dart';
import 'reference_store.dart';
import 'operations_screen.dart';
import 'statement_screen.dart';
import 'reports_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 1;

  void _navigateToTab(int index) {
    if (mounted && index >= 0 && index < 6) setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const StoreView(),
      AccountScreen(onNavigateToTab: _navigateToTab),
      const PaymentScreen(),
      OperationsScreen(onBack: () => setState(() => _currentIndex = 1)),
      StatementScreen(onBack: () => setState(() => _currentIndex = 1)),
      ReportsScreen(onBack: () => setState(() => _currentIndex = 1), onNavigateTab: _navigateToTab),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
          boxShadow: [BoxShadow(color: Color(0x0A0F172A), blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                _buildNavItem(index: 0, label: 'المتجر', icon: Icons.storefront_outlined, activeIcon: Icons.storefront_rounded),
                _buildNavItem(index: 1, label: 'حسابي', icon: Icons.home_outlined, activeIcon: Icons.home_rounded),
                _buildNavItem(index: 2, label: 'السداد', icon: Icons.credit_card_outlined, activeIcon: Icons.credit_card_rounded),
                _buildNavItem(index: 3, label: 'العمليات', icon: Icons.history_rounded, activeIcon: Icons.history_rounded),
                _buildNavItem(index: 4, label: 'كشف حساب', icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded),
                _buildNavItem(index: 5, label: 'التقارير', icon: Icons.bar_chart_rounded, activeIcon: Icons.bar_chart_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required int index, required String label, required IconData icon, required IconData activeIcon}) {
    final isSelected = _currentIndex == index;
    const activeColor = Color(0xFF8B1D3B);
    const inactiveColor = Color(0xFF64748B);
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(height: 3, width: double.infinity, color: isSelected ? activeColor : Colors.transparent),
            const Spacer(),
            Icon(isSelected ? activeIcon : icon, size: 22, color: isSelected ? activeColor : inactiveColor),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold, color: isSelected ? activeColor : inactiveColor), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
