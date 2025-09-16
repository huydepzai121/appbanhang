class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? originalPrice;
  final String? brand;
  final String? model;
  final String? color;
  final String? storage;
  final String? ram;
  final String? screenSize;
  final String? battery;
  final String? camera;
  final String? os;
  final String? image;
  final List<String> images;
  final int? categoryId;
  final String? categoryName;
  final int stockQuantity;
  final bool isFeatured;
  final bool isActive;
  final double averageRating;
  final int reviewCount;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.originalPrice,
    this.brand,
    this.model,
    this.color,
    this.storage,
    this.ram,
    this.screenSize,
    this.battery,
    this.camera,
    this.os,
    this.image,
    this.images = const [],
    this.categoryId,
    this.categoryName,
    required this.stockQuantity,
    this.isFeatured = false,
    this.isActive = true,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      originalPrice: json['original_price'] != null
          ? double.parse(json['original_price'].toString())
          : null,
      brand: json['brand'],
      model: json['model'],
      color: json['color'],
      storage: json['storage'],
      ram: json['ram'],
      screenSize: json['screen_size'],
      battery: json['battery'],
      camera: json['camera'],
      os: json['os'],
      image: json['image'],
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      stockQuantity: json['stock_quantity'],
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      averageRating: json['average_rating'] != null
          ? double.parse(json['average_rating'].toString())
          : 0.0,
      reviewCount: json['review_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  bool get inStock => stockQuantity > 0;
}