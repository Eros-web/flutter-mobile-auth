import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register user ke Firebase Auth + simpan profil ke Firestore
  Future<bool> register(String email, String password, String username, String phone) async {
    try {
      print('[Register] Mulai: email=$email');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = userCredential.user!.uid;
      print('[Register] UID baru: $uid');

      await _firestore.collection('users').doc(uid).set({
        'email': email.trim(),
        'username': username.trim(),
        'phone': phone.trim(),
        'gender': '',
        'birthdate': '',
        'photo': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('logged_in_uid', uid);

      print('[Register] Profil Firestore + UID disimpan ke SharedPreferences');
      return true;
    } on FirebaseAuthException catch (e) {
      print('[Register Error] ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('[Register Error] $e');
      return false;
    }
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    try {
      print('[Login] Mulai: email=$email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = userCredential.user!.uid;
      print('[Login] UID login: $uid');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('logged_in_uid', uid);

      print('[Login] UID disimpan ke SharedPreferences');
      return true;
    } on FirebaseAuthException catch (e) {
      print('[Login Error] ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('[Login Error] $e');
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('logged_in_uid');
    await _auth.signOut();
    print('[Logout] Selesai.');
  }

  /// Cek status login
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    print('[isLoggedIn] $isLoggedIn');
    return isLoggedIn;
  }

  /// Ambil UID user login
  Future<String?> getCurrentUID() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('logged_in_uid');
    print('[getCurrentUID] UID: $uid');
    return uid;
  }

  /// Ambil detail user Firestore
  Future<Map<String, dynamic>?> getUserDetails(String uid) async {
    print('[getUserDetails] Ambil data untuk UID: $uid');
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        print('[getUserDetails] Data ditemukan: $data');
        return data;
      } else {
        print('[getUserDetails] Dokumen TIDAK ADA.');
        return null;
      }
    } catch (e) {
      print('[getUserDetails ERROR] $e');
      return null;
    }
  }

  /// Update profil
  Future<void> updateUserDetails(String uid, Map<String, dynamic> updatedData) async {
    print('[updateUserDetails] Update UID: $uid => $updatedData');
    await _firestore.collection('users').doc(uid).update(updatedData);

    if (updatedData.containsKey('password')) {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.updatePassword(updatedData['password']);
      }
    }
  }
}

final authService = AuthService();
