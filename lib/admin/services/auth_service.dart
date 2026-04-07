import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._();

  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Placeholder for initialization if needed by main.dart
  static void initialize() {}

  // ADMIN REGISTER
  Future<User?> registerAdmin({
    required String email,
    required String password,
    required String village,
    required String district,
    required String taluka,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        await _firestore.collection('admins').doc(user.uid).set({
          'email': email,
          'village_name': village,
          'district': district,
          'taluka': taluka,
          'role': 'admin',
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during registration.');
    }
  }

  // ADMIN LOGIN (Renamed from login to match your request, but keeping 'login' alias for compatibility)
  Future<User?> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during login.');
    }
  }

  // Compatibility alias for existing code
  Future<void> login({required String username, required String password}) async {
    // Note: username is treated as email in Firebase Auth context here
    await loginAdmin(email: username, password: password);
  }

  // GUEST LOGIN
  Future<User?> signInGuest() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;

      if (user != null) {
        await _firestore.collection('guest_users').doc(user.uid).set({
          'device_id': user.uid,
          'role': 'guest',
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during guest login.');
    }
  }

  // CURRENT USER
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Compatibility methods for token-based services
  Future<String?> getToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  Future<String> requireToken() async {
    final String? token = await getToken();
    if (token == null) {
      throw Exception('Admin session not found. Please login again.');
    }
    return token;
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Error handling
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return e.message ?? 'An unknown authentication error occurred.';
    }
  }
}
