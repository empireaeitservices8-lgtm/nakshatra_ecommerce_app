class CartItem {
  final String id;
  final String productId;
  final String title;
  final String price;
  final String imagePath;
  final int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['cart_line_id'] ?? json['id'] ?? '';
    final rawProductId = json['product_id'] ?? json['productId'] ?? '';
    final rawName = json['product_name'] ?? json['title'] ?? '';
    
    // Format price safely with currency symbol
    final rawPrice = json['price'];
    String formattedPrice = '';
    if (rawPrice != null) {
      if (rawPrice is num) {
        formattedPrice = '₹${rawPrice.toStringAsFixed(2)}';
      } else {
        final priceStr = rawPrice.toString();
        if (priceStr.startsWith('₹')) {
          formattedPrice = priceStr;
        } else {
          final parsed = double.tryParse(priceStr);
          if (parsed != null) {
            formattedPrice = '₹${parsed.toStringAsFixed(2)}';
          } else {
            formattedPrice = priceStr;
          }
        }
      }
    }

    final nameLower = rawName.toString().toLowerCase();

    // Guess image based on name keywords if missing
    String imagePath = json['image_url'] ?? json['imagePath'] ?? json['image_path'] ?? '';
    if (imagePath.startsWith('/')) {
      imagePath = 'http://100.52.86.195:8069$imagePath';
    }
    if (imagePath.isEmpty) {
      if (nameLower.contains('necklace')) {
        imagePath = 'assets/images/necklace.png';
      } else if (nameLower.contains('earring') || nameLower.contains('stud')) {
        imagePath = 'assets/images/earring.png';
      } else if (nameLower.contains('bangle')) {
        imagePath = 'assets/images/bangle.png';
      } else if (nameLower.contains('bracelet')) {
        imagePath = 'assets/images/bracelet.png';
      } else if (nameLower.contains('ring')) {
        imagePath = 'assets/images/ring.png';
      } else {
        imagePath = 'assets/images/necklace.png';
      }
    }

    return CartItem(
      id: rawId.toString(),
      productId: rawProductId.toString(),
      title: rawName.toString(),
      price: formattedPrice,
      imagePath: imagePath,
      quantity: json['quantity'] is num ? (json['quantity'] as num).toInt() : int.tryParse(json['quantity']?.toString() ?? '') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'title': title,
      'price': price,
      'imagePath': imagePath,
      'quantity': quantity,
    };
  }
}
