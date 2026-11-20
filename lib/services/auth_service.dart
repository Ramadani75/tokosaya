import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotRegisteredException implements Exception {
  final String message;
  final String email;
  final String name;

  UserNotRegisteredException(this.message, {this.email = '', this.name = ''});

  @override
  String toString() => message;
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _ensureDefaultRegisteredUsers();
  }

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

  // Ensure default registered accounts (e.g. Kasir default)
  Future<void> _ensureDefaultRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('registered_users');
    if (usersJson == null || usersJson.isEmpty) {
      final defaultList = [
        {
          'uid': 'cashier_001',
          'name': 'Kasir Cak Arip',
          'email': 'kasir@tokomadura.com',
          'password': '123456',
          'provider': 'email',
          'photoUrl': '',
          'role': 'cashier',
          'registeredAt': DateTime.now().toIso8601String(),
        }
      ];
      await prefs.setString('registered_users', jsonEncode(defaultList));
    }
  }

  // Check if a user is registered in Database (Firestore or Local Database)
  Future<bool> isUserRegistered({String? email, String? uid}) async {
    final cleanEmail = email?.trim().toLowerCase() ?? '';
    final cleanUid = uid?.trim() ?? '';

    if (cleanEmail.isEmpty && cleanUid.isEmpty) return false;

    // 1. Check in Cloud Firestore
    if (_firestore != null) {
      try {
        if (cleanUid.isNotEmpty) {
          final doc = await _firestore!.collection('users').doc(cleanUid).get();
          if (doc.exists) return true;
        }
        if (cleanEmail.isNotEmpty) {
          final query = await _firestore!
              .collection('users')
              .where('email', isEqualTo: cleanEmail)
              .limit(1)
              .get();
          if (query.docs.isNotEmpty) return true;
        }
      } catch (e) {
        debugPrint('Firestore check error: $e');
      }
    }

    // 2. Check in Local SharedPreferences registered_users
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('registered_users');
    if (usersJson != null && usersJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(usersJson);
        for (var item in list) {
          final uEmail = (item['email'] as String? ?? '').toLowerCase();
          final uUid = item['uid'] as String? ?? '';
          if ((cleanEmail.isNotEmpty && uEmail == cleanEmail) ||
              (cleanUid.isNotEmpty && uUid == cleanUid)) {
            return true;
          }
        }
      } catch (_) {}
    }

    return false;
  }

  // Retrieve user data if registered
  Future<Map<String, dynamic>?> getRegisteredUserData({String? email, String? uid}) async {
    final cleanEmail = email?.trim().toLowerCase() ?? '';
    final cleanUid = uid?.trim() ?? '';

    // Check Firestore
    if (_firestore != null) {
      try {
        if (cleanUid.isNotEmpty) {
          final doc = await _firestore!.collection('users').doc(cleanUid).get();
          if (doc.exists && doc.data() != null) {
            return doc.data();
          }
        }
        if (cleanEmail.isNotEmpty) {
          final query = await _firestore!
              .collection('users')
              .where('email', isEqualTo: cleanEmail)
              .limit(1)
              .get();
          if (query.docs.isNotEmpty) {
            return query.docs.first.data();
          }
        }
      } catch (_) {}
    }

    // Check Local
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('registered_users');
    if (usersJson != null && usersJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(usersJson);
        for (var item in list) {
          final uEmail = (item['email'] as String? ?? '').toLowerCase();
          final uUid = item['uid'] as String? ?? '';
          if ((cleanEmail.isNotEmpty && uEmail == cleanEmail) ||
              (cleanUid.isNotEmpty && uUid == cleanUid)) {
            return Map<String, dynamic>.from(item);
          }
        }
      } catch (_) {}
    }

    return null;
  }

  // Register user into Database
  Future<void> registerUserInDatabase({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
    String? password,
    required String provider,
  }) async {
    final nowIso = DateTime.now().toIso8601String();
    final cleanEmail = email.trim().toLowerCase();

    // 1. Save to Cloud Firestore
    if (_firestore != null) {
      try {
        await _firestore!.collection('users').doc(uid).set({
          'uid': uid,
          'name': name.trim(),
          'email': cleanEmail,
          'photoUrl': photoUrl ?? '',
          'role': 'cashier',
          'provider': provider,
          'registered': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore write error: $e');
      }
    }

    // 2. Save to Local registered_users
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('registered_users');
    List<Map<String, dynamic>> usersList = [];
    if (usersJson != null && usersJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(usersJson);
        usersList = list.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (_) {}
    }

    final index = usersList.indexWhere((u) =>
        (u['email'] as String? ?? '').toLowerCase() == cleanEmail ||
        (u['uid'] as String? ?? '') == uid);

    final userEntry = {
      'uid': uid,
      'name': name.trim(),
      'email': cleanEmail,
      'photoUrl': photoUrl ?? '',
      if (password != null) 'password': password,
      'provider': provider,
      'role': 'cashier',
      'registeredAt': nowIso,
    };

    if (index >= 0) {
      usersList[index] = userEntry;
    } else {
      usersList.add(userEntry);
    }
    await prefs.setString('registered_users', jsonEncode(usersList));

    // 3. Save as current active session
    await _saveLocalUser(
      uid: uid,
      name: name.trim(),
      email: cleanEmail,
      photoUrl: photoUrl,
    );
  }

  // Attempt Google Sign-In Account Retrieval
  Future<Map<String, String>?> getGoogleAccountDetails() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        if (_auth != null) {
          final userCredential = await _auth!.signInWithPopup(googleProvider);
          final u = userCredential.user;
          if (u != null) {
            return {
              'uid': u.uid,
              'name': u.displayName ?? 'Pengguna Google',
              'email': u.email ?? '',
              'photoUrl': u.photoURL ?? '',
            };
          }
        }
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser != null) {
          String uid = 'google_${googleUser.id}';
          if (_auth != null) {
            try {
              final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
              final AuthCredential credential = GoogleAuthProvider.credential(
                accessToken: googleAuth.accessToken,
                idToken: googleAuth.idToken,
              );
              final uc = await _auth!.signInWithCredential(credential);
              if (uc.user != null) {
                uid = uc.user!.uid;
              }
            } catch (_) {}
          }
          return {
            'uid': uid,
            'name': googleUser.displayName ?? 'Pengguna Google',
            'email': googleUser.email,
            'photoUrl': googleUser.photoUrl ?? '',
          };
        }
      }
    } catch (e) {
      debugPrint('Native Google SignIn error: $e');
    }
    return null;
  }

  // LOGIN WITH GOOGLE (Must be registered first!)
  Future<void> signInWithGoogleAccount({
    required String email,
    required String name,
    required String uid,
    String? photoUrl,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // STRICT CHECK: Is user registered in database?
    final registered = await isUserRegistered(email: cleanEmail, uid: uid);
    if (!registered) {
      // Abort Google auth session
      try {
        await _googleSignIn.signOut();
        await _auth?.signOut();
      } catch (_) {}

      throw UserNotRegisteredException(
        'Akun Google ($cleanEmail) belum terdaftar! Anda belum mempunyai akun. Silakan klik "Daftar Sekarang" terlebih dahulu.',
        email: cleanEmail,
        name: name,
      );
    }

    // User is registered! Fetch full details if available
    final existingData = await getRegisteredUserData(email: cleanEmail, uid: uid);
    final finalName = existingData?['name'] as String? ?? name;
    final finalPhoto = existingData?['photoUrl'] as String? ?? photoUrl;

    // Update lastLogin in Firestore
    if (_firestore != null) {
      try {
        await _firestore!.collection('users').doc(uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }

    // Save active login session
    await _saveLocalUser(
      uid: uid,
      name: finalName,
      email: cleanEmail,
      photoUrl: finalPhoto,
    );
  }

  // REGISTER WITH GOOGLE (Called from Register screen)
  Future<void> registerWithGoogleAccount({
    required String email,
    required String name,
    required String uid,
    String? photoUrl,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // Check if already registered
    final alreadyRegistered = await isUserRegistered(email: cleanEmail, uid: uid);
    if (alreadyRegistered) {
      throw 'Akun Google ($cleanEmail) sudah terdaftar! Silakan langsung login di halaman Masuk.';
    }

    // Register user to database and start active session
    await registerUserInDatabase(
      uid: uid,
      name: name,
      email: cleanEmail,
      photoUrl: photoUrl,
      provider: 'google',
    );
  }

  // REGISTER WITH EMAIL & PASSWORD
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // Check if already registered
    final alreadyRegistered = await isUserRegistered(email: cleanEmail);
    if (alreadyRegistered) {
      throw 'Email ini ($cleanEmail) sudah terdaftar! Silakan langsung masuk ke akun Anda.';
    }

    String uid = 'user_${DateTime.now().millisecondsSinceEpoch}';

    if (_auth != null) {
      try {
        final uc = await _auth!.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        if (uc.user != null) {
          uid = uc.user!.uid;
          await uc.user!.updateDisplayName(name.trim());
        }
      } on FirebaseAuthException catch (e) {
        throw _handleAuthException(e);
      } catch (_) {}
    }

    await registerUserInDatabase(
      uid: uid,
      name: name.trim(),
      email: cleanEmail,
      password: password,
      provider: 'email',
    );
  }

  // LOGIN WITH EMAIL & PASSWORD
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Check if user is registered in Database
    final isReg = await isUserRegistered(email: cleanEmail);
    if (!isReg) {
      throw UserNotRegisteredException(
        'Akun dengan email ($cleanEmail) belum terdaftar! Anda belum mempunyai akun. Silakan mendaftar terlebih dahulu.',
        email: cleanEmail,
      );
    }

    // 2. Validate password
    if (_auth != null) {
      try {
        final uc = await _auth!.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        if (uc.user != null) {
          await _saveLocalUser(
            uid: uc.user!.uid,
            name: uc.user!.displayName ?? cleanEmail.split('@').first,
            email: cleanEmail,
            photoUrl: uc.user!.photoURL,
          );
          return;
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          throw UserNotRegisteredException(
            'Akun dengan email ($cleanEmail) belum terdaftar! Anda belum mempunyai akun.',
            email: cleanEmail,
          );
        }
        throw _handleAuthException(e);
      } catch (_) {}
    }

    // Local DB verification
    final user = await getRegisteredUserData(email: cleanEmail);
    if (user != null) {
      final savedPass = user['password'] as String?;
      if (savedPass != null && savedPass != password) {
        throw 'Kata sandi salah. Silakan coba lagi.';
      }
      await _saveLocalUser(
        uid: user['uid'] as String? ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: user['name'] as String? ?? cleanEmail.split('@').first,
        email: cleanEmail,
        photoUrl: user['photoUrl'] as String?,
      );
      return;
    }

    throw 'Gagal memverifikasi akun.';
  }

  // Save current active user session
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
    if (photoUrl != null && photoUrl.isNotEmpty) {
      await prefs.setString('user_photo', photoUrl);
    } else {
      await prefs.remove('user_photo');
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
    final prefs = await SharedPreferences.getInstance();
    final bool loggedIn = prefs.getBool('is_logged_in') ?? false;
    if (_auth?.currentUser != null && loggedIn) return true;
    return loggedIn;
  }

  // SIGN OUT (Clears active session only, does NOT delete registered accounts)
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
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
        return 'Akun belum terdaftar. Anda belum mempunyai akun.';
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
