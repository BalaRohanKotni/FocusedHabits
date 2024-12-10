import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:focused_habits/screens/home_screen.dart';
import 'package:focused_habits/screens/signin_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // kAppBackgroundColor = Colors.white;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AppScreen());
}

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // Unregister the observer to avoid memory leaks.
  }

  // @override
  // void didChangePlatformBrightness() {
  //   super.didChangePlatformBrightness();
  //   // Call your function whenever the system theme changes.
  //   print(MediaQuery.of(context).platformBrightness);
  //   final isDarkMode =
  //       MediaQuery.of(context).platformBrightness == Brightness.dark;
  //   setState(() {

  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // FirebaseAuth.instance.signOut();
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const SignInScreen();
          }
        },
      ),
      //
    );
  }
}
