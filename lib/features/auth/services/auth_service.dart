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
        try {
          await _database.child('users').child(credential.user!.uid).update({
            'lastLoginAt': ServerValue.timestamp,
          });
        } catch (e) {
          print('Error updating last login time: $e');
          // Don't throw error here as login was successful
        }
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
    try {
      final profileData = {
        'name': name,
        'email': email,
        'isAnonymous': isAnonymous,
        'createdAt': ServerValue.timestamp,
        'lastLoginAt': ServerValue.timestamp,
      };

      print('Creating user profile for $uid with data: $profileData');
      await _database.child('users').child(uid).set(profileData);
      print('User profile created successfully for $uid');
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final snapshot = await _database.child('users').child(uid).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value;
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
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
    try {
      // Updated path: devices are linked under patients
      final snapshot = await _database
          .child('users')
          .child(uid)
          .child('patients')
          .get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value;
        if (data is Map) {
          return data.length;
        }
      }
      return 0;
    } catch (e) {
      print('Error getting user devices count: $e');
      return 0;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check Firebase connection and data
  static Future<bool> checkFirebaseConnection() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      // Try to read from database
      final snapshot = await _database.child('.info/connected').get();
      print('Firebase connection status: ${snapshot.value}');

      // Try to read user data
      final userSnapshot = await _database.child('users').child(user.uid).get();
      print('User data exists: ${userSnapshot.exists}');
      print('User data: ${userSnapshot.value}');

      return snapshot.value == true;
    } catch (e) {
      print('Firebase connection check failed: $e');
      return false;
    }
  }

  // Ensure user profile exists - create if missing
  static Future<void> ensureUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return;

      final profile = await getUserProfile(user.uid);
      if (profile == null) {
        print('User profile missing, creating one...');

        // Get user info from Firebase Auth
        final name = user.displayName ?? 'User';
        final email = user.email ?? 'unknown@example.com';
        final isAnonymous = user.isAnonymous;

        await _createUserProfile(
          user.uid,
          name,
          email,
          isAnonymous: isAnonymous,
        );
        print('User profile created successfully');
      } else {
        print('User profile exists: $profile');
      }
    } catch (e) {
      print('Error ensuring user profile: $e');
    }
  }
}
