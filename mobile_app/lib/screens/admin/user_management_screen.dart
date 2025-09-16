import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'edit_user_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'all';
  bool _isLoading = false;
  List<Map<String, dynamic>> _users = [];

  final List<Map<String, dynamic>> _roleOptions = [
    {'value': 'all', 'label': 'Tất cả', 'color': Colors.grey},
    {'value': 'customer', 'label': 'Khách hàng', 'color': Colors.blue},
    {'value': 'admin', 'label': 'Quản trị viên', 'color': Colors.orange},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading users from API
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _users = [
        {
          'id': 1,
          'name': 'Admin',
          'email': 'admin@phonestore.com',
          'phone': '0123456789',
          'address': 'Hà Nội',
          'role': 'admin',
          'createdAt': DateTime.now().subtract(const Duration(days: 30)),
          'totalOrders': 0,
          'totalSpent': 0,
        },
        {
          'id': 2,
          'name': 'Nguyễn Văn A',
          'email': 'nguyenvana@gmail.com',
          'phone': '0987654321',
          'address': '123 Đường ABC, Quận 1, TP.HCM',
          'role': 'customer',
          'createdAt': DateTime.now().subtract(const Duration(days: 15)),
          'totalOrders': 5,
          'totalSpent': 75000000,
        },
        {
          'id': 3,
          'name': 'Trần Thị B',
          'email': 'tranthib@gmail.com',
          'phone': '0912345678',
          'address': '456 Đường XYZ, Quận 2, TP.HCM',
          'role': 'customer',
          'createdAt': DateTime.now().subtract(const Duration(days: 10)),
          'totalOrders': 3,
          'totalSpent': 45000000,
        },
        {
          'id': 4,
          'name': 'Lê Văn C',
          'email': 'levanc@gmail.com',
          'phone': '0934567890',
          'address': '789 Đường DEF, Quận 3, TP.HCM',
          'role': 'customer',
          'createdAt': DateTime.now().subtract(const Duration(days: 5)),
          'totalOrders': 1,
          'totalSpent': 15000000,
        },
        {
          'id': 5,
          'name': 'Phạm Thị D',
          'email': 'phamthid@gmail.com',
          'phone': '0945678901',
          'address': '321 Đường GHI, Quận 4, TP.HCM',
          'role': 'customer',
          'createdAt': DateTime.now().subtract(const Duration(days: 2)),
          'totalOrders': 2,
          'totalSpent': 30000000,
        },
      ];
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredUsers {
    var filtered = _users;

    // Filter by role
    if (_selectedRole != 'all') {
      filtered = filtered.where((user) => user['role'] == _selectedRole).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               user['email'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (user['phone']?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm người dùng...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Role filter
                Row(
                  children: [
                    const Text(
                      'Vai trò: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _roleOptions.map((role) {
                            final isSelected = _selectedRole == role['value'];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(role['label']),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedRole = role['value'];
                                  });
                                },
                                selectedColor: role['color'].withOpacity(0.2),
                                checkmarkColor: role['color'],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, 
                                 size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty ? 'Không có người dùng nào' : 'Không tìm thấy người dùng',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _buildUserCard(user);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final role = _roleOptions.firstWhere(
      (r) => r['value'] == user['role'],
      orElse: () => _roleOptions.first,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: role['color'],
                  radius: 24,
                  child: Text(
                    user['name'].substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: role['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: role['color']),
                            ),
                            child: Text(
                              role['label'],
                              style: TextStyle(
                                color: role['color'],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['email'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // User details
            if (user['phone'] != null) ...[
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(user['phone']),
                ],
              ),
              const SizedBox(height: 8),
            ],

            if (user['address'] != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user['address'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Tham gia: ${DateFormat('dd/MM/yyyy').format(user['createdAt'])}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),

            // Customer stats (only for customers)
            if (user['role'] == 'customer') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            user['totalOrders'].toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Text(
                            'Đơn hàng',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${(user['totalSpent'] / 1000000).toStringAsFixed(1)}M',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Text(
                            'Đã mua',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.blue,
                            size: 20,
                          ),
                          Text(
                            user['role'] == 'admin' ? 'Admin' : 'Customer',
                            style: TextStyle(
                              fontSize: 12,
                              color: user['role'] == 'admin' ? Colors.orange : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Actions
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showUserDetails(user),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Chi tiết'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _editUser(user),
                  icon: const Icon(Icons.edit),
                  label: const Text('Sửa'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chi tiết người dùng'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tên: ${user['name']}'),
              Text('Email: ${user['email']}'),
              if (user['phone'] != null) Text('Số điện thoại: ${user['phone']}'),
              if (user['address'] != null) Text('Địa chỉ: ${user['address']}'),
              Text('Vai trò: ${user['role'] == 'admin' ? 'Quản trị viên' : 'Khách hàng'}'),
              Text('Ngày tham gia: ${DateFormat('dd/MM/yyyy HH:mm').format(user['createdAt'])}'),
              if (user['role'] == 'customer') ...[
                const SizedBox(height: 16),
                Text('Tổng số đơn hàng: ${user['totalOrders']}'),
                Text('Tổng chi tiêu: ${user['totalSpent'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ'),
              ],
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

  // Removed _toggleUserStatus since isActive column doesn't exist

  void _editUser(Map<String, dynamic> user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserScreen(user: user),
      ),
    );

    // Refresh user list if edit was successful
    if (result == true) {
      _loadUsers();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
