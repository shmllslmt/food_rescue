import 'package:geolocator/geolocator.dart';

class Food {
  final String name;
  final int quantity;
  final Position location;

  Food({required this.name, required this.quantity, required this.location});
}
