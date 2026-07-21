class Product {
  final String id;
  final String title;
  final String subtitle;
  final String price;
  final String imagePath;
  final String category;
  final String gender;

  const Product({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imagePath,
    required this.category,
    required this.gender,
  });

  factory Product.fromMap(Map<String, String> map) {
    return Product(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      price: map['price'] ?? '',
      imagePath: map['imagePath'] ?? '',
      category: map['category'] ?? '',
      gender: map['gender'] ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'imagePath': imagePath,
      'category': category,
      'gender': gender,
    };
  }
}
