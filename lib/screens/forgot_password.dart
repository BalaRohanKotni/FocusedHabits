// ignore_for_file: use_build_context_synchronously

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_habits/constants.dart';
import 'package:focused_habits/screens/signup_screen.dart';

class ForgotPassword extends StatefulWidget {
  final String email;
  const ForgotPassword({super.key, required this.email});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  final _scrollController = ScrollController();
  Future resetPassword() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));
    bool networkStatus = await hasNetwork();
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent.")));
      Navigator.popUntil(context, (route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      String error = firebaseExceptionHandler(e, networkStatus);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              SizedBox(
                height: (MediaQuery.sizeOf(context).height >=
                        MediaQuery.sizeOf(context).width)
                    ? MediaQuery.sizeOf(context).height / 4
                    : MediaQuery.sizeOf(context).width / 4,
                child: Container(
                  // color: kPurpleLightShade,
                  width: double.maxFinite,
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    margin: const EdgeInsets.only(left: 18),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.start,
                      direction: Axis.vertical,
                      children: [
                        Text(
                          "Reset Password",
                          style: semiBold18().copyWith(
                            fontSize: 38,
                            // color: kPurpleDarkShade,
                          ),
                        ),
                        const Text(
                          "Recieve an email to reset password",
                          style: TextStyle(
                              // color: kPurpleDarkShade,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: (MediaQuery.sizeOf(context).height >=
                        MediaQuery.sizeOf(context).width)
                    ? MediaQuery.sizeOf(context).height * 3 / 4
                    : MediaQuery.sizeOf(context).width * 3 / 4,
                child: SafeArea(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                          ),
                          validator: (email) =>
                              email != "" && !EmailValidator.validate(email!)
                                  ? 'Enter a valid email'
                                  : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: emailController,
                        ),
                        SizedBox(
                          height: 50,
                          child: TextButton(
                            onPressed: resetPassword,
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.indigo[900]),
                                foregroundColor:
                                    WidgetStateProperty.all(Colors.white),
                                shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)))),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Reset password",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          child: Wrap(
                            alignment: WrapAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Sign in",
                                  style: semiBold18()
                                      .copyWith(fontWeight: FontWeight.normal),
                                ),
                              ),
                              const Text("or"),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignupScreen()));
                                },
                                child: Text(
                                  "Sign up",
                                  style: semiBold18()
                                      .copyWith(fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
