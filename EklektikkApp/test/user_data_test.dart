import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test user data completeness', () async {
    final doc = await FirebaseFirestore.instance.collection('users').doc('test_id').get();
    expect(doc.exists, isTrue);

    final data = doc.data()!;
    expect(data['phone'], isNotNull);
    expect(data['email'], isNotNull);
  });
}