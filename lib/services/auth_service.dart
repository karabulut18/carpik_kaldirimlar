import 'package:carpik_kaldirimlar/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _firebaseUser;
  AppUser? _appUser;

  AuthService() {
    _auth.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        await _fetchUserData(user.uid);
      } else {
        _appUser = null;
      }
      notifyListeners();
    });
  }

  bool get isLoggedIn => _firebaseUser != null;
  bool get isAdmin => _appUser?.isAdmin ?? false;
  
  // Expose the full user object if needed, or keeping getters for compatibility for now
  AppUser? get currentUser => _appUser;
  
  String? get currentUserName => _appUser?.name ?? _firebaseUser?.displayName ?? _firebaseUser?.email?.split('@')[0];
  String? get currentUserEmail => _appUser?.email ?? _firebaseUser?.email;
  String? get currentUserId => _firebaseUser?.uid;
  String? get currentBio => _appUser?.bio;

  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _appUser = AppUser.fromMap(doc.id, doc.data()!);
      } else {
        _appUser = null;
      }
    } catch (e) {
      debugPrint('User data fetch error: $e');
      _appUser = null;
    }
  }

  Future<void> _syncUserToFirestore(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      final newAppUser = AppUser(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? user.email?.split('@')[0] ?? 'User',
        role: 'user',
      );
      
      await userDoc.set({
        ...newAppUser.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Update local state immediately
      _appUser = newAppUser; 
    } else {
       // Ideally we refresh local _appUser here too
       _appUser = AppUser.fromMap(docSnapshot.id, docSnapshot.data()!);
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Sync listener will handle the rest, but explicit sync ensures data is ready
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
      _firebaseUser = _auth.currentUser;
      
      if (_firebaseUser != null) {
        await _syncUserToFirestore(_firebaseUser!);
      }

      notifyListeners();
      
    } catch (e) {
      debugPrint('Register Error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _appUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(String name, {String? bio}) async {
    try {
      if (_firebaseUser == null) return;

      if (_firebaseUser?.displayName != name) {
        await _firebaseUser?.updateDisplayName(name);
        await _firebaseUser?.reload();
        _firebaseUser = _auth.currentUser;
      }
      
      final updates = <String, dynamic>{'name': name};
      if (bio != null) {
        updates['bio'] = bio;
      }
      
      await _firestore.collection('users').doc(_firebaseUser!.uid).update(updates);
      
      // Update local state
      if (_appUser != null) {
        // Create a new instance with updated fields (immutability pattern)
        _appUser = AppUser(
          id: _appUser!.id,
          email: _appUser!.email,
          name: name,
          role: _appUser!.role,
          bio: bio ?? _appUser!.bio,
          createdAt: _appUser!.createdAt
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Update Profile Error: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      UserCredential? credential;
      
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        credential = await _auth.signInWithPopup(authProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) return; 

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential cred = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        credential = await _auth.signInWithCredential(cred);
      }

      if (credential?.user != null) {
        await _syncUserToFirestore(credential!.user!);
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }
  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.id, doc.data()!);
      }
    } catch (e) {
      debugPrint('Error fetching user $uid: $e');
    }
    return null;
  }
}
