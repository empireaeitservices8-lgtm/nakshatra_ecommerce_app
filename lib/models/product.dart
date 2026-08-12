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

  factory Product.fromJson(Map<String, dynamic> json) {
    final String name = json['name'] ?? '';
    final String desc = json['description'] ?? '';
    
    // Format price
    final double rawPrice = (json['price'] as num?)?.toDouble() ?? 0.0;
    final String formattedPrice = '₹${rawPrice.toStringAsFixed(2)}';

    // Format image URL
    String imgUrl = json['image_url'] ?? '';
    if (imgUrl.startsWith('/')) {
      imgUrl = 'http://100.52.86.195:8069$imgUrl';
    }

    // Deduce category from name
    String categoryName = 'Necklaces';
    final lowerName = name.toLowerCase();
    if (lowerName.contains('ring')) {
      categoryName = 'Rings';
    } else if (lowerName.contains('bangle') || lowerName.contains('bracelet') || lowerName.contains('kada')) {
      categoryName = 'Bracelets';
    } else if (lowerName.contains('earring') || lowerName.contains('stud')) {
      categoryName = 'Earrings';
    } else if (lowerName.contains('chain') || lowerName.contains('necklace')) {
      categoryName = 'Necklaces';
    } else if (lowerName.contains('wedding') || lowerName.contains('set')) {
      categoryName = 'Wedding Sets';
    }

    return Product(
      id: (json['id'] ?? '').toString(),
      title: name,
      subtitle: desc.isNotEmpty ? desc : 'Exquisite Nakshathra Hallmark 22K',
      price: formattedPrice,
      imagePath: imgUrl,
      category: categoryName,
      gender: 'Womens', // Default gender category
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
