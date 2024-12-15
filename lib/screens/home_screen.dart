import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_habits/screens/focus_screen.dart';
import 'package:focused_habits/screens/habits_overview_screen.dart';
import 'package:focused_habits/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isScrollable = false;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
                height: 40,
                width: 40,
                child: Center(child: CircularProgressIndicator()));
          }
          int defaultTabIndex =
              int.parse(snapshot.data!['defaultTabIndex'].toString());
          return DefaultTabController(
            length: 3,
            initialIndex: defaultTabIndex,
            child: Scaffold(
              body: const TabBarView(
                children: [
                  ProfileScreen(),
                  FocusScreen(),
                  HabitsScreen(),
                ],
              ),
              bottomNavigationBar: Container(
                color: Colors.indigo[100],
                child: TabBar(
                    labelColor: Colors.indigo[900],
                    indicatorColor: Colors.indigo[900],
                    unselectedLabelColor: Colors.grey[600],
                    isScrollable: isScrollable,
                    tabs: const [
                      Tab(icon: Icon(Icons.person), text: "Profile"),
                      Tab(icon: Icon(Icons.self_improvement), text: "Focus"),
                      Tab(icon: Icon(Icons.book), text: "Habits"),
                    ],
                    indicatorWeight: 5,
                    indicatorSize: TabBarIndicatorSize.label),
              ),
            ),
          );
        });
  }
}
