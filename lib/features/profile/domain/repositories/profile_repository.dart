import '../profile.dart';
import '../review.dart';

abstract class ProfileRepository {
  Future<Profile> fetchMyProfile();
  Future<Profile> fetchProfileById(String userId);
  Future<void> updateMyProfile(Map<String, dynamic> updates);
  Future<List<Review>> fetchReviews(String userId);
}