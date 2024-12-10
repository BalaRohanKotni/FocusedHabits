// ignore_for_file: use_build_context_synchronously

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_habits/constants.dart';
import 'package:focused_habits/screens/signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController emailController = TextEditingController(),
      passwordController = TextEditingController();
  final _scrollController = ScrollController();

  Future signIn() async {
    bool networkStatus = await hasNetwork();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Signed in!")));
    } on FirebaseAuthException catch (e) {
      String error = firebaseExceptionHandler(e, networkStatus);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
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
                  child: const Text(
                    "Sign in to your Account",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 38,
                      color: Color(0xFF2e86ab),
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
                      TextField(
                          controller: passwordController,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          style: const TextStyle(fontSize: 16),
                          onSubmitted: (_) => signIn(),
                          decoration: const InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder())),
                      SizedBox(
                        height: 50,
                        child: TextButton(
                          onPressed: () {
                            signIn();
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
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "Sign in",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Wrap(
                        alignment: WrapAlignment.end,
                        children: [
                          Container(),
                          MaterialButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              // TODO Forgot password
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => ForgotPassword(
                              //             email: emailController.text)));
                            },
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(color: Color(0xFF058ed9)),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        "or",
                        style: TextStyle(
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
                            const Text(
                              "New?",
                              style: TextStyle(fontSize: 16),
                            ),
                            MaterialButton(
                              padding: const EdgeInsets.only(left: 8),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              enableFeedback: false,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignupScreen()));
                              },
                              child: const Text(
                                "Create an account",
                                style: TextStyle(color: Color(0xFF058ed9)),
                                // style: TextStyle(
                                //     color: kPurpleDarkShade, fontSize: 16),
                              ),
                            )
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
