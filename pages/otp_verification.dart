import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OTPscreen extends StatelessWidget {
  const OTPscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        padding: const EdgeInsets.all(1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "CO",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 60),
            ),
            SizedBox(height: 0,),
            const Text(
              "DE",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 60),
            ),
            const Text(
              "Verificaton",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 2,),

            const Text(
              "Enter the Verification code sent at emailid@gmail.com",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const  SizedBox(height: 20,),

            OtpTextField(
              numberOfFields: 6,
              fillColor: Colors.black12,
              filled: true,
              keyboardType: TextInputType.number,
              borderColor: Colors.black,
              onSubmit: (code){if (kDebugMode) {
                print("OTP is $code ");
              }},
            ),
            const SizedBox(height: 30,),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 25,right: 25),
                child: ElevatedButton(onPressed: (){},
                  style: OutlinedButton.styleFrom(
                    elevation: 10,
                    shadowColor: Colors.black,
                    shape: const RoundedRectangleBorder(),
                  ), child: const Text("Conform"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
