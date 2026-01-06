import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isAdmin = false;
  String? _bio;

  AuthService() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _fetchUserData(user.uid);
      } else {
        _isAdmin = false;
        _bio = null;
      }
      notifyListeners();
    });
  }

  bool get isLoggedIn => _user != null;
  bool get isAdmin => _isAdmin;
  String? get currentUserName => _user?.displayName ?? _user?.email?.split('@')[0];
  String? get currentUserEmail => _user?.email;
  String? get currentUserId => _user?.uid;
  String? get currentBio => _bio;

  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        _isAdmin = data?['role'] == 'admin';
        _bio = data?['bio'];
      } else {
        _isAdmin = false;
        _bio = null;
      }
    } catch (e) {
      debugPrint('User data fetch error: $e');
      _isAdmin = false;
      _bio = null;
    }
  }

  Future<void> _syncUserToFirestore(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? user.email?.split('@')[0],
        'role': 'user', // Default role
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }



  Future<void> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Sync on login too, just in case
      if (credential.user != null) {
        await _syncUserToFirestore(credential.user!);
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
      _user = _auth.currentUser;
      
      if (_user != null) {
        await _syncUserToFirestore(_user!);
      }

      notifyListeners();
      
    } catch (e) {
      debugPrint('Register Error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> updateProfile(String name, {String? bio}) async {
    try {
      if (_user?.displayName != name) {
        await _user?.updateDisplayName(name);
        await _user?.reload();
        _user = _auth.currentUser;
      }
      
      // Update name and bio in Firestore
      if (_user != null) {
        final updates = <String, dynamic>{'name': name};
        if (bio != null) {
          updates['bio'] = bio;
        }
        await _firestore.collection('users').doc(_user!.uid).update(updates);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Update Profile Error: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        final credential = await _auth.signInWithPopup(authProvider);
         if (credential.user != null) {
          await _syncUserToFirestore(credential.user!);
        }
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) return; // User canceled

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          await _syncUserToFirestore(userCredential.user!);
        }
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }
}
