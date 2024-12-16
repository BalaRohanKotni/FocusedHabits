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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool isScrollable = false;
  bool hideTabBar = false;
  bool firstBuild = true;
  late TabController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

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
          if (firstBuild) {
            _controller.index =
                int.parse(snapshot.data!['defaultTabIndex'].toString());
            firstBuild = false;
          }

          return DefaultTabController(
            length: 3,
            child: Builder(builder: (context) {
              if (_controller.index == 2) {
                hideTabBar = snapshot.data!['hideTabBarInHabitsOverview'];
              }
              _controller.addListener(() {
                if (_controller.index == 2) {
                  hideTabBar = snapshot.data!['hideTabBarInHabitsOverview'];
                } else {
                  hideTabBar = false;
                }
                setState(() {});
              });
              return Scaffold(
                body: TabBarView(
                  controller: _controller,
                  children: const [
                    ProfileScreen(),
                    FocusScreen(),
                    HabitsScreen(),
                  ],
                ),
                bottomNavigationBar: Container(
                  color: Colors.indigo[100],
                  child: (!hideTabBar)
                      ? TabBar(
                          controller: _controller,
                          labelColor: Colors.indigo[900],
                          indicatorColor: Colors.indigo[900],
                          unselectedLabelColor: Colors.grey[600],
                          isScrollable: isScrollable,
                          tabs: const [
                            Tab(icon: Icon(Icons.person), text: "Profile"),
                            Tab(
                                icon: Icon(Icons.self_improvement),
                                text: "Focus"),
                            Tab(icon: Icon(Icons.book), text: "Habits"),
                          ],
                          indicatorWeight: 5,
                          indicatorSize: TabBarIndicatorSize.label)
                      : Container(
                          height: 2,
                          width: 2,
                        ),
                ),
              );
            }),
          );
        });
  }
}
