class CartItem {
  final int id;
  final int productId;
  final String name;
  final double price;
  final int quantity;
  final int stockQuantity;
  final String? image;
  final DateTime? createdAt;

  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.stockQuantity,
    this.image,
    this.createdAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      name: json['name'] as String,
      price: double.tryParse(json['price'].toString()) ?? 0,
      quantity: json['quantity'] as int,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      image: json['image'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'stock_quantity': stockQuantity,
      'image': image,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  double get subtotal => price * quantity;

  CartItem copyWith({
    int? id,
    int? productId,
    String? name,
    double? price,
    int? quantity,
    int? stockQuantity,
    String? image,
    DateTime? createdAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Cart {
  final List<CartItem> items;
  final double total;
  final int count;

  const Cart({
    required this.items,
    required this.total,
    required this.count,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson
        .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return Cart(
      items: items,
      total: double.tryParse(json['total'].toString()) ?? 0,
      count: json['count'] as int? ?? items.length,
    );
  }

  factory Cart.empty() => const Cart(items: [], total: 0, count: 0);

  bool get isEmpty => items.isEmpty;
}
