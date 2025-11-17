import '../models/rating_model.dart';

abstract class RatingRepository {

  Future<List<RatingModel>> getPendingRatings();

  Future<List<RatingModel>> getHistoryRatings();

  Future<void> createRating({
    required String bookingId,
    required int stars,
    String? comment,
    List<String>? imageIds,
  });
}