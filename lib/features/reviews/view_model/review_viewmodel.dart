import 'package:flutter/material.dart';
import '../../../models/review.dart';
import '../../../providers/view_model.dart';
import '../../../repositories/review_repository.dart';

class ReviewViewModel extends BaseViewModel {
  final ReviewRepository _repository = ReviewRepository();
  List<Review> _reviews = [];

  ReviewViewModel() : super(name: "ReviewViewModel");

  List<Review> get reviews => _reviews;

  Future<void> fetchReviews(String customerId, [String? productId]) async {
    setBusy(true);
    clearError();

    try {
      _reviews = await _repository.getReviews(customerId: customerId, productId: productId);
    } catch (e) {
      setErrorMessage(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<bool> addReview({
    required String customerId,
    required String productId,
    required int rating,
    required String comment,
  }) async {
    setBusy(true);
    clearError();

    try {
      await _repository.writeReview(
        customerId: customerId,
        productId: productId,
        rating: rating,
        comment: comment,
      );
      await fetchReviews(customerId, productId);
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }

  Future<bool> deleteReview({
    required String customerId,
    required String reviewId,
  }) async {
    setBusy(true);
    clearError();

    try {
      await _repository.deleteReview(customerId: customerId, reviewId: reviewId);
      _reviews.removeWhere((item) => item.reviewId == reviewId);
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }
}
