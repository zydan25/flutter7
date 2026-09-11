import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_controller.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'reference_account_clean.dart';
import 'reference_store.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, this.onNavigateToTab});
  final void Function(int tabIndex)? onNavigateToTab;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _showBalance = true;
  String _activeCurrency = 'YER';
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      await context.read<AppController>().refreshAll();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  void _showTransferDialog() {
    final phoneCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('تحويل رصيد لمشترك آخر', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم هاتف المستلم',
                  hintText: '77XXXXXXX',
                  prefixIcon: Icon(Icons.phone_iphone_rounded),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'المبلغ (ريال يمني)',
                  hintText: '1000',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'ملاحظة (اختياري)',
                  hintText: 'سداد دفعة..',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: loading
                      ? null
                      : () async {
                          final phone = phoneCtrl.text.trim();
                          final amt = double.tryParse(amountCtrl.text.trim()) ?? 0;
                          if (phone.isEmpty || amt <= 0) {
                            showAppToast(context, 'يرجى إدخال رقم صحيح ومبلغ صالح', isError: true);
                            return;
                          }
                          setDialogState(() => loading = true);
                          try {
                            final app = context.read<AppController>();
                            await app.api.transfer(recipient: phone, amount: amt, note: noteCtrl.text.trim());
                            await app.refreshAll(quiet: true);
                            if (mounted) {
                              Navigator.pop(ctx);
                              showAppToast(context, 'تم التحويل بنجاح بقيمة $amt ر.ي', isSuccess: true);
                            }
                          } catch (e) {
                            setDialogState(() => loading = false);
                            if (mounted) showAppToast(context, 'فشل التحويل: $e', isError: true);
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1D3B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('تأكيد التحويل الفوري', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final user = app.user;
    final balance = app.balance;
    final orderCount = app.orders.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'حسابي والمحفظة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshing ? null : _refresh,
            icon: _refreshing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8B1D3B)))
                : const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
            tooltip: 'تحديث الحساب',
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserProfileEditScreen()),
            ),
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF64748B)),
            tooltip: 'تعديل الملف الشخصي',
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF8B1D3B),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Verified Account Header Card (Matching Screenshot 4)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(color: Color(0x060F172A), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  // Avatar with checkmark badge
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFFFF1F2),
                        child: Text(
                          user?.name.isNotEmpty == true ? user!.name[0] : 'م',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF8B1D3B),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF059669),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'الحساب الموثق: ${user?.name.isNotEmpty == true ? user!.name : "المستخدم"}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF059669)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'الهاتف: ${user?.phone.isNotEmpty == true ? user!.phone : "774952665"} • المحافظة: ${user?.governorate.isNotEmpty == true ? user!.governorate : "إب"}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Text(
                                '${user?.points ?? 0} نقطة ولاء',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'صلاحيات: ${user?.role == "agent" ? "وكيل معتمد" : "عميل ومشتري"}',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.shield_rounded, color: Color(0xFF059669), size: 12),
                        SizedBox(width: 4),
                        Text('معتمد', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Digital Wallet Card (Matching Screenshot 4)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                    Color(0xFF8B1D3B),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x228B1D3B), blurRadius: 16, offset: Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFFECDD3), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'البطاقة الرقمية والمحفظة',
                            style: TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => setState(() => _showBalance = !_showBalance),
                            icon: Icon(
                              _showBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.white70,
                              size: 18,
                            ),
                            tooltip: _showBalance ? 'إخفاء الرصيد' : 'إظهار الرصيد',
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: _refresh,
                            icon: const Icon(Icons.sync_rounded, color: Colors.white70, size: 18),
                            tooltip: 'تحديث الرصيد',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'الرصيد المتاح للعمليات',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _showBalance ? money(balance, 'ريال يمني') : '••••••••••',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'رقم العميل المعتمد: #${user?.id ?? 11}',
                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 10, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 12),

                  // Currency Switcher
                  Row(
                    children: [
                      _buildCurrencyPill('YER', 'يمني (نشط)'),
                      const SizedBox(width: 6),
                      _buildCurrencyPill('SAR', 'سعودي'),
                      const SizedBox(width: 6),
                      _buildCurrencyPill('USD', 'دولار \$'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 3. Electronic Services & Payments (The 3x3 Elegant Grid matching Screenshot 4)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'الخدمات والمدفوعات الإلكترونية',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'لوحة الوصول السريع',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.95,
              children: [
                // 1. شبكة السداد
                _buildGridItem(
                  title: 'شبكة السداد',
                  icon: Icons.bolt_rounded,
                  bg: const Color(0xFFFFF1F2),
                  border: const Color(0xFFFECDD3),
                  fg: const Color(0xFF8B1D3B),
                  onTap: () => widget.onNavigateToTab?.call(1),
                ),
                // 2. التقارير
                _buildGridItem(
                  title: 'التقارير',
                  icon: Icons.bar_chart_rounded,
                  bg: const Color(0xFFF0F9FF),
                  border: const Color(0xFFBAE6FD),
                  fg: const Color(0xFF0284C7),
                  onTap: () => widget.onNavigateToTab?.call(3),
                ),
                // 3. الخدمات
                _buildGridItem(
                  title: 'الخدمات',
                  icon: Icons.grid_view_rounded,
                  bg: const Color(0xFFFAF5FF),
                  border: const Color(0xFFE9D5FF),
                  fg: const Color(0xFF9333EA),
                  onTap: () => widget.onNavigateToTab?.call(1),
                ),
                // 4. كروت الشبكات
                _buildGridItem(
                  title: 'كروت الشبكات',
                  icon: Icons.wifi_rounded,
                  bg: const Color(0xFFECFDF5),
                  border: const Color(0xFFA7F3D0),
                  fg: const Color(0xFF059669),
                  onTap: () => _showWifiDialog(context),
                ),
                // 5. شحن الألعاب
                _buildGridItem(
                  title: 'شحن الألعاب',
                  icon: Icons.sports_esports_rounded,
                  bg: const Color(0xFFFFFBEB),
                  border: const Color(0xFFFDE68A),
                  fg: const Color(0xFFD97706),
                  onTap: () => _showGamesDialog(context),
                ),
                // 6. شحن البرامج
                _buildGridItem(
                  title: 'شحن البرامج',
                  icon: Icons.chat_bubble_outline_rounded,
                  bg: const Color(0xFFEEF2FF),
                  border: const Color(0xFFC7D2FE),
                  fg: const Color(0xFF4F46E5),
                  onTap: () => _showChatAppsDialog(context),
                ),
                // 7. دفتر العناوين
                _buildGridItem(
                  title: 'دفتر العناوين',
                  icon: Icons.location_on_outlined,
                  bg: const Color(0xFFFFF7ED),
                  border: const Color(0xFFFED7AA),
                  fg: const Color(0xFFEA580C),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddressesScreen()),
                  ),
                ),
                // 8. تحويل مالي
                _buildGridItem(
                  title: 'تحويل مالي',
                  icon: Icons.send_rounded,
                  bg: const Color(0xFFEFF6FF),
                  border: const Color(0xFFBFDBFE),
                  fg: const Color(0xFF2563EB),
                  onTap: _showTransferDialog,
                ),
                // 9. طلباتي (with dynamic order badge)
                _buildGridItem(
                  title: 'طلباتي ($orderCount)',
                  icon: Icons.shopping_bag_outlined,
                  bg: const Color(0xFFF0FDF4),
                  border: const Color(0xFFBBF7D0),
                  fg: const Color(0xFF16A34A),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersDetailView()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 4. Action Cards Row (Below the Grid)
            Row(
              children: [
                Expanded(
                  child: _buildWideActionCard(
                    title: 'تغذية الحساب',
                    subtitle: 'كشف الحساب والإيداع',
                    icon: Icons.account_balance_rounded,
                    color: const Color(0xFF8B1D3B),
                    onTap: () => _showDepositDialog(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildWideActionCard(
                    title: 'تحويل مالي',
                    subtitle: 'إرسال رصيد لمشترك',
                    icon: Icons.swap_horiz_rounded,
                    color: const Color(0xFF2563EB),
                    onTap: _showTransferDialog,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildWideActionCard(
                    title: 'طلباتي',
                    subtitle: '$orderCount طلبات مسجلة',
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFF059669),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersDetailView()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyPill(String code, String label) {
    final active = _activeCurrency == code;
    return InkWell(
      onTap: () => setState(() => _activeCurrency = code),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: active ? const Color(0xFF0F172A) : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required String title,
    required IconData icon,
    required Color bg,
    required Color border,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
          boxShadow: const [
            BoxShadow(color: Color(0x040F172A), blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Color(0x080F172A), blurRadius: 4, offset: Offset(0, 1)),
                ],
              ),
              child: Icon(icon, color: fg, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: fg,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 8.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showDepositDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('طرق تغذية المحفظة والحساب', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('يمكنك تغذية رصيدك عبر أحد الحسابات المعتمدة التالية:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            SizedBox(height: 10),
            Text('• بنك الكريمي (حساب رقم: 120000000)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('• بنك التضامن (حساب رقم: 25000000)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('• محفظة جوالي / كاش (رقم: 774952665)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('بعد الإيداع يتم التحديث فورياً عبر النظام المالي.', style: TextStyle(fontSize: 11, color: Color(0xFF059669))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  void _showWifiDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('شبكات الوايفاي المحلية', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('شراء كروت وبطاقات الوايفاي لشبكات إب وصنعاء والمحافظات فورياً وبأسعار الجملة.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onNavigateToTab?.call(1);
                },
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF059669)),
                child: const Text('الانتقال لشبكات الوايفاي'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGamesDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('شحن الألعاب والتطبيقات الإلكترونية', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('شحن شدات ببجي، جواهر فري فاير، بطاقات جوجل بلاي وآبل فورياً من رصيدك المتاح.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onNavigateToTab?.call(1);
                },
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
                child: const Text('شحن لعبة الآن'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatAppsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('شحن برامج البث والدردشة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('شحن نقاط وتطبيقات يلا لودو، بيجو لايف، وتطبيقات التواصل الاجتماعي الفورية.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onNavigateToTab?.call(1);
                },
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                child: const Text('شحن البرامج الآن'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
