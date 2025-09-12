import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isLoading = true;

  AuthProvider() {
    _auth.authStateChanges().listen((User? firebaseUser) {
      user = firebaseUser;
      isLoading = false;
      notifyListeners();
    });
  }

  bool get isLoggedIn => user != null;

  // معرف المستخدم الذي سيتم استخدامه مع العناصر
  String get userId {
    if (user == null) return "";
    return user!.uid;
  }

  // اسم المستخدم الحقيقي
  String get userName {
    if (user == null) return "User";
    if (user!.displayName != null && user!.displayName!.isNotEmpty) {
      return user!.displayName!;
    }
    // إذا ما في displayName نستخدم البريد قبل @
    return user!.email!.split('@')[0];
  }

  Future<void> login({required String email, required String password}) async {
    try {
      isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      user = _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({required String email, required String password}) async {
    try {
      isLoading = true;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      user = _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    user = null;
    notifyListeners();
  }
}
