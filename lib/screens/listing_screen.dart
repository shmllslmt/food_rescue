import 'package:flutter/material.dart';
import '/services/firestore_service.dart';

class ListingScreen extends StatefulWidget {
  const ListingScreen({super.key});

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  final firestore = FirestoreService();

  Future<void> deleteDonation(String docId) async {
    await firestore.deleteFoodPost(docId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: firestore.getFoodPosts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No food available"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];

              return Dismissible(
                key: Key(docs[index].id),

                direction: DismissDirection.endToStart,

                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.check, color: Colors.white),
                ),

                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirm Pickup"),
                      content: const Text("Mark this food as picked up?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Yes"),
                        ),
                      ],
                    ),
                  );
                },

                onDismissed: (direction) async {
                  final docId = docs[index].id;

                  await deleteDonation(docId);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Food picked up")),
                  );
                },

                child: ListTile(
                  leading: const Icon(Icons.fastfood, color: Colors.red),
                  title: Text(data['food_name']),
                  subtitle: Text(
                    "Pickup at Lat: ${data['location']['latitude']}, Lng: ${data['location']['longitude']}",
                  ),
                  trailing: Text(
                    "${data['quantity']}\navailable",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
