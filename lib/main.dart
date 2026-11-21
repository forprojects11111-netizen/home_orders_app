import 'package:flutter/material.dart';

void main() {
  runApp(const HomeOrdersApp());
}

enum OrderStatus {
  newOrder('جديد', Color(0xFF1D4ED8)),
  preparing('قيد التجهيز', Color(0xFFD97706)),
  ready('جاهز للتوصيل', Color(0xFF059669)),
  completed('مكتمل', Color(0xFF4B5563));

  final String label;
  final Color color;
  const OrderStatus(this.label, this.color);
}

class OrderItem {
  final String id;
  final String customerName;
  final String district;
  final String productDetails;
  final double price;
  OrderStatus status;

  OrderItem({
    required this.id,
    required this.customerName,
    required this.district,
    required this.productDetails,
    required this.price,
    this.status = OrderStatus.newOrder,
  });
}

class HomeOrdersApp extends StatelessWidget {
  const HomeOrdersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'إدارة طلبات الأسر المنتجة',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: OrdersDashboardScreen(),
      ),
    );
  }
}

class OrdersDashboardScreen extends StatefulWidget {
  const OrdersDashboardScreen({super.key});

  @override
  State<OrdersDashboardScreen> createState() => _OrdersDashboardScreenState();
}

class _OrdersDashboardScreenState extends State<OrdersDashboardScreen> {
  OrderStatus? _selectedFilter;

  final List<OrderItem> _orders = [
    OrderItem(
      id: '101',
      customerName: 'أم سارة',
      district: 'حي الياسمين - الرياض',
      productDetails: 'صينية حلى قهوة + بوكس معجنات',
      price: 185,
      status: OrderStatus.preparing,
    ),
    OrderItem(
      id: '102',
      customerName: 'نورة العتيبي',
      district: 'حي الروضة - جدة',
      productDetails: 'معمول تمر فاخر (2 كيلو)',
      price: 140,
      status: OrderStatus.completed,
    ),
  ];

  List<OrderItem> get _filteredOrders {
    if (_selectedFilter == null) return _orders;
    return _orders.where((o) => o.status == _selectedFilter).toList();
  }

  double get _totalSales =>
      _filteredOrders.fold(0, (sum, order) => sum + order.price);

  void _openAddOrderDialog() {
    final nameController = TextEditingController();
    final districtController = TextEditingController();
    final detailsController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إضافة طلب جديد'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'اسم العميل'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'أدخلي اسم العميل' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: districtController,
                    decoration: const InputDecoration(labelText: 'الحي / المدينة'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'أدخلي الحي أو المدينة' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: detailsController,
                    decoration: const InputDecoration(labelText: 'تفاصيل الطلب'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'أدخلي تفاصيل الطلب' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'المبلغ (ريال سعودي)'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'أدخلي المبلغ';
                      if (double.tryParse(v.trim()) == null) return 'أدخلي رقماً صحيحاً';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _orders.insert(
                      0,
                      OrderItem(
                        id: '${101 + _orders.length}',
                        customerName: nameController.text.trim(),
                        district: districtController.text.trim(),
                        productDetails: detailsController.text.trim(),
                        price: double.parse(priceController.text.trim()),
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ الطلب'),
            ),
          ],
        ),
      ),
    );
  }

  void _cycleStatus(OrderItem order) {
    setState(() {
      final nextIndex = (order.status.index + 1) % OrderStatus.values.length;
      order.status = OrderStatus.values[nextIndex];
    });
  }

  void _deleteOrder(String id) {
    setState(() {
      _orders.removeWhere((o) => o.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleOrders = _filteredOrders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة طلبات الأسر المنتجة'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddOrderDialog,
        icon: const Icon(Icons.add),
        label: const Text('طلب جديد'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  color: const Color(0xFF1E3A8A),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('عدد الطلبات',
                                style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text('${visibleOrders.length}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('إجمالي المبيعات',
                                style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text('${_totalSales.toStringAsFixed(0)} ر.س',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('الكل'),
                        selected: _selectedFilter == null,
                        onSelected: (_) => setState(() => _selectedFilter = null),
                      ),
                      const SizedBox(width: 8),
                      ...OrderStatus.values.map(
                        (status) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChip(
                            label: Text(status.label),
                            selected: _selectedFilter == status,
                            onSelected: (_) => setState(() => _selectedFilter = status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: visibleOrders.isEmpty
                      ? const Center(child: Text('لا توجد طلبات مطابقة للتصفية'))
                      : ListView.builder(
                          itemCount: visibleOrders.length,
                          itemBuilder: (context, index) {
                            final order = visibleOrders[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                title: Text(
                                  '${order.customerName} • ${order.price.toStringAsFixed(0)} ر.س',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                      '${order.productDetails}\nالموقع: ${order.district}'),
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ActionChip(
                                      label: Text(
                                        order.status.label,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      backgroundColor: order.status.color,
                                      onPressed: () => _cycleStatus(order),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.redAccent),
                                      onPressed: () => _deleteOrder(order.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}