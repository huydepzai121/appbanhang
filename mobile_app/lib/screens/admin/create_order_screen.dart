import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _notesController = TextEditingController();

  List<Map<String, dynamic>> _orderItems = [];
  bool _isLoading = false;
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo đơn hàng'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer info
                    const Text(
                      'Thông tin khách hàng',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập họ và tên';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _customerEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _customerPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _customerAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập địa chỉ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Order items
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sản phẩm đặt hàng',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showAddProductDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm SP'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_orderItems.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Chưa có sản phẩm nào\nNhấn "Thêm SP" để thêm sản phẩm',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else
                      ...(_orderItems.map((item) => _buildOrderItemCard(item)).toList()),

                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            // Total and submit
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _orderItems.isEmpty || _isLoading ? null : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Tạo đơn hàng',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: item['product']['image'] != null
                    ? Image.network(
                        'http://10.0.2.2:3000${item['product']['image']}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.phone_android, size: 30);
                        },
                      )
                    : const Icon(Icons.phone_android, size: 30),
              ),
            ),
            const SizedBox(width: 12),

            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['product']['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['product']['price'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),

            // Quantity controls
            Row(
              children: [
                IconButton(
                  onPressed: () => _updateQuantity(item, item['quantity'] - 1),
                  icon: const Icon(Icons.remove),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    item['quantity'].toString(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => _updateQuantity(item, item['quantity'] + 1),
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                  ),
                ),
              ],
            ),

            // Remove button
            IconButton(
              onPressed: () => _removeItem(item),
              icon: const Icon(Icons.delete),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn sản phẩm'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = productProvider.products;

              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade200,
                        child: product.image != null
                            ? Image.network(
                                'http://10.0.2.2:3000${product.image}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.phone_android, size: 25);
                                },
                              )
                            : const Icon(Icons.phone_android, size: 25),
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text('${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ'),
                    onTap: () {
                      Navigator.pop(context);
                      _addProduct(product);
                    },
                  );
                },
              );
            },
          ),
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

  void _addProduct(Product product) {
    // Check if product already exists
    final existingIndex = _orderItems.indexWhere(
      (item) => item['product']['id'] == product.id,
    );

    if (existingIndex >= 0) {
      // Increase quantity
      _updateQuantity(_orderItems[existingIndex], _orderItems[existingIndex]['quantity'] + 1);
    } else {
      // Add new item
      setState(() {
        _orderItems.add({
          'product': {
            'id': product.id,
            'name': product.name,
            'price': product.price,
            'image': product.image,
          },
          'quantity': 1,
        });
        _calculateTotal();
      });
    }
  }

  void _updateQuantity(Map<String, dynamic> item, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem(item);
    } else {
      setState(() {
        item['quantity'] = newQuantity;
        _calculateTotal();
      });
    }
  }

  void _removeItem(Map<String, dynamic> item) {
    setState(() {
      _orderItems.remove(item);
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    _totalAmount = _orderItems.fold(0.0, (sum, item) {
      return sum + (item['product']['price'] * item['quantity']);
    });
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate() || _orderItems.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        throw Exception('Không có quyền truy cập');
      }

      // Prepare order data
      final orderData = {
        'customer_name': _customerNameController.text.trim(),
        'customer_phone': _customerPhoneController.text.trim(),
        'customer_address': _customerAddressController.text.trim(),
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        'items': _orderItems.map((item) => {
          'product_id': item['product']['id'],
          'quantity': item['quantity'],
          'price': item['product']['price'],
        }).toList(),
        'total_amount': _totalAmount,
        'status': 'confirmed', // Admin created orders are confirmed by default
      };

      // Call API to create order
      await ApiService.createOrderForAdmin(token, orderData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo đơn hàng thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Create order error: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo đơn hàng: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
