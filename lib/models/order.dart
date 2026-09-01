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

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      title: json['title'] ?? '',
      price: json['price'] ?? '',
      imagePath: json['imagePath'] ?? json['image_path'] ?? '',
      qty: json['qty'] ?? json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'imagePath': imagePath,
      'qty': qty,
    };
  }
}

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

  factory Order.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List?;
    final orderItems = list != null
        ? list.map((item) => OrderItem.fromJson(item)).toList()
        : <OrderItem>[];
    return Order(
      orderId: json['orderId'] ?? json['order_id'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? json['order_status'] ?? '',
      total: json['total']?.toString() ?? '',
      items: orderItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'date': date,
      'status': status,
      'total': total,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
