import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  static bool get isSignedIn => currentUser != null;

  // Sign in anonymously for demo purposes
  static Future<UserCredential> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();

    // Create a basic profile for anonymous users
    if (credential.user != null) {
      await _createUserProfile(
        credential.user!.uid,
        'Guest User',
        'guest@demo.com',
        isAnonymous: true,
      );
    }

    return credential;
  }

  // Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time
      if (credential.user != null) {
        await _database.child('users').child(credential.user!.uid).update({
          'lastLoginAt': ServerValue.timestamp,
        });
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email address.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'invalid-credential':
          message = 'Invalid email or password. Please check your credentials.';
          break;
        default:
          message = 'Login failed. Please try again.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Login failed. Please check your internet connection.');
    }
  }

  // Create account with email, password, and name
  static Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in database
      if (credential.user != null) {
        await _createUserProfile(credential.user!.uid, name, email);

        // Update display name in Firebase Auth
        await credential.user!.updateDisplayName(name);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password is too weak. Please use at least 6 characters.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with this email address.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        default:
          message = 'Account creation failed. Please try again.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception(
        'Account creation failed. Please check your internet connection.',
      );
    }
  }

  // Create user profile in database
  static Future<void> _createUserProfile(
    String uid,
    String name,
    String email, {
    bool isAnonymous = false,
  }) async {
    await _database.child('users').child(uid).set({
      'name': name,
      'email': email,
      'isAnonymous': isAnonymous,
      'createdAt': ServerValue.timestamp,
      'lastLoginAt': ServerValue.timestamp,
    });
  }

  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final snapshot = await _database.child('users').child(uid).get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }

  // Update user profile
  static Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _database.child('users').child(uid).update(data);
  }

  // Get user devices count
  static Future<int> getUserDevicesCount(String uid) async {
    final snapshot = await _database
        .child('users')
        .child(uid)
        .child('devices')
        .get();
    if (snapshot.exists) {
      final devices = snapshot.value as Map<dynamic, dynamic>;
      return devices.length;
    }
    return 0;
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}
