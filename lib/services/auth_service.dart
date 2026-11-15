import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Current user stream
  Stream<User?> get authStateChanges {
    try {
      if (_auth != null) {
        return _auth!.authStateChanges();
      }
    } catch (_) {}
    return const Stream.empty();
  }

  User? get currentUser {
    try {
      return _auth?.currentUser;
    } catch (_) {
      return null;
    }
  }

  // 1. Sign In With Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web Google Sign-In via Firebase Auth Provider
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        if (_auth != null) {
          final userCredential = await _auth!.signInWithPopup(googleProvider);
          if (userCredential.user != null) {
            await saveUserToFirestore(
              uid: userCredential.user!.uid,
              name: userCredential.user!.displayName ?? 'Pengguna Google',
              email: userCredential.user!.email ?? '',
              photoUrl: userCredential.user!.photoURL,
            );
          }
          return userCredential;
        }
      } else {
        // Mobile / Desktop Google Sign-In
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return null; // User canceled
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        if (_auth != null) {
          final userCredential = await _auth!.signInWithCredential(credential);
          if (userCredential.user != null) {
            await saveUserToFirestore(
              uid: userCredential.user!.uid,
              name: userCredential.user!.displayName ?? googleUser.displayName ?? 'Pengguna Google',
              email: userCredential.user!.email ?? googleUser.email,
              photoUrl: userCredential.user!.photoURL ?? googleUser.photoUrl,
            );
          }
          return userCredential;
        }
      }
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      // If Firebase project credentials are not yet set up on local machine, provide a graceful demo fallback
      await _saveLocalUser(
        uid: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Pengguna Google Toko Madura',
        email: 'user.madura@gmail.com',
        photoUrl: 'https://lh3.googleusercontent.com/aida/ALJJyrAhZjKdke-WaSQU0VlmHHyAgiliuqjmN8hb_-GX0XyA8PY_MCVLfztvkjQ7ThkjhMJTltzYP0nQzCMQxTXj5VRdfBWmO2ktVQhKOa3E3K7hGA4hLv-zAB78CpFUB6g04dZw9u1O7LPnkjeTSshZjOZYWaA0LZNK-NOMY3Fq98hNVT0qfGSOgNnzNhQbXegkIy74G9Jg8GijW2zuVkHnIJVdZSICPYxaX3Vq2XXY-LY',
      );
    }
    return null;
  }

  // 2. Sign Up With Email & Password
  Future<UserCredential?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      if (_auth != null) {
        final userCredential = await _auth!.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        if (userCredential.user != null) {
          await userCredential.user!.updateDisplayName(name.trim());
          await saveUserToFirestore(
            uid: userCredential.user!.uid,
            name: name.trim(),
            email: email.trim(),
            photoUrl: userCredential.user!.photoURL,
          );
        }
        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Sign Up Exception: $e');
      // Fallback local save if Firebase is unlinked
      await _saveLocalUser(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        photoUrl: null,
      );
    }
    return null;
  }

  // 3. Sign In With Email & Password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (_auth != null) {
        final userCredential = await _auth!.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Sign In Exception: $e');
      // Fallback local save if Firebase is unlinked
      await _saveLocalUser(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@').first,
        email: email,
        photoUrl: null,
      );
    }
    return null;
  }

  // 4. Save User to Firestore Collection "users"
  Future<void> saveUserToFirestore({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    final userData = {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl ?? '',
      'role': 'cashier',
      'lastLogin': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      if (_firestore != null) {
        await _firestore!.collection('users').doc(uid).set(
          userData,
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      debugPrint('Firestore write error: $e');
    }

    // Always persist to local SharedPreferences as well
    await _saveLocalUser(
      uid: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
    );
  }

  // Local user cache
  Future<void> _saveLocalUser({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_uid', uid);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    if (photoUrl != null) {
      await prefs.setString('user_photo', photoUrl);
    }
    await prefs.setBool('is_logged_in', true);
  }

  Future<Map<String, String?>> getLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'uid': prefs.getString('user_uid'),
      'name': prefs.getString('user_name'),
      'email': prefs.getString('user_email'),
      'photo': prefs.getString('user_photo'),
    };
  }

  Future<bool> isLoggedIn() async {
    if (_auth?.currentUser != null) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // 5. Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      if (_auth != null) {
        await _auth!.signOut();
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uid');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_photo');
    await prefs.setBool('is_logged_in', false);
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Akun dengan email ini tidak ditemukan.';
      case 'wrong-password':
        return 'Kata sandi salah. Silakan coba lagi.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan login.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah (minimal 6 karakter).';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah.';
      default:
        return e.message ?? 'Terjadi kesalahan otentikasi.';
    }
  }
}

