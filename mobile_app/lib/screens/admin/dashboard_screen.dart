import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        throw Exception('Không có quyền truy cập');
      }

      // Load dashboard data from API
      final data = await ApiService.getDashboardStats(token);

      setState(() {
        final ordersData = data['data']['orders'] ?? {};
        final productsData = data['data']['products'] ?? {};
        final usersData = data['data']['users'] ?? {};

        _stats = {
          'totalProducts': productsData['total_products'] ?? 0,
          'totalOrders': ordersData['total_orders'] ?? 0,
          'totalUsers': usersData['total_users'] ?? 0,
          'totalRevenue': _parseToDouble(ordersData['total_revenue']),
          'todayOrders': ordersData['today_orders'] ?? 0,
          'pendingOrders': ordersData['pending_orders'] ?? 0,
          'completedOrders': ordersData['delivered_orders'] ?? 0,
          'cancelledOrders': ordersData['cancelled_orders'] ?? 0,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _stats = {
          'totalProducts': 0,
          'totalOrders': 0,
          'totalUsers': 0,
          'totalRevenue': 0.0,
          'todayOrders': 0,
          'pendingOrders': 0,
          'completedOrders': 0,
          'cancelledOrders': 0,
        };
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu dashboard: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome card
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Card(
                          color: Colors.orange.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  radius: 30,
                                  child: Text(
                                    authProvider.user?.name.substring(0, 1).toUpperCase() ?? 'A',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Chào mừng, ${authProvider.user?.name ?? 'Admin'}!',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Quản lý cửa hàng điện thoại',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Stats overview
                    const Text(
                      'Tổng quan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          'Sản phẩm',
                          _stats['totalProducts'].toString(),
                          Icons.inventory,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Đơn hàng',
                          _stats['totalOrders'].toString(),
                          Icons.shopping_cart,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Người dùng',
                          _stats['totalUsers'].toString(),
                          Icons.people,
                          Colors.purple,
                        ),
                        _buildStatCard(
                          'Doanh thu',
                          _formatRevenue(_stats['totalRevenue']),
                          Icons.attach_money,
                          Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Today's orders
                    const Text(
                      'Đơn hàng hôm nay',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildOrderStatusCard(
                            'Mới',
                            _stats['todayOrders'].toString(),
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildOrderStatusCard(
                            'Đang xử lý',
                            _stats['pendingOrders'].toString(),
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildOrderStatusCard(
                            'Hoàn thành',
                            _stats['completedOrders'].toString(),
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildOrderStatusCard(
                            'Đã hủy',
                            _stats['cancelledOrders'].toString(),
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick actions
                    const Text(
                      'Thao tác nhanh',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to add product
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm sản phẩm'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to orders
                            },
                            icon: const Icon(Icons.list),
                            label: const Text('Xem đơn hàng'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  double _parseToDouble(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  String _formatRevenue(dynamic revenue) {
    try {
      double revenueValue = 0.0;
      if (revenue is double) {
        revenueValue = revenue;
      } else if (revenue is int) {
        revenueValue = revenue.toDouble();
      } else if (revenue is String) {
        revenueValue = double.tryParse(revenue) ?? 0.0;
      }
      return '${(revenueValue / 1000000).toStringAsFixed(1)}M';
    } catch (e) {
      return '0.0M';
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
