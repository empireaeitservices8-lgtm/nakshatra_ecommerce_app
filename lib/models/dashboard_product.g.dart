// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardProduct _$DashboardProductFromJson(Map<String, dynamic> json) =>
    DashboardProduct(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discount_percentage'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      currencySymbol: json['currency_symbol'] as String? ?? '₹',
      purity: json['purity'] as String?,
      purityPercentage: (json['purity_percentage'] as num?)?.toDouble(),
      totalStock: (json['total_stock'] as num?)?.toInt() ?? 0,
      availableLocations: json['available_locations'] as List<dynamic>? ?? const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      inWishlist: json['in_wishlist'] as bool? ?? false,
      badge: json['badge'] as String?,
      image: json['image'],
    );

Map<String, dynamic> _$DashboardProductToJson(DashboardProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'original_price': instance.originalPrice,
      'discount_percentage': instance.discountPercentage,
      'currency': instance.currency,
      'currency_symbol': instance.currencySymbol,
      'purity': instance.purity,
      'purity_percentage': instance.purityPercentage,
      'total_stock': instance.totalStock,
      'available_locations': instance.availableLocations,
      'rating': instance.rating,
      'reviews_count': instance.reviewsCount,
      'in_wishlist': instance.inWishlist,
      'badge': instance.badge,
      'image': instance.image,
    };
