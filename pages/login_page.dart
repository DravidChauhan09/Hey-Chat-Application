import 'package:chatapp/pages/email_password_forget.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/componet/my_textfield.dart';
import 'package:flutter/material.dart';
import '../componet/my_button.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;


  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  void login(BuildContext context) async {
    // auth service
    final authservice = AuthService();

    // try login
    try {
      await authservice.signInWithEmailPassword(
          _emailController.text, _pwdController.text);
    }

    // catch the error
    catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
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
              const SizedBox(height: 100,),
              const Image(image: AssetImage("assets/images/login.png"),height: 200,),
              const SizedBox(height: 13,),
              MyTextField(
                hintText: "Email",
                obscure: false,
                controller: _emailController,
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
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const emailforgetpassword()));
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10,right: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Forget Password ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              MyButton(
                text: "Login",
                onTap: () => login(context),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: widget.onTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member? ",
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                    Text(
                      "Register now",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
