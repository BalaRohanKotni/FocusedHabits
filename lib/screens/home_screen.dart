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
    return DefaultTabController(
      length: 3,
      initialIndex: 2,
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
  }
}
