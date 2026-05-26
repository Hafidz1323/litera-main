import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'models/user_profile_model.dart';
import 'services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 1. LOGIN GOOGLE
  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return "Login dibatalkan";

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // 2. REGISTER
  Future<String> register(String email, String password, String name) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        // Create profile in Firestore
        final profile = UserProfileModel(
          uid: user.uid,
          displayName: name,
          email: email,
          createdAt: DateTime.now(),
        );
        await UserService.saveProfile(profile);
      }

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Terjadi kesalahan";
    }
  }

  // 3. LOGIN EMAIL
  Future<String> login(String email, String password) async {
    try {
      UserCredential credential =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      // Sync profile if missing
      final user = credential.user;
      if (user != null) {
        final existing = await UserService.getProfile();
        if (existing == null) {
          final profile = UserProfileModel(
            uid: user.uid,
            displayName: user.displayName ?? 'Pembaca',
            email: email,
            createdAt: DateTime.now(),
          );
          await UserService.saveProfile(profile);
        }
      }
      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Email atau Password salah";
    }
  }

  // 4. LOGOUT
  Future<void> signOut() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error saat logout: $e");
    }
  }

  // 5. RESET PASSWORD 
  Future<String> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "Email tidak terdaftar";
      } else if (e.code == 'invalid-email') {
        return "Format email tidak valid";
      }
      return "Terjadi kesalahan";
    } catch (e) {
      return "Gagal mengirim email";
    }
  }
}
