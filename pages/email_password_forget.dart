import 'package:chatapp/componet/my_button.dart';
import 'package:chatapp/componet/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/pages/login_page.dart';

class emailforgetpassword extends StatefulWidget {
  const emailforgetpassword({super.key});

  @override
  State<emailforgetpassword> createState() => _emailforgetpasswordState();
}

class _emailforgetpasswordState extends State<emailforgetpassword> {

  String email = "" ;
  final emailC = TextEditingController();
  final _foemkey = GlobalKey<FormState>();
  resetpassword() async {
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Check email To Reset Password ",style: TextStyle(fontSize: 20),)));
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(onTap: (){},)));
    }on FirebaseAuthException catch(e){
      if(e.code == "user-not-found") {}
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("user-not-found",style: TextStyle(fontSize: 20),)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .surface,
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.surface,),
        body: SingleChildScrollView(
          child: Center(
              child: Form(
                key: _foemkey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    const Center(child: Image(image: AssetImage("assets/images/pass.png"),height: 190,)),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 25,left: 25),
                          child: Text(
                            "Foegte Password",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 25,left: 25,bottom: 10),
                          child: Text(
                            "Select one of the option given below to reser your password.",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    MyTextField(
                      hintText: "E-Mail",
                      obscure: false,
                      controller: emailC,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MyButton(
                      text: "Send To Email",
                      onTap: (){
                        if(_foemkey.currentState!.validate()){
                          setState(() {
                            email = emailC.text ;
                          });
                        }
                        resetpassword();
                      },
                    ),
                  ],
                ),
              ),
            ),
        ));
  }
}
