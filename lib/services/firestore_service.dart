import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/food.dart';

class FirestoreService {
  final collection = FirebaseFirestore.instance.collection('food_posts');

  Future<void> addFoodPost(Food food) async {
    await collection.add({
      'food_name': food.name,
      'quantity': food.quantity,
      'location': {
        'latitude': food.location.latitude,
        'longitude': food.location.longitude,
      },
      'time': DateTime.now(),
    });
  }
  
  Future<void> deleteFoodPost(String postId) async {
    await collection.doc(postId).delete();
  }

  Stream<QuerySnapshot> getFoodPosts() {
    return collection.orderBy('time', descending: true).snapshots();
  }
}