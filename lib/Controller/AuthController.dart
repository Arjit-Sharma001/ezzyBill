import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezzybill/Screens/AutyhScreen/VerifyEmailScreen.dart';
import 'package:ezzybill/consts/firebaseConst.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;

  // Text controllers for login inputs
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  // Dispose controllers to avoid memory leaks
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Login method using email and password
  Future<UserCredential?> loginMethod({required BuildContext context}) async {
    UserCredential? userCredential;
    try {
      userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorToast(context, e.message ?? "Login failed");
      print("Error: ${e.message}");
    }
    return userCredential;
  }

// 🔹 Login with Google
  Future<UserCredential?> googleLoginMethod(
      {required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // user canceled login

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Sign in to Firebase
      final userCredential = await auth.signInWithCredential(credential);

      // Store user data in Firestore
      await storeUserData(
        name: userCredential.user?.displayName ?? "Unknown User",
        email: userCredential.user?.email ?? "Unknown Email",
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _showErrorToast(context, e.message ?? "Google login failed");
      print("FirebaseAuth Error: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      _showErrorToast(context, "Something went wrong: $e");
      print("General Error: $e");
      return null;
    }
  }

  // 🔹 Login with Facebook
  Future<UserCredential?> facebookLoginMethod(
      {required BuildContext context}) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);

        final userCredential = await auth.signInWithCredential(credential);

        await storeUserData(
          name: userCredential.user?.displayName ?? "Unknown User",
          email: userCredential.user?.email ?? "Unknown Email",
        );

        return userCredential;
      } else if (result.status == LoginStatus.cancelled) {
        _showErrorToast(context, "Facebook login cancelled");
        return null;
      } else {
        _showErrorToast(context, "Facebook login failed: ${result.message}");
        return null;
      }
    } catch (e) {
      _showErrorToast(context, "Facebook login error: $e");
      print("Facebook login error: $e");
      return null;
    }
  }

  // Sign up method
  Future<UserCredential?> signUpMethod({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    UserCredential? userCredential;
    try {
      userCredential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorToast(context, e.message ?? "Signup failed");
    }
    return userCredential;
  }

// 🔹 Verify and check email logic
  Future<void> sendEmailVerification(BuildContext context, String email) async {
    try {
      // Step 1: Check if email already exists in Firestore
      bool alreadyExists = await isEmailRegistered(context, email);
      if (alreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This email is already registered.")),
        );
        return;
      }

      // Step 2: Create a temporary Firebase user (for verification)
      const tempPassword = "TempPass@123";
      UserCredential tempUserCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: tempPassword);

      User? tempUser = tempUserCredential.user;

      // Step 3: Send verification email
      await tempUser?.sendEmailVerification();

      // Step 4: Delete temporary user to avoid storing unverified users
      // await tempUser?.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Verification link sent to $email. Please verify."),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    }
  }

// 🔹 Check if an email already exists in Firestore
  Future<bool> isEmailRegistered(BuildContext context, String email) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      return false;
    }
  }

  // Forget Pass method
  Future<UserCredential?> forgetMethod({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        "Password Reset",
        "A reset link has been sent to $email. Check your inbox.",
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 4),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorToast(context, e.message ?? "Forget link failed");
    }
  }

  // Store user data in Firestore **without storing password**
  Future<void> storeUserData({
    required String name,
    required String email,
  }) async {
    final user = currentUser;
    if (user == null) return; // Safety check

    final DocumentReference store =
        firestore.collection(usersCollection).doc(user.uid);

    // Removed password storage for security
    await store.set({
      'name': name.trim(),
      'email': email.trim(),
      'profileUrl': '2', // placeholder
      'id': user.uid,
      'createdAt': Timestamp.now(),
    });
  }

  // Sign out method
  Future<void> signOutMethod(BuildContext context) async {
    try {
      await auth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      _showErrorToast(context, e.toString());
    }
  }

  // Common function to show error messages via SnackBar
  void _showErrorToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.redAccent,
    ));
  }
}
