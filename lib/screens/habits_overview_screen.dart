import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_habits/components/heatmap_tile.dart';
import 'package:focused_habits/components/new_habit_bottomsheet.dart';
import 'package:focused_habits/constants.dart';
import 'package:focused_habits/controllers/firestore_operations.dart';
import 'package:focused_habits/screens/habit_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                documentSnapshot) {
          if (!documentSnapshot.hasData) {
            return const SizedBox(
                height: 40,
                width: 40,
                child: Center(child: CircularProgressIndicator()));
          }
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection("habits")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                    height: 40,
                    width: 40,
                    child: Center(child: CircularProgressIndicator()));
              }
              List orderedHabitsList = [];
              orderedHabitsList = snapshot.data!.docs;
              orderedHabitsList.sort(
                  (a, b) => a.data()['index'].compareTo(b.data()['index']));
              return Scaffold(
                backgroundColor: kAppBackgroundColor,
                body: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PopupMenuButton(
                          color: kAppBackgroundColor,
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.indigo[400],
                          ),
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                onTap: () {
                                  firestoreSetDefaultTabIndex(
                                      FirebaseAuth.instance.currentUser!, 2);
                                },
                                child: Text(
                                  "Set this screen on launch",
                                  style: GoogleFonts.lato(
                                    color: Colors.indigo[400],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ];
                          },
                        )
                      ],
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: ReorderableGridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                (MediaQuery.of(context).size.width ~/ 370 > 0)
                                    ? MediaQuery.of(context).size.width ~/ 370
                                    : 1,
                            childAspectRatio: 1,
                            mainAxisExtent: 382,
                          ),
                          // shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          onReorder: (oldIndex, newIndex) async {
                            List originalList = [...orderedHabitsList];
                            final element =
                                orderedHabitsList.removeAt(oldIndex);
                            orderedHabitsList.insert(newIndex, element);
                            for (int index = 0;
                                index < orderedHabitsList.length;
                                index++) {
                              if (originalList[index] ==
                                  orderedHabitsList[index]) {
                              } else {
                                firestoreUpdateHabit(
                                  user: FirebaseAuth.instance.currentUser!,
                                  updatedHabit: {'index': index},
                                  id: orderedHabitsList[index]['id'],
                                );
                              }
                            }
                          },
                          itemBuilder: (context, index) {
                            Map<DateTime, int> habitDataSets = {};
                            for (int i = 0;
                                i < orderedHabitsList[index]['entries'].length;
                                i++) {
                              DateTime entryDateTime =
                                  DateTime.fromMillisecondsSinceEpoch(
                                      orderedHabitsList[index]['entries'][i]
                                          ['dateTimeMillisecondsSinceEpoch']);
                              // Here calendar heat map is not registering entries if datetime is not perfectly on a day like correct: (2024-11-08 00:00:00.000) not 2024-11-08 23:59:59.999
                              entryDateTime = DateTime(entryDateTime.year,
                                  entryDateTime.month, entryDateTime.day);

                              habitDataSets[entryDateTime] =
                                  (habitDataSets[entryDateTime] != null)
                                      ? habitDataSets[entryDateTime]! +
                                          orderedHabitsList[index]['entries'][i]
                                              ['value']
                                      : orderedHabitsList[index]['entries'][i]
                                          ['value'];
                            }
                            return HeatMapTile(
                              key: ValueKey(orderedHabitsList[index]['id']),
                              habitName: orderedHabitsList[index]['name'],
                              showHabitName: true,
                              showAddEntry: true,
                              habitUnits: orderedHabitsList[index]['units'],
                              date: DateTime.now(),
                              context: context,
                              dataSets: habitDataSets,
                              habitId: orderedHabitsList[index]['id'],
                              size: ((MediaQuery.of(context).size.width /
                                          13.5) >
                                      34)
                                  ? 34
                                  : MediaQuery.of(context).size.width / 13.5,
                              bottomWidget: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => HabitScreen(
                                                    habitId:
                                                        orderedHabitsList[index]
                                                            ['id'],
                                                  )));
                                    },
                                    child: Text(
                                      "More Details",
                                      style: GoogleFonts.lato(
                                          color: Colors.indigo[400]),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: Colors.indigo[900],
                  onPressed: () async {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) => NewHabitBottomSheet(
                              bottomSheetContext: context,
                            ));
                  },
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              );
            },
          );
        });
  }
}
