import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      //Set the disoplay name of the user
      await credential.user?.updateDisplayName(username);

      return credential.user;
    } catch (e) {
      print("Error signing up user: $e"); // Log specific error message
      return null; // Return null to indicate failure
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      print("Error signing in: $e"); // Log specific error message
      return null; // Return null to indicate failure
    }
  }
}
