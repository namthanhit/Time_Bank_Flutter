import '../models/booking.dart';

abstract class BookingRepository {
  Future<List<Booking>> getListBooked();

  Future<int> getCountBooked(String jobId);
}
