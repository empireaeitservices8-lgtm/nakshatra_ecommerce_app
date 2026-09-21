import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'product_detail.g.dart';

@JsonSerializable()
class ProductDetail {
  final int id;
  final String name;
  final String description;
  final double price;
  @JsonKey(name: 'original_price')
  final double originalPrice;
  @JsonKey(name: 'discount_percentage')
  final int discountPercentage;
  final String currency;
  @JsonKey(name: 'currency_symbol')
  final String currencySymbol;
  final String? purity;
  @JsonKey(name: 'purity_percentage')
  final double? purityPercentage;
  @JsonKey(name: 'total_stock')
  final int totalStock;
  @JsonKey(name: 'available_locations')
  final List<dynamic> availableLocations;
  final double rating;
  @JsonKey(name: 'reviews_count')
  final int reviewsCount;
  @JsonKey(name: 'in_wishlist')
  final bool inWishlist;
  final dynamic image;

  ProductDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.discountPercentage,
    required this.currency,
    required this.currencySymbol,
    required this.purity,
    required this.purityPercentage,
    required this.totalStock,
    required this.availableLocations,
    required this.rating,
    required this.reviewsCount,
    required this.inWishlist,
    required this.image,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['product_id'] ?? 0;
    final int id = rawId is num
        ? rawId.toInt()
        : (int.tryParse(rawId.toString()) ?? 0);

    final String name =
        (json['name'] ?? json['product_name'] ?? json['title'] ?? '')
            .toString();
    final String description = (json['description'] ?? '').toString();

    final rawPrice = json['price'];
    final double price = rawPrice is num
        ? rawPrice.toDouble()
        : (double.tryParse(rawPrice?.toString() ?? '') ?? 0.0);

    final rawOrigPrice = json['original_price'];
    final double originalPrice = rawOrigPrice is num
        ? rawOrigPrice.toDouble()
        : (double.tryParse(rawOrigPrice?.toString() ?? '') ?? price);

    final rawDiscount = json['discount_percentage'];
    final int discountPercentage = rawDiscount is num
        ? rawDiscount.toInt()
        : (int.tryParse(rawDiscount?.toString() ?? '') ?? 0);

    final String currency = (json['currency'] ?? 'INR').toString();
    final String currencySymbol = (json['currency_symbol'] ?? '₹').toString();

    final String? purity = json['purity']?.toString();
    final rawPurityPct = json['purity_percentage'];
    final double? purityPercentage = rawPurityPct is num
        ? rawPurityPct.toDouble()
        : double.tryParse(rawPurityPct?.toString() ?? '');

    final rawStock = json['total_stock'] ?? json['stock'];
    final double totalStockNum = rawStock is num
        ? rawStock.toDouble()
        : (double.tryParse(rawStock?.toString() ?? '') ?? 0.0);
    final int totalStock = totalStockNum.ceil();

    final availableLocations =
        json['available_locations'] as List<dynamic>? ?? const [];

    final rawRating = json['rating'];
    final double rating = rawRating is num
        ? rawRating.toDouble()
        : (double.tryParse(rawRating?.toString() ?? '') ?? 0.0);

    final rawReviews = json['reviews_count'];
    final int reviewsCount = rawReviews is num
        ? rawReviews.toInt()
        : (int.tryParse(rawReviews?.toString() ?? '') ?? 0);

    final bool inWishlist = json['in_wishlist'] == true;

    final image =
        json['image_url'] ??
        json['image'] ??
        json['image_path'] ??
        (json['images'] is List && (json['images'] as List).isNotEmpty
            ? json['images'][0]
            : null);

    return ProductDetail(
      id: id,
      name: name,
      description: description,
      price: price,
      originalPrice: originalPrice,
      discountPercentage: discountPercentage,
      currency: currency,
      currencySymbol: currencySymbol,
      purity: purity,
      purityPercentage: purityPercentage,
      totalStock: totalStock,
      availableLocations: availableLocations,
      rating: rating,
      reviewsCount: reviewsCount,
      inWishlist: inWishlist,
      image: image,
    );
  }

  Map<String, dynamic> toJson() => _$ProductDetailToJson(this);

  Product toProduct() {
    String imgUrl = '';
    if (image is String && (image as String).isNotEmpty) {
      final img = image as String;
      imgUrl = img.startsWith('/') ? 'http://100.52.86.195:8069$img' : img;
    }

    // Default image guessing based on name if empty
    if (imgUrl.isEmpty) {
      final nameLower = name.toLowerCase();
      if (nameLower.contains('necklace')) {
        imgUrl = 'assets/images/necklace.png';
      } else if (nameLower.contains('earring') || nameLower.contains('stud')) {
        imgUrl = 'assets/images/earring.png';
      } else if (nameLower.contains('bangle')) {
        imgUrl = 'assets/images/bangle.png';
      } else if (nameLower.contains('bracelet')) {
        imgUrl = 'assets/images/bracelet.png';
      } else if (nameLower.contains('ring')) {
        imgUrl = 'assets/images/ring.png';
      } else {
        imgUrl = 'assets/images/necklace.png';
      }
    }

    return Product(
      id: id.toString(),
      title: name,
      subtitle: purity != null ? 'Hallmarked $purity' : 'Luxury Gold Edition',
      price: price > 0 ? '₹${price.toStringAsFixed(2)}' : '₹0.00',
      imagePath: imgUrl,
      category: '',
      gender: '',
      description: description.isNotEmpty
          ? description
          : 'Exclusive premium gold jewellery crafted with perfection.',
      weightGrams: 0.0,
      purity: purity ?? '22K',
      inStock: totalStock > 0,
    );
  }
}
