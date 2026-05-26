import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_model.dart';

class UserService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  static String? get _uid => _auth.currentUser?.uid;

  /// Stream user profile (realtime)
  static Stream<UserProfileModel?> watchProfile() {
    final uid = _uid;
    if (uid == null) return Stream.value(null);
    return _usersCol.doc(uid).snapshots().map((doc) =>
        doc.exists ? UserProfileModel.fromFirestore(doc.data()!, doc.id) : null);
  }

  /// Create or update user profile
  static Future<void> saveProfile(UserProfileModel profile) async {
    await _usersCol.doc(profile.uid).set(profile.toFirestore(), SetOptions(merge: true));
  }

  /// Get user profile once
  static Future<UserProfileModel?> getProfile() async {
    final uid = _uid;
    if (uid == null) return null;
    final doc = await _usersCol.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfileModel.fromFirestore(doc.data()!, doc.id);
  }

  /// Update specific fields
  static Future<void> updateFields(Map<String, dynamic> data) async {
    final uid = _uid;
    if (uid == null) return;
    await _usersCol.doc(uid).update(data);
  }
}
