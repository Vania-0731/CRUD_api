class Product {
  final int? id;
  final String title;
  final String description;
  final double price;
  final String? image;
  final String? category;

  Product({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    this.image,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      image: json['image'],
      category: json['category'],
    );
  }

  factory Product.fromJsonDB(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      image: json['image'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'image': image ?? '',
      'category': category ?? 'general',
    };
  }

  Map<String, dynamic> toJsonForDB() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'image': image ?? '',
      'category': category ?? 'general',
    };
  }
}
