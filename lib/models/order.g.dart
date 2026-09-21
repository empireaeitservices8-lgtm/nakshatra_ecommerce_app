// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) {
  final rawQty = json['qty'] ?? json['quantity'] ?? json['product_uom_qty'];
  int parsedQty = 1;
  if (rawQty is int) {
    parsedQty = rawQty;
  } else if (rawQty is num) {
    parsedQty = rawQty.toInt();
  } else if (rawQty is String) {
    parsedQty = int.tryParse(rawQty) ?? double.tryParse(rawQty)?.toInt() ?? 1;
  }

  return OrderItem(
    title: json['title'] as String? ??
        json['name'] as String? ??
        json['product_name'] as String? ??
        '',
    price: json['price']?.toString() ??
        json['price_unit']?.toString() ??
        json['subtotal']?.toString() ??
        '',
    imagePath: json['imagePath'] as String? ??
        json['image_path'] as String? ??
        json['image_url'] as String? ??
        json['image'] as String? ??
        '',
    qty: parsedQty,
  );
}

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
      'title': instance.title,
      'price': instance.price,
      'imagePath': instance.imagePath,
      'qty': instance.qty,
    };

Order _$OrderFromJson(Map<String, dynamic> json) {
  final list = (json['items'] ??
      json['order_lines'] ??
      json['lines'] ??
      json['products']) as List?;
  final orderItems = list != null
      ? list.map((item) {
          if (item is Map<String, dynamic>) {
            return OrderItem.fromJson(item);
          } else if (item is Map) {
            return OrderItem.fromJson(Map<String, dynamic>.from(item));
          }
          return OrderItem(title: '', price: '', imagePath: '', qty: 1);
        }).toList()
      : <OrderItem>[];

  final rawTotal = json['total'] ??
      json['amount_total'] ??
      json['price_total'] ??
      json['grand_total'];
  final totalStr = rawTotal != null ? rawTotal.toString() : '';

  return Order(
    orderId: json['orderId']?.toString() ??
        json['order_id']?.toString() ??
        json['id']?.toString() ??
        json['name']?.toString() ??
        '',
    date: json['date'] as String? ??
        json['date_order'] as String? ??
        json['create_date'] as String? ??
        json['order_date'] as String? ??
        '',
    status: json['status'] as String? ??
        json['order_status'] as String? ??
        json['state'] as String? ??
        'Pending',
    total: totalStr.isNotEmpty &&
            !totalStr.startsWith('₹') &&
            !totalStr.startsWith('\$')
        ? '₹$totalStr'
        : totalStr,
    items: orderItems,
  );
}

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'orderId': instance.orderId,
      'date': instance.date,
      'status': instance.status,
      'total': instance.total,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
