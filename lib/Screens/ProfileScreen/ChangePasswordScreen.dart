import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ezzybill/consts/consts.dart';
import 'package:ezzybill/widgetsCommon/CustomTextFieldAuth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> changePassword() async {
    final oldPass = oldPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (newPass != confirmPass) {
      Get.snackbar("Error", "New passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        Get.snackbar("Error", "User not logged in");
        setState(() => isLoading = false);
        return;
      }

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPass,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPass);
      Get.snackbar("Success", "Password updated successfully");
      Get.back();
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Password update failed");
    } catch (e) {
      Get.snackbar("Error", "Unexpected error: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        backgroundColor: primaryColor2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              customTextFieldAuth(
                controller: oldPasswordController,
                title: "Old Password",
                isPass: true,
              ),
              const SizedBox(height: 12),
              customTextFieldAuth(
                controller: newPasswordController,
                title: "New Password",
                isPass: true,
              ),
              const SizedBox(height: 12),
              customTextFieldAuth(
                controller: confirmPasswordController,
                title: "Confirm New Password",
                isPass: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : changePassword,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: primaryColor2),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Update Password"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
