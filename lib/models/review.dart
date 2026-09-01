class Review {
  final String reviewId;
  final String userName;
  final String productTitle;
  final int rating;
  final String comment;
  final String date;

  Review({
    required this.reviewId,
    required this.userName,
    required this.productTitle,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'] ?? json['reviewId'] ?? '',
      userName: json['user_name'] ?? json['userName'] ?? '',
      productTitle: json['product_title'] ?? json['productTitle'] ?? 'Nakshatra Jewelry',
      rating: json['rating'] ?? 5,
      comment: json['comment'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'user_name': userName,
      'product_title': productTitle,
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }
}
