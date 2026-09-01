class Product {
  final String id;
  final String title;
  final String subtitle;
  final String price;
  final String imagePath;
  final String category;
  final String gender;
  final String description;
  final double weightGrams;
  final String purity;
  final bool inStock;

  const Product({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imagePath,
    required this.category,
    required this.gender,
    this.description = '',
    this.weightGrams = 0.0,
    this.purity = '',
    this.inStock = true,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    final rawId = map['product_id'] ?? map['id'] ?? '';
    final rawName = map['name'] ?? map['product_name'] ?? map['title'] ?? '';

    // Format price safely with currency symbol
    final rawPrice = map['price'];
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
    String imagePath =
        map['image_url'] ?? map['imagePath'] ?? map['image_path'] ?? '';
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

    // Guess category
    String category = map['category'] ?? '';
    if (category.isEmpty) {
      if (nameLower.contains('necklace') || nameLower.contains('chain')) {
        category = 'Chains';
      } else if (nameLower.contains('earring') || nameLower.contains('stud')) {
        category = 'Earrings';
      } else if (nameLower.contains('bangle')) {
        category = 'Bangles';
      } else if (nameLower.contains('bracelet')) {
        category = 'Bracelets';
      } else if (nameLower.contains('ring')) {
        category = 'Rings';
      } else {
        category = 'Chains';
      }
    }

    // Guess gender
    String gender = map['gender'] ?? '';
    if (gender.isEmpty) {
      if (nameLower.contains('gents') || nameLower.contains('men')) {
        gender = 'Gents';
      } else if (nameLower.contains('kids') || nameLower.contains('child')) {
        gender = 'Kids';
      } else {
        gender = 'Womens';
      }
    }

    return Product(
      id: rawId.toString(),
      title: rawName.toString(),
      subtitle: (map['subtitle'] ?? map['branch_name'] ?? 'Luxury Gold Edition')
          .toString(),
      price: formattedPrice,
      imagePath: imagePath,
      category: category,
      gender: gender,
      description:
          (map['description'] ??
                  'Exclusive premium jewellery crafted with perfection.')
              .toString(),
      weightGrams: (map['weight_grams'] ?? map['weightGrams'] ?? 0.0)
          .toDouble(),
      purity: (map['purity'] ?? '22K').toString(),
      inStock: map['in_stock'] ??
          map['inStock'] ??
          (() {
            final stockVal = map['total_stock'] ?? map['totalStock'] ?? map['stock'];
            if (stockVal == null) return true;
            if (stockVal is num) return stockVal > 0;
            return (double.tryParse(stockVal.toString()) ?? 1.0) > 0;
          })(),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final String rawName = json['name'] ?? json['title'] ?? '';
    final String desc = json['description'] ?? '';

    // Convert raw uppercase template name to Title Case for elegant display
    // e.g. "RING(22CT)" -> "Ring (22CT)"
    String name = rawName;
    if (name.isNotEmpty) {
      name = name.replaceAll('(', ' (');
      name = name.split(RegExp(r'\s+')).map((word) {
        if (word.isEmpty) return '';
        if (word.startsWith('(')) {
          return '(' + word.substring(1).toUpperCase();
        }
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ').replaceAll(' (', ' (').trim();
    }

    // Format price safely with currency symbol
    final rawPrice = json['price'];
    String formattedPrice = '₹0.00';
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

    // Format image URL
    String imgUrl = json['image_url'] ?? json['imagePath'] ?? json['image_path'] ?? '';
    if (imgUrl.startsWith('/')) {
      imgUrl = 'http://100.52.86.195:8069$imgUrl';
    }

    // Parse category from json, fall back to guessing if missing
    String categoryName = json['category'] ?? json['category_name'] ?? '';
    if (categoryName.isEmpty) {
      categoryName = 'Necklaces';
      final lowerName = rawName.toLowerCase();
      if (lowerName.contains('ring')) {
        categoryName = 'Rings';
      } else if (lowerName.contains('bangle') ||
          lowerName.contains('bracelet') ||
          lowerName.contains('kada')) {
        categoryName = 'Bracelets';
      } else if (lowerName.contains('earring') || lowerName.contains('stud')) {
        categoryName = 'Earrings';
      } else if (lowerName.contains('chain') || lowerName.contains('necklace')) {
        categoryName = 'Necklaces';
      } else if (lowerName.contains('wedding') || lowerName.contains('set')) {
        categoryName = 'Wedding Sets';
      }
    }

    // Parse gender from json, fall back to guessing if missing
    String gender = json['gender'] ?? '';
    if (gender.isEmpty) {
      final lowerName = rawName.toLowerCase();
      if (lowerName.contains('gents') || lowerName.contains('men')) {
        gender = 'Gents';
      } else if (lowerName.contains('kids') || lowerName.contains('child')) {
        gender = 'Kids';
      } else {
        gender = 'Womens';
      }
    }

    // Extract weight from location_stocks if missing from root
    double weight = (json['weight_grams'] ?? json['weightGrams'] ?? 0.0).toDouble();
    if (weight == 0.0) {
      final locStocks = json['location_stocks'];
      if (locStocks is List && locStocks.isNotEmpty) {
        final firstLoc = locStocks.first;
        final labels = firstLoc['labels'];
        if (labels is List && labels.isNotEmpty) {
          weight = (labels.first['grams'] ?? 0.0).toDouble();
        }
      }
    }

    // Extract purity
    final purity = (json['purity'] ?? '22K').toString();

    // Construct dynamically from real API data
    String dynamicSubtitle = json['subtitle'] ?? '';
    if (dynamicSubtitle.isEmpty) {
      dynamicSubtitle = 'Hallmarked $purity';
      if (weight > 0) {
        dynamicSubtitle += ' | ${weight.toStringAsFixed(2)}g';
      }
    }

    String dynamicDesc = desc;
    if (dynamicDesc.isEmpty) {
      dynamicDesc = 'Exclusive premium ${name.toLowerCase()} crafted with perfection in $purity gold.';
      if (weight > 0) {
        dynamicDesc += ' Item weight is ${weight.toStringAsFixed(2)} grams.';
      }
    }

    return Product(
      id: (json['id'] ?? json['product_id'] ?? '').toString(),
      title: name,
      subtitle: dynamicSubtitle,
      price: formattedPrice,
      imagePath: imgUrl,
      category: categoryName,
      gender: gender,
      description: dynamicDesc,
      weightGrams: weight,
      purity: purity,
      inStock: json['in_stock'] ??
          json['inStock'] ??
          (() {
            final stockVal = json['total_stock'] ?? json['totalStock'] ?? json['stock'];
            if (stockVal == null) return true;
            if (stockVal is num) return stockVal > 0;
            return (double.tryParse(stockVal.toString()) ?? 1.0) > 0;
          })(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'imagePath': imagePath,
      'category': category,
      'gender': gender,
      'description': description,
      'weight_grams': weightGrams,
      'purity': purity,
      'in_stock': inStock,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
