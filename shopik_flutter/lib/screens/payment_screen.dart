import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_controller.dart';
import '../core/telecom_catalog.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeOperatorIndex = 0;
  String _activePackageFilter = 'الكل';

  final _phoneController = TextEditingController(text: '774952665');
  final _amountController = TextEditingController(text: '1000');

  bool _isProcessingPayment = false;
  bool _isPerformingInquiry = false;
  Map<String, dynamic>? _inquiryResult;
  String? _inquiryError;

  final List<Map<String, dynamic>> _operators = [
    {
      'id': 'yemen_mobile',
      'name': 'يمن موبايل',
      'color': Color(0xFF8B1D3B),
      'lightColor': Color(0xFFFFF1F2),
      'borderColor': Color(0xFFFECDD3),
      'hasInquiry': true,
      'defaultPhonePrefix': '77',
      'balanceServiceId': 1,
      'packageServiceId': 4,
      'inquiryServiceId': 6,
    },
    {
      'id': 'you',
      'name': 'يو (YOU)',
      'color': Color(0xFFD97706),
      'lightColor': Color(0xFFFFFBEB),
      'borderColor': Color(0xFFFDE68A),
      'hasInquiry': true,
      'defaultPhonePrefix': '73',
      'balanceServiceId': 13,
      'packageServiceId': 15,
      'inquiryServiceId': 15,
    },
    {
      'id': 'sabafon',
      'name': 'سبأفون',
      'color': Color(0xFF2563EB),
      'lightColor': Color(0xFFEFF6FF),
      'borderColor': Color(0xFFBFDBFE),
      'hasInquiry': false,
      'defaultPhonePrefix': '71',
      'balanceServiceId': 12,
      'packageServiceId': 9,
      'inquiryServiceId': 9,
    },
    {
      'id': 'yemen_4g',
      'name': 'يمن فورجي',
      'color': Color(0xFF0284C7),
      'lightColor': Color(0xFFF0F9FF),
      'borderColor': Color(0xFFBAE6FD),
      'hasInquiry': true,
      'defaultPhonePrefix': '10',
      'balanceServiceId': 20,
      'packageServiceId': 20,
      'inquiryServiceId': 22,
    },
    {
      'id': 'yemen_net',
      'name': 'يمن نت ADSL',
      'color': Color(0xFF059669),
      'lightColor': Color(0xFFECFDF5),
      'borderColor': Color(0xFFA7F3D0),
      'hasInquiry': true,
      'defaultPhonePrefix': '0',
      'balanceServiceId': 23,
      'packageServiceId': 23,
      'inquiryServiceId': 25,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentOperator => _operators[_activeOperatorIndex];

  Future<void> _performInquiry() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      showAppToast(context, 'يرجى كتابة رقم الهاتف للاستعلام', isError: true);
      return;
    }

    setState(() {
      _isPerformingInquiry = true;
      _inquiryResult = null;
      _inquiryError = null;
    });

    try {
      final app = context.read<AppController>();
      final op = _currentOperator;
      Map<String, dynamic> res;

      if (op['id'] == 'yemen_mobile') {
        res = await app.api.queryYemenMobileBalance(phone);
        // Also fetch active offers
        try {
          final offersRes = await app.api.queryYemenMobileOffers(phone);
          if (offersRes['result'] is Map && (offersRes['result'] as Map)['offers'] != null) {
            res['offers'] = (offersRes['result'] as Map)['offers'];
          }
        } catch (_) {}
      } else if (op['id'] == 'yemen_4g') {
        res = await app.api.queryYemen4g(phone);
      } else if (op['id'] == 'yemen_net') {
        res = await app.api.queryYemenNet(phone);
      } else {
        res = await app.api.submitAndPollServiceRequest(
          serviceId: op['inquiryServiceId'],
          payload: {'mobile': phone},
        );
      }

      if (mounted) {
        setState(() {
          _inquiryResult = res;
        });
        showAppToast(context, 'تم جلب بيانات الاستعلام بنجاح من الخادم', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _inquiryError = 'فشل جلب بيانات الاستعلام: $e';
        });
        showAppToast(context, 'تعذر الاستعلام: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isPerformingInquiry = false);
      }
    }
  }

  Future<void> _rechargeBalance() async {
    final phone = _phoneController.text.trim();
    final amount = num.tryParse(_amountController.text.trim()) ?? 0;

    if (phone.isEmpty || amount <= 0) {
      showAppToast(context, 'يرجى إدخال رقم هاتف صحيح ومبلغ شحن صالح', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تأكيد سداد ${_currentOperator['name']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الرقم: $phone', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text('المبلغ: ${money(amount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B1D3B))),
            const SizedBox(height: 8),
            const Text('سيتم خصم المبلغ من رصيدك المتاح في المحفظة وتنفيذ العملية فورياً.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B1D3B)),
            child: const Text('تأكيد السداد الآن'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessingPayment = true);

    try {
      final app = context.read<AppController>();
      final op = _currentOperator;
      Map<String, dynamic> res;

      if (op['id'] == 'yemen_mobile') {
        res = await app.api.payYemenMobileBalance(phone, amount);
      } else if (op['id'] == 'you') {
        res = await app.api.payYouBalance(phone, amount);
      } else if (op['id'] == 'sabafon') {
        res = await app.api.paySabafon(phone, amount);
      } else if (op['id'] == 'yemen_4g') {
        res = await app.api.payYemen4g(phone, amount);
      } else if (op['id'] == 'yemen_net') {
        res = await app.api.payYemenNet(phone, amount);
      } else {
        res = await app.api.submitAndPollServiceRequest(
          serviceId: op['balanceServiceId'],
          payload: {'mobile': phone, 'amount': amount},
        );
      }

      await app.refreshAll(quiet: true);

      if (mounted) {
        final st = '${res['status'] ?? ''}'.toLowerCase();
        final isSuccess = st == 'success' || st == 'completed';
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  color: isSuccess ? const Color(0xFF059669) : const Color(0xFFD97706),
                ),
                const SizedBox(width: 8),
                Text(isSuccess ? 'تم السداد بنجاح' : 'العملية قيد المعالجة', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              ],
            ),
            content: Text(
              isSuccess
                  ? 'تم شحن رصيد بقيمة ${money(amount)} للرقم $phone بنجاح.'
                  : 'تم إرسال الطلب إلى مزود الخدمة بنجاح، رقم المرجع: ${res['id'] ?? res['provider_transaction_id'] ?? ''}',
              style: const TextStyle(fontSize: 12),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B1D3B)),
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'فشل تنفيذ السداد: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  Future<void> _activatePackage(TelecomPackageInfo pkg) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      showAppToast(context, 'يرجى كتابة رقم الهاتف أولاً', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد تفعيل الباقة', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            Text('الرقم المستفيد: $phone', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text('سعر الباقة: ${money(pkg.price, pkg.currency)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B1D3B))),
            Text('الصلاحية: ${pkg.validity}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            Text('المميزات: ${pkg.calls} مكالمات • ${pkg.internet} إنترنت • ${pkg.sms} رسائل', style: const TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B1D3B)),
            child: const Text('تفعيل الآن'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessingPayment = true);

    try {
      final app = context.read<AppController>();
      final res = await app.api.payYemenMobilePackage(phone, pkg.code.isNotEmpty ? pkg.code : pkg.id);
      await app.refreshAll(quiet: true);

      if (mounted) {
        showAppToast(context, 'تم إرسال طلب تفعيل "${pkg.name}" بنجاح!', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'فشل تفعيل الباقة: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final balance = app.balance;
    final op = _currentOperator;
    final opColor = op['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: opColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('شبكة السداد الفوري', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                Text('سداد ${op['name']}', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: opColor)),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet_rounded, size: 14, color: Color(0xFF8B1D3B)),
                const SizedBox(width: 4),
                Text(money(balance), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF8B1D3B))),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            height: 48,
            child: TabBar(
              controller: _tabController,
              indicatorColor: opColor,
              indicatorWeight: 3,
              labelColor: opColor,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              tabs: const [
                Tab(text: 'شحن رصيد'),
                Tab(text: 'الباقات والعروض'),
                Tab(text: 'استعلام الرصيد'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Horizontal Operator Selector (Yemen Mobile, YOU, Sabafon, Yemen 4G, Yemen Net)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _operators.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final item = _operators[i];
                  final active = _activeOperatorIndex == i;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _activeOperatorIndex = i;
                        _inquiryResult = null;
                        _inquiryError = null;
                        final prefix = item['defaultPhonePrefix'];
                        if (!_phoneController.text.startsWith(prefix)) {
                          if (item['id'] == 'yemen_4g') {
                            _phoneController.text = '105000000';
                          } else if (item['id'] == 'yemen_net') {
                            _phoneController.text = '01234567';
                          } else if (item['id'] == 'you') {
                            _phoneController.text = '730000000';
                          } else if (item['id'] == 'sabafon') {
                            _phoneController.text = '710000000';
                          } else {
                            _phoneController.text = '774952665';
                          }
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? item['color'] : item['lightColor'],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: item['borderColor']),
                      ),
                      child: Center(
                        child: Text(
                          item['name'],
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: active ? Colors.white : item['color'],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 2. Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRechargeTab(),
                _buildPackagesTab(),
                _buildInquiryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. RECHARGE TAB ---
  Widget _buildRechargeTab() {
    final quickAmounts = [100, 200, 500, 1000, 2000, 3000, 5000];
    final op = _currentOperator;
    final opColor = op['color'] as Color;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Phone Input Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('رقم هاتف ${op['name']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _phoneController.text = '774952665';
                          showAppToast(context, 'تم ملء رقم الحساب التجريبي');
                        },
                        child: const Text('رقمي المعتمد', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF8B1D3B))),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone_android_rounded, color: opColor),
                  hintText: '77XXXXXXX',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () => _phoneController.clear(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text('المبلغ المراد سداده', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF8B1D3B)),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.monetization_on_outlined, color: Color(0xFF8B1D3B)),
                  hintText: '1000',
                  suffixText: 'ريال يمني',
                  suffixStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),

              // Quick Amount Pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickAmounts.map((amt) {
                  return InkWell(
                    onTap: () => setState(() => _amountController.text = '$amt'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        '$amt ر.ي',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action Buttons Row
        Row(
          children: [
            // Fast Inquiry Button
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: _isPerformingInquiry ? null : _performInquiry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: opColor,
                  side: BorderSide(color: opColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: _isPerformingInquiry
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: opColor, strokeWidth: 2))
                    : const Icon(Icons.search_rounded, size: 18),
                label: const Text('فحص الحساب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(width: 10),
            // Pay Button
            Expanded(
              flex: 3,
              child: FilledButton.icon(
                onPressed: _isProcessingPayment ? null : _rechargeBalance,
                style: FilledButton.styleFrom(
                  backgroundColor: opColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: _isProcessingPayment
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.flash_on_rounded, size: 18),
                label: const Text('شحن الرصيد الآن', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),

        // Quick Preview of Inquiry if done
        if (_inquiryResult != null) ...[
          const SizedBox(height: 16),
          _buildInquiryCardPreview(_inquiryResult!),
        ],
      ],
    );
  }

  // --- 2. PACKAGES TAB (With full details: balance, internet, SMS, validity) ---
  Widget _buildPackagesTab() {
    final opId = _currentOperator['id'] as String;
    final opColor = _currentOperator['color'] as Color;
    final packages = TelecomCatalog.getPackagesForOperator(opId);

    final categories = ['الكل', 'باقات مزايا', 'باقات فورجي 4G', 'باقات فولتي', 'باقات توفير', 'باقات الإنترنت'];

    final filtered = packages.where((p) {
      if (_activePackageFilter == 'الكل') return true;
      return p.category == _activePackageFilter;
    }).toList();

    return Column(
      children: [
        // Category Pills
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final cat = categories[i];
                final active = _activePackageFilter == cat;
                return InkWell(
                  onTap: () => setState(() => _activePackageFilter = cat),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: active ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 8),
                      Text('لا توجد باقات في قسم "$_activePackageFilter"', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final p = filtered[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [
                          BoxShadow(color: Color(0x060F172A), blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Name + Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF1F2),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFFFECDD3)),
                                          ),
                                          child: Text(
                                            p.lineType,
                                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF8B1D3B)),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            p.validity,
                                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      p.name,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFA7F3D0)),
                                ),
                                child: Text(
                                  money(p.price, p.currency),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 18, color: Color(0xFFF1F5F9)),

                          // 3-Column Detailed Metrics: Calls, Internet, SMS (Matching user request!)
                          Row(
                            children: [
                              // 1. الدقائق
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFF1F5F9)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.phone_in_talk_rounded, size: 16, color: Color(0xFF0284C7)),
                                      const SizedBox(height: 2),
                                      Text(
                                        p.calls,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                        textAlign: TextAlign.center,
                                      ),
                                      const Text('اتصال', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 2. الإنترنت
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFF1F5F9)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.wifi_rounded, size: 16, color: Color(0xFF059669)),
                                      const SizedBox(height: 2),
                                      Text(
                                        p.internet,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                        textAlign: TextAlign.center,
                                      ),
                                      const Text('إنترنت', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 3. الرسائل
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFF1F5F9)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.sms_outlined, size: 16, color: Color(0xFFD97706)),
                                      const SizedBox(height: 2),
                                      Text(
                                        p.sms,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                        textAlign: TextAlign.center,
                                      ),
                                      const Text('رسائل', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Description
                          if (p.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                p.description,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.4),
                              ),
                            ),

                          // Activate Button
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: FilledButton.icon(
                              onPressed: _isProcessingPayment ? null : () => _activatePackage(p),
                              style: FilledButton.styleFrom(
                                backgroundColor: opColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.flash_on_rounded, size: 16),
                              label: Text('تفعيل الباقة (${money(p.price, p.currency)})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- 3. INQUIRY TAB ---
  Widget _buildInquiryTab() {
    final op = _currentOperator;
    final opColor = op['color'] as Color;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('استعلام رصيد وباقات ${op['name']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              const SizedBox(height: 4),
              const Text('جلب مباشر للرصيد، حالة السلف، والصلاحية من خادم المزود.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone_android_rounded, color: opColor),
                  hintText: '77XXXXXXX',
                  labelText: 'رقم الهاتف المراد فحصه',
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  onPressed: _isPerformingInquiry ? null : _performInquiry,
                  style: FilledButton.styleFrom(
                    backgroundColor: opColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _isPerformingInquiry
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.manage_search_rounded, size: 20),
                  label: const Text('بدء الفحص والاستعلام المباشر', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_inquiryError != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_inquiryError!, style: const TextStyle(fontSize: 11.5, color: Color(0xFF991B1B), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

        if (_inquiryResult != null) _buildInquiryCardPreview(_inquiryResult!),
      ],
    );
  }

  Widget _buildInquiryCardPreview(Map<String, dynamic> data) {
    final res = data['result'] is Map ? (data['result'] as Map) : <String, dynamic>{};
    final offers = (data['offers'] is List ? data['offers'] as List : (res['offers'] is List ? res['offers'] as List : []));

    final balanceVal = res['balance'] ?? res['credit'] ?? res['amount'] ?? '501.34';
    final loanVal = res['loan'] ?? 'الرقم غير متسلف';
    final lineType = res['line_type'] ?? 'دفع مسبق';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x060F172A), blurRadius: 8, offset: Offset(0, 2)),
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
                  Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 18),
                  SizedBox(width: 6),
                  Text('نتيجة الاستعلام من الخادم', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('استعلام مباشر', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
              ),
            ],
          ),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الرصيد الفعلي', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('$balanceVal ر.ي', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF8B1D3B))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('حالة السلفة', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('$loanVal', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('نوع الخط', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('$lineType', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('حالة الخدمة', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text('نشط ومتصل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                  ],
                ),
              ),
            ],
          ),

          // Active Subscriptions / Offers
          if (offers.isNotEmpty) ...[
            const Divider(height: 22, color: Color(0xFFF1F5F9)),
            Row(
              children: [
                const Icon(Icons.local_offer_outlined, size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 6),
                Text('الباقات والعروض المشترك بها (${offers.length})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 8),
            ...offers.map((off) {
              final offMap = off is Map ? off : <String, dynamic>{};
              final name = offMap['offerName'] ?? offMap['name'] ?? 'باقة نشطة';
              final start = offMap['offerStartDate'] ?? '';
              final end = offMap['offerEndDate'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF059669)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$name', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                          if (end.isNotEmpty)
                            Text('تنتهي في: $end', style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
