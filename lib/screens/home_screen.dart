import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '/services/location_service.dart';
import '/services/firestore_service.dart';
import '/models/food.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String locationText = "Fetching location...";
  Position? currentLocation;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();
      final address = await locationService.getAddressFromCoordinates(position);

      setState(() {
        locationText = address;
        currentLocation = position;
      });
    } catch (e) {
      setState(() {
        locationText = "Unable to fetch location...";
      });

      debugPrint("Error fetching location: ${e.toString()}");
    }
  }

  Future<void> _submitDonation() async {
    if (currentLocation != null) {
      try {
        final food = Food(
          name: foodNameController.text,
          quantity: int.parse(quantityController.text),
          location: currentLocation!,
        );

        // Call your Firestore service to add the food post
        await FirestoreService().addFoodPost(food);

        // await NotificationService.showNotification(
        //   'Food Donation Posted',
        //   'Your food donation has been posted successfully!',
        // );

        foodNameController.clear();
        quantityController.clear();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Food donation posted successfully!')),
        );
      } catch (e) {
        // Handle parsing error or show an error message
        debugPrint("Error creating food donation post: ${e.toString()}");
      }
    } else {
      // Show an error message or handle the case when location is not available
    }
  }

  TextEditingController foodNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: foodNameController,
              decoration: InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fastfood, color: Colors.red[700]),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers, color: Colors.red[700]),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.place, color: Colors.red[700], size: 30),
                SizedBox(width: 10),
                Flexible(
                  child: Text(
                    locationText,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: MaterialButton(
                onPressed: _submitDonation,
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Donate Food', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
