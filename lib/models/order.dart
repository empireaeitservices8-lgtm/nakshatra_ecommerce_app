import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class OrderItem {
  final String title;
  final String price;
  final String imagePath;
  final int qty;

  OrderItem({
    required this.title,
    required this.price,
    required this.imagePath,
    required this.qty,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Order {
  final String orderId;
  final String date;
  final String status;
  final String total;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.date,
    required this.status,
    required this.total,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
