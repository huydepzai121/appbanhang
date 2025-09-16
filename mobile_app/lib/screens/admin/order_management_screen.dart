import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'create_order_screen.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  String _selectedStatus = 'all';
  bool _isLoading = false;
  List<Map<String, dynamic>> _orders = [];

  final List<Map<String, dynamic>> _statusOptions = [
    {'value': 'all', 'label': 'Tất cả', 'color': Colors.grey},
    {'value': 'pending', 'label': 'Chờ xử lý', 'color': Colors.orange},
    {'value': 'confirmed', 'label': 'Đã xác nhận', 'color': Colors.blue},
    {'value': 'shipping', 'label': 'Đang giao', 'color': Colors.purple},
    {'value': 'delivered', 'label': 'Đã giao', 'color': Colors.green},
    {'value': 'cancelled', 'label': 'Đã hủy', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        throw Exception('Không có quyền truy cập');
      }

      // Load orders from API
      final ordersData = await ApiService.getAllOrders(token);

      setState(() {
        _orders = ordersData.map<Map<String, dynamic>>((order) {
          return {
            'id': order['id'],
            'orderNumber': order['order_number'],
            'customerName': order['customer_name'] ?? order['shipping_name'],
            'customerPhone': order['customer_phone'] ?? order['shipping_phone'],
            'total': (order['total_amount'] ?? order['final_amount']).toDouble(),
            'status': order['status'],
            'createdAt': DateTime.parse(order['created_at']),
            'items': [], // Will be loaded separately if needed
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _orders = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải đơn hàng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedStatus == 'all') {
      return _orders;
    }
    return _orders.where((order) => order['status'] == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Status filter and create button
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lọc theo trạng thái',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateOrderScreen(),
                          ),
                        ).then((_) {
                          // Refresh orders after creating
                          _loadOrders();
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Tạo đơn'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statusOptions.map((status) {
                      final isSelected = _selectedStatus == status['value'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status['label']),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = status['value'];
                            });
                          },
                          selectedColor: status['color'].withOpacity(0.2),
                          checkmarkColor: status['color'],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Orders list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, 
                                 size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'Không có đơn hàng nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = _filteredOrders[index];
                            return _buildOrderCard(order);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = _statusOptions.firstWhere(
      (s) => s['value'] == order['status'],
      orElse: () => _statusOptions.first,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['orderNumber'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: status['color']),
                  ),
                  child: Text(
                    status['label'],
                    style: TextStyle(
                      color: status['color'],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer info
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(order['customerName']),
                const SizedBox(width: 16),
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(order['customerPhone']),
              ],
            ),
            const SizedBox(height: 8),

            // Order date
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(order['createdAt']),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Order items
            ...order['items'].map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item['name']} x${item['quantity']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '${item['price'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            }).toList(),
            const Divider(),

            // Total and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng: ${order['total'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _showOrderDetails(order),
                      icon: const Icon(Icons.visibility),
                      color: Colors.blue,
                    ),
                    if (order['status'] != 'delivered' && order['status'] != 'cancelled')
                      IconButton(
                        onPressed: () => _showStatusUpdateDialog(order),
                        icon: const Icon(Icons.edit),
                        color: Colors.orange,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chi tiết đơn hàng ${order['orderNumber']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Khách hàng: ${order['customerName']}'),
              Text('Số điện thoại: ${order['customerPhone']}'),
              Text('Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(order['createdAt'])}'),
              const SizedBox(height: 16),
              const Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...order['items'].map<Widget>((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('• ${item['name']} x${item['quantity']} - ${item['price'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ'),
                );
              }).toList(),
              const SizedBox(height: 16),
              Text(
                'Tổng cộng: ${order['total'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(Map<String, dynamic> order) {
    String newStatus = order['status'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cập nhật trạng thái đơn hàng ${order['orderNumber']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statusOptions.where((s) => s['value'] != 'all').map((status) {
            return RadioListTile<String>(
              title: Text(status['label']),
              value: status['value'],
              groupValue: newStatus,
              onChanged: (value) async {
                newStatus = value!;
                Navigator.pop(context);
                await _updateOrderStatus(order, newStatus);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(Map<String, dynamic> order, String newStatus) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        throw Exception('Không có quyền truy cập');
      }

      // Call API to update order status
      await ApiService.updateOrderStatus(token, order['id'], newStatus);

      setState(() {
        order['status'] = newStatus;
      });

      final statusLabel = _statusOptions.firstWhere(
        (s) => s['value'] == newStatus,
        orElse: () => _statusOptions.first,
      )['label'];

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật trạng thái đơn hàng ${order['orderNumber']} thành "$statusLabel"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật trạng thái: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
