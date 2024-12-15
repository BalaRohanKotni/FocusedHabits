// ignore_for_file: use_build_context_synchronously

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_habits/constants.dart';
import 'package:focused_habits/controllers/firestore_operations.dart';
import 'package:focused_habits/screens/verifyemail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController(),
      passwordController = TextEditingController(),
      nameController = TextEditingController();
  final _scrollController = ScrollController();

  Future signUp() async {
    bool networkStatus = await hasNetwork();
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());
      firestoreCreateUserCollection(userCredential.user!, nameController.text);
    } on FirebaseAuthException catch (e) {
      String error = firebaseExceptionHandler(e, networkStatus);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => VerifyEmailScreen(
                    email: emailController.text.trim(),
                  )));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(children: [
            SizedBox(
              height: (MediaQuery.sizeOf(context).height >=
                      MediaQuery.sizeOf(context).width)
                  ? MediaQuery.sizeOf(context).height / 4
                  : MediaQuery.sizeOf(context).width / 4,
              child: Container(
                width: double.maxFinite,
                alignment: Alignment.bottomLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 18),
                  child: Text(
                    "Create a new Account",
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w600,
                      fontSize: 38,
                      color: const Color(0xFF2e86ab),
                    ),
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
                  margin: const EdgeInsets.only(left: 18, right: 18),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 32,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(),
                        ),
                        controller: nameController,
                      ),
                      const SizedBox(
                        height: 32,
                      ),
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
                      const SizedBox(
                        height: 32,
                      ),
                      TextField(
                          controller: passwordController,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          style: GoogleFonts.lato(fontSize: 16),
                          onSubmitted: (_) => signUp(),
                          decoration: const InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder())),
                      const SizedBox(
                        height: 48,
                      ),
                      SizedBox(
                        height: 50,
                        child: TextButton(
                          onPressed: () {
                            signUp();
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.indigo[900]),
                              foregroundColor:
                                  WidgetStateProperty.all(Colors.white),
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "Sign up",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        "or",
                        style: GoogleFonts.lato(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        width: double.maxFinite,
                        child: Wrap(
                          spacing: 4,
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: GoogleFonts.lato(fontSize: 16),
                            ),
                            MaterialButton(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              enableFeedback: false,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Sign in",
                                style: GoogleFonts.lato(
                                    color: const Color(0xFF058ed9)),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
