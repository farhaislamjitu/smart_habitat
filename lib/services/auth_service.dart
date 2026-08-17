import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  // MainNavigation checks this flag to show "Account created" message once
  static bool justRegistered = false;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Securely updates password based on how the user logged in
  Future<void> updateUserPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No authenticated user profile session found.");
    }

    // Check if the user is a Google Sign-In user
    final isGoogleUser = user.providerData.any((info) => info.providerId == 'google.com');

    if (isGoogleUser) {
      if (user.email != null) {
        await _auth.sendPasswordResetEmail(email: user.email!);
        throw FirebaseAuthException(
          code: 'google-user-reset-sent',
          message: 'Google accounts must change passwords via Google. A reset link has been emailed to you.',
        );
      } else {
        throw Exception("Google account email not found.");
      }
    }

    // Standard Email/Password user handling
    if (user.email != null) {
      // 1. Create credential with current email and current password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      // 2. Re-authenticate user session with Firebase backend
      await user.reauthenticateWithCredential(credential);
      
      // 3. Update the password safely after validation passes
      await user.updatePassword(newPassword);
    } else {
      throw Exception("User email profile is unavailable.");
    }
  }

  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    return credential;
  }

  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (!_googleInitialized) {
      await _googleSignIn.initialize();
      _googleInitialized = true;
    }
    final googleUser = await _googleSignIn.authenticate();

    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
