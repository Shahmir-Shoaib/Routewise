import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:routewise/firebase_options.dart';
import 'package:routewise/utils/firestore_seeder.dart';

const _defaultUserId = 'bXEQvPuPJ3cifcYZGLdQrzbfXnm1';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final userId = args.isNotEmpty ? args[0] : _defaultUserId;

  if (args.isEmpty) {
    print('No userId provided, using default UID: $_defaultUserId');
    print(
        'To override, run: flutter pub run tool/firestore_seed.dart <userId>');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    print('Seeding Firestore for user: $userId');
    await FirestoreSeeder.seedFirestoreForUser(userId);
    print('Firestore seeding complete.');
  } catch (e, stack) {
    print('Failed to seed Firestore: $e');
    print(stack);
  }
}
