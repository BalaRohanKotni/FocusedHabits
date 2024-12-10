import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_habits/components/heatmap_tile.dart';
import 'package:focused_habits/constants.dart';
import 'package:focused_habits/controllers/firestore_operations.dart';
import 'package:intl/intl.dart';

class HabitScreen extends StatefulWidget {
  final String habitId;
  const HabitScreen({super.key, required this.habitId});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  TextEditingController habitNameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    habitNameController.addListener(() {
      firestoreUpdateHabit(
        user: FirebaseAuth.instance.currentUser!,
        updatedHabit: {'name': habitNameController.text},
        id: widget.habitId,
      );
    });
  }

  @override
  void dispose() {
    habitNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: kAppBackgroundColor,
        width: double.maxFinite,
        child: StreamBuilder<Object>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection("habits")
                .doc(widget.habitId)
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                    height: 40,
                    width: 40,
                    child: Center(child: CircularProgressIndicator()));
              }
              var habitDocument = snapshot.data!;
              habitNameController.text = habitDocument['name'];

              Map<DateTime, int> habitDataSets = {};
              List habitEntries = [];
              int habitValue = 0;
              for (int i = 0; i < habitDocument['entries'].length; i++) {
                DateTime entryDateTime = DateTime.fromMillisecondsSinceEpoch(
                    habitDocument['entries'][i]
                        ['dateTimeMillisecondsSinceEpoch']);
                // Here calendar heat map is not registering entries if datetime is not perfectly on a day like correct: (2024-11-08 00:00:00.000) not 2024-11-08 23:59:59.999
                entryDateTime = DateTime(
                    entryDateTime.year, entryDateTime.month, entryDateTime.day);
                habitEntries.add(habitDocument['entries'][i]);
                habitDataSets[entryDateTime] =
                    (habitDataSets[entryDateTime] != null)
                        ? habitDataSets[entryDateTime]! +
                            habitDocument['entries'][i]['value']
                        : habitDocument['entries'][i]['value'];
                habitValue +=
                    int.parse(habitDocument['entries'][i]['value'].toString());
              }
              habitEntries.sort((a, b) => a['dateTimeMillisecondsSinceEpoch']
                  .compareTo(b['dateTimeMillisecondsSinceEpoch']));
              habitEntries = habitEntries.reversed.toList();
              String formattedHabitValue = (habitDocument['units'] == "time")
                  ? "${(habitValue ~/ 3600).toString()}h ${((habitValue % 3600) ~/ 60)}m ${((habitValue % 60).toInt())}s"
                  : "$habitValue";

              return Container(
                color: kAppBackgroundColor,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.indigo[400],
                              )),
                          Container(),
                          IconButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await Future.delayed(
                                  const Duration(milliseconds: 200));
                              await firestoreDeleteHabit(
                                  user: FirebaseAuth.instance.currentUser!,
                                  id: widget.habitId);
                            },
                            icon: Icon(
                              Icons.delete_forever,
                              color: Colors.indigo[400],
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: habitNameController,
                                      style: TextStyle(
                                        color: Colors.indigo[400],
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              HeatMapTile(
                                habitName: habitNameController.text,
                                showHabitName: false,
                                showAddEntry: true,
                                context: context,
                                dataSets: habitDataSets,
                                date: DateTime.now(),
                                habitId: widget.habitId,
                                habitUnits: habitDocument['units'],
                                size: ((MediaQuery.of(context).size.width /
                                            14) >
                                        30)
                                    ? 30
                                    : MediaQuery.of(context).size.width / 14,
                                bottomWidget: Container(),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Total ${habitDocument['units']}: $formattedHabitValue",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.indigo[400],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 16),
                                width: double.maxFinite,
                                child: Text(
                                  "History",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo[400],
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: habitDocument['entries'].length,
                                  itemBuilder: (bcontext, index) {
                                    var currentHabitEntry = habitEntries[index];
                                    String formattedHabitValue = (habitDocument[
                                                'units'] ==
                                            "time")
                                        ? "${(currentHabitEntry['value'] ~/ 3600).toString()}h ${((currentHabitEntry['value'] % 3600) ~/ 60)}m ${((currentHabitEntry['value'] % 60).toInt())}s"
                                        : "${currentHabitEntry['value']}";
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: (kAppBackgroundColor ==
                                                Colors.white)
                                            ? Colors.grey[100]
                                            : Colors.grey[850],
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: ListTile(
                                        key: Key(currentHabitEntry[
                                                'dateTimeMillisecondsSinceEpoch']
                                            .toString()),
                                        title: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Text(
                                                  DateFormat('MMM dd, y')
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              currentHabitEntry[
                                                                  'dateTimeMillisecondsSinceEpoch'])),
                                                  style: TextStyle(
                                                    color: Colors.indigo[400],
                                                  ),
                                                ),
                                                Text(
                                                  "${DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(currentHabitEntry['dateTimeMillisecondsSinceEpoch']))} - $formattedHabitValue",
                                                  style: TextStyle(
                                                    color: Colors.indigo[400],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete_forever,
                                                size: 20,
                                                color: Colors.indigo[400],
                                              ),
                                              onPressed: () {
                                                List newList = [
                                                  ...habitEntries
                                                ];
                                                newList.removeAt(index);
                                                firestoreUpdateEntryInHabit(
                                                  user: FirebaseAuth
                                                      .instance.currentUser!,
                                                  newEntryData: newList,
                                                  habitId: widget.habitId,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
