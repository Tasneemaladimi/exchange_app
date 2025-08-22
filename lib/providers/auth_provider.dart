import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isInitialized = false;
  bool isLoggedIn = false;

  AuthProvider() {
    _auth.authStateChanges().listen((User? u) {
      user = u;
      isLoggedIn = user != null;
      isInitialized = true;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    user = cred.user;
    isLoggedIn = user != null;
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    user = cred.user;
    isLoggedIn = user != null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    user = null;
    isLoggedIn = false;
    notifyListeners();
  }
}
