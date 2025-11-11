import '../models/booking.dart';

abstract class BookingRepository {
  Future<List<Booking>> getListBooked();
}
