import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '734686170315-ca4mlacbai08h0e0s12etf0fkr2cra2k.apps.googleusercontent.com',
  );

  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isRemembered = prefs.getBool('remember_user') ?? false;
    return currentUser != null && isRemembered;
  }

  Future<void> saveUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_user', true);
    if (currentUser != null) {
      await prefs.setString('user_uid', currentUser!.uid);
    }
  }

  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remember_user');
    await prefs.remove('user_uid');
  }

  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    String? gender,
    DateTime? dateOfBirth,
    double? height,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
        
        final appUser = AppUser(
          uid: userCredential.user!.uid,
          displayName: displayName,
          email: email,
          gender: gender,
          dateOfBirth: dateOfBirth,
          height: height,
          photoURL: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(appUser.toFirestore());

        await saveUserSession();
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await saveUserSession();
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final bool isAvailable = await _googleSignIn.isSignedIn();
      
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to obtain Google authentication tokens');
      }
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        try {
          final user = userCredential.user!;
          final appUser = AppUser(
            uid: user.uid,
            displayName: user.displayName ?? googleUser.displayName ?? '',
            email: user.email ?? googleUser.email,
            photoURL: user.photoURL ?? googleUser.photoUrl,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          final userDoc = await _firestore.collection('users').doc(user.uid).get();
          if (!userDoc.exists) {
            await _firestore.collection('users').doc(user.uid).set(appUser.toFirestore());
          } else {
            await _firestore.collection('users').doc(user.uid).update({
              'updatedAt': DateTime.now(),
            });
          }
        } catch (firestoreError) {
        }
        
        await saveUserSession();
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during Google Sign-In: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await clearUserSession();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  Future<void> updateUserProfile(AppUser user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}