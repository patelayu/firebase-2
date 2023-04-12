import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDBHelpers {
  FirebaseDBHelpers._();

  static final FirebaseDBHelpers firebaseDBHelpers = FirebaseDBHelpers._();

  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> insertBook({required Map<String, dynamic> data}) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await db.collection("counter").doc("book_counter").get();

    int count = documentSnapshot.data()!['count'];
    int id = documentSnapshot.data()!['id'];

    await db.collection("books").doc("${++id}").set(data);

    await db.collection("counter").doc("book_counter").update({"id": id});

    await db
        .collection("counter")
        .doc("book_counter")
        .update({"count": ++count});
  }

  Future<void> deleteBook({required String id}) async {
    await db.collection("books").doc(id).delete();

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await db.collection("counter").doc("book_counter").get();

    int count = documentSnapshot.data()!['count'];

    await db
        .collection("counter")
        .doc("book_counter")
        .update({"count": --count});
  }

  Future<void> updateBook({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await db.collection("books").doc(id).update(data);
  }
}