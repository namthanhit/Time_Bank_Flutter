import '../domain/models/home_models.dart';

abstract class HomeRepository {
  Future<HomeSummary> fetchSummary();
  Future<List<Activity>> fetchActivities();
}
