import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import '../componet/my_button.dart';
import '../componet/my_textfield.dart';
import 'package:email_otp/email_otp.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  EmailOTP myauth =  EmailOTP();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _cpwdController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _register() async {
    final String email = _emailController.text.trim();
    final String password = _pwdController.text.trim();
    final String confirmPassword = _cpwdController.text.trim();
    final String phone = _phoneController.text.trim();

    // Validate email
    if (!EmailValidator.validate(email)) {
      return _showErrorDialog("Invalid email address.");
    }

    // Validate phone number (basic validation: length and digits)
    if (phone.isEmpty || phone.length < 10 || phone.length > 12 || !RegExp(r'^\d+$').hasMatch(phone)) {
      return _showErrorDialog("Invalid phone number.");
    }

    // Validate password and confirm password match
    if (password != confirmPassword) {
      return _showErrorDialog("Passwords don't match.");
    }

    if (password.isEmpty || password.length < 8 || password.length > 15 ) {
      return _showErrorDialog("Week Password");
    }

    // If all validations pass, proceed with registration
    final auth = AuthService();
    try {
      auth.signUpWithEmailPassword(email, password, phone);
      // Optionally, you can navigate to another page or show a success message
    } catch (e) {
      return _showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(padding: EdgeInsets.only(top: 150)),
              const Icon(
                Icons.message,
                size: 60,
              ),
              const SizedBox(
                height: 50,
              ),
              MyTextField(
                hintText: "Email",
                obscure: false,
                controller: _emailController,
              ),
              const SizedBox(
                height: 10,
              ),
              MyTextField(
                hintText: "Phone No.",
                obscure: false,
                controller: _phoneController,
              ),
              const SizedBox(
                height: 10,
              ),
              MyTextField(
                hintText: "Password",
                obscure: true,
                controller: _pwdController,
              ),
              const SizedBox(
                height: 10,
              ),
              MyTextField(
                hintText: "Confirm Password",
                obscure: true,
                controller: _cpwdController,
              ),
              const SizedBox(
                height: 10,
              ),
              MyButton(
                text: "Register",
                onTap: _register,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  GestureDetector(
                    onTap: () => widget.onTap?.call(),
                    child: Text(
                      "Login",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
