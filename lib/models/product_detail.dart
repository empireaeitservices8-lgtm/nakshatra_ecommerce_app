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

  factory ProductDetail.fromJson(Map<String, dynamic> json) =>
      _$ProductDetailFromJson(json);

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
