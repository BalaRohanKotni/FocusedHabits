import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_habits/constants.dart';
import 'package:focused_habits/controllers/firestore_operations.dart';
import 'package:google_fonts/google_fonts.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen>
    with AutomaticKeepAliveClientMixin {
  int selectedHabitIndex = 0;
  List<Map<String, dynamic>> habits = [
    {'id': 'unknown', 'name': 'None'}
  ];

  FocusNode habitPickerFocusNode = FocusNode();

  // duration in seconds
  int duration = 3661;
  int timeInFocus = 0;

  bool isTimer = true;

  FocusSessionStatus sessionStatus = FocusSessionStatus.inactive;

  TextEditingController hoursController = TextEditingController(),
      minutesController = TextEditingController(),
      secondsController = TextEditingController(),
      focusNoteController = TextEditingController();

  late Timer _timer;
  bool isTimerRunning = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    hoursController.text = "0";
    minutesController.text = "0";
    secondsController.text = "0";
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      isTimerRunning = true;
      if (duration == 0) {
        setState(() {
          stopTimer();
        });
      } else {
        setState(() {
          duration--;
          timeInFocus++;
        });
      }
    });
  }

  void startStopwatch() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      isTimerRunning = true;
      // if (duration == 0) {
      //   setState(() {
      //     stopTimer();
      //   });
      // } else {
      setState(() {
        duration++;
        timeInFocus++;
      });
      // }
    });
  }

  void stopTimer() async {
    _timer.cancel();
    isTimerRunning = false;
    sessionStatus = FocusSessionStatus.inactive;
    DateTime now = DateTime.now();

    Map<String, dynamic> focusSessionData = {
      "dateTimeMillisecondsSinceEpoch": now.millisecondsSinceEpoch,
      "timeInFocusInSeconds": timeInFocus,
      "focusNote": focusNoteController.text,
      "isLinkedWithHabit": (selectedHabitIndex != 0) ? true : false,
      "habitID": habits[selectedHabitIndex]['id'],
    };
    String id = await firestoreCreateFocusSession(
      user: FirebaseAuth.instance.currentUser!,
      sessionData: focusSessionData,
    );
    if (habits[selectedHabitIndex]['id'] != 'unknown') {
      await firestoreAddEntryToHabit(
        user: FirebaseAuth.instance.currentUser!,
        newEntryData: {
          "dateTimeMillisecondsSinceEpoch": now.millisecondsSinceEpoch,
          "isLinkedWithFocusSession": true,
          "focusSessionID": id,
          "value":
              (habits[selectedHabitIndex]['units'] == "time") ? timeInFocus : 1
        },
        habitId: habits[selectedHabitIndex]['id'],
      );
    }
    setState(() {
      timeInFocus = 0;
      duration = 0;
    });
  }

  @override
  void dispose() {
    if (isTimerRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  Widget durationWidget(String abbr) {
    TextEditingController controller = TextEditingController();
    if (abbr == 'h') {
      controller = hoursController;
    } else if (abbr == 'm') {
      controller = minutesController;
    } else if (abbr == 's') {
      controller = secondsController;
    }
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6, left: 6),
        child: Container(
          margin: const EdgeInsets.only(right: 12, left: 12),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  // color: Colors.indigo[100],
                ),
                width: double.maxFinite,
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        if (abbr == 'h') {
                          duration += 3600;
                        } else if (abbr == 'm') {
                          duration += 60;
                        } else if (abbr == 's') {
                          duration += 1;
                        }
                      });
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(
                            width: 2,
                            color: Colors.indigo[300]!,
                          ),
                        ),
                      ),
                    ),
                    icon: Icon(Icons.add,
                        size: MediaQuery.of(context).size.width / 16,
                        color: Colors.indigo[400])),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: 2,
                    color: Colors.indigo[300]!,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(
                    right: 12,
                    left: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: TextField(
                          textAlign: TextAlign.end,
                          cursorColor: Colors.indigo[400],
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                          controller: controller,
                          style: GoogleFonts.lato(
                            fontSize: MediaQuery.of(context).size.width / 14,
                            color: Colors.indigo[400],
                          ),
                          onChanged: (value) {
                            if (abbr == 'h') {
                              hoursController.text =
                                  (value.isNotEmpty) ? value : "0";
                            } else if (abbr == 'm') {
                              minutesController.text =
                                  (value.isNotEmpty) ? value : "0";
                            } else if (abbr == 's') {
                              secondsController.text =
                                  (value.isNotEmpty) ? value : "0";
                            }
                            setState(() {
                              duration =
                                  int.parse(hoursController.text) * 3600 +
                                      int.parse(minutesController.text) * 60 +
                                      int.parse(secondsController.text);
                            });
                          },
                        ),
                      ),
                      Text(
                        abbr,
                        style: GoogleFonts.lato(
                            fontSize: MediaQuery.of(context).size.width / 18,
                            color: Colors.indigo[400]),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  // color: Colors.indigo[100],
                ),
                width: double.maxFinite,
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        if (abbr == 'h' && duration >= 3600) {
                          duration -= 3600;
                        } else if (abbr == 'm' && duration >= 60) {
                          duration -= 60;
                        } else if (abbr == 's' && duration >= 1) {
                          duration -= 1;
                        }
                      });
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(
                            width: 2,
                            color: Colors.indigo[300]!,
                          ),
                        ),
                      ),
                    ),
                    icon: Icon(Icons.remove,
                        size: MediaQuery.of(context).size.width / 16,
                        color: Colors.indigo[400])),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    hoursController.text = (duration ~/ 3600).toString();
    minutesController.text = ((duration % 3600) ~/ 60).toString();
    secondsController.text = ((duration % 60).toInt()).toString();

    // var habits = (await firestoreGetHabitsFromUser(
    //               user: FirebaseAuth.instance.currentUser!))
    //           .toList();
    //       firestoreAddEntryToHabit(
    //         user: FirebaseAuth.instance.currentUser!,
    //         newEntryData: {
    //           "dateTimeMillisecondsSinceEpoch":
    //               DateTime.now().millisecondsSinceEpoch,
    //           "isLinkedWithFocusSession": false,
    //           "focusSessionID": "unknown",
    //         },
    //         habitId: habits[1]['id'],
    //       );

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot> documentSnapshot) {
        if (!documentSnapshot.hasData) {
          return const SizedBox(
              height: 40,
              width: 40,
              child: Center(child: CircularProgressIndicator()));
        }
        String theme = documentSnapshot.data!['theme'];
        if (theme == "light") {
          kAppBackgroundColor = Colors.white;
        } else {
          kAppBackgroundColor = Colors.grey[900]!;
        }
        return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(firestoreCollection)
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection("habits")
                .snapshots(),
            builder: (context, collectionSnapshot) {
              if (!collectionSnapshot.hasData) {
                return const SizedBox(
                    height: 40,
                    width: 40,
                    child: Center(child: CircularProgressIndicator()));
              }

              habits = [
                {'id': 'unknown', 'name': 'None'}
              ];

              for (var element in collectionSnapshot.data!.docs) {
                habits.add(element.data());
              }
              return LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: Container(
                    color: kAppBackgroundColor,
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 16, right: 16, top: 36, bottom: 36),
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      color: kAppBackgroundColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // const Text(
                          //   "Hi Rohan",
                          // ),
                          // const TabBar(
                          //   tabs: [
                          //     Text("Timer"),
                          //     Text("Stopwatch"),
                          //   ],
                          // ),
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
                                            FirebaseAuth.instance.currentUser!,
                                            1);
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: TextButton(
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                          (isTimer)
                                              ? Colors.indigo[100]
                                              : kAppBackgroundColor),
                                      shape: WidgetStateProperty.all(
                                          const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      )))),
                                  onPressed: () {
                                    setState(() {
                                      isTimer = true;
                                      duration = 0;
                                      if (isTimerRunning) _timer.cancel();
                                      sessionStatus =
                                          FocusSessionStatus.inactive;
                                      isTimerRunning = false;
                                    });
                                  },
                                  child: Text(
                                    "Timer",
                                    style: GoogleFonts.lato(
                                        color: Colors.indigo[800]),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                          (!isTimer)
                                              ? Colors.indigo[100]
                                              : kAppBackgroundColor),
                                      shape: WidgetStateProperty.all(
                                          const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      )))),
                                  onPressed: () {
                                    setState(() {
                                      isTimer = false;
                                      duration = 0;
                                      if (isTimerRunning) _timer.cancel();
                                      sessionStatus =
                                          FocusSessionStatus.inactive;
                                    });
                                  },
                                  child: Text(
                                    "Stopwatch",
                                    style: GoogleFonts.lato(
                                        color: Colors.indigo[800]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // SizedBox(
                          //   height: 24,
                          // ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.indigo[100],
                                borderRadius: BorderRadius.only(
                                  bottomLeft: const Radius.circular(8),
                                  bottomRight: const Radius.circular(8),
                                  topRight: Radius.circular((isTimer) ? 8 : 0),
                                  topLeft: Radius.circular((!isTimer) ? 8 : 0),
                                )),
                            child: Container(
                              margin:
                                  const EdgeInsets.only(top: 24, bottom: 16),
                              child: (isTimer)
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        durationWidget('h'),
                                        durationWidget('m'),
                                        durationWidget('s'),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              hoursController.text,
                                              style: GoogleFonts.lato(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    14,
                                                color: Colors.indigo[400],
                                              ),
                                            ),
                                            Text(
                                              "h",
                                              style: GoogleFonts.lato(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          18,
                                                  color: Colors.indigo[400]),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              minutesController.text,
                                              style: GoogleFonts.lato(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    14,
                                                color: Colors.indigo[400],
                                              ),
                                            ),
                                            Text(
                                              "m",
                                              style: GoogleFonts.lato(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          18,
                                                  color: Colors.indigo[400]),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              secondsController.text,
                                              style: GoogleFonts.lato(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    14,
                                                color: Colors.indigo[400],
                                              ),
                                            ),
                                            Text(
                                              "s",
                                              style: GoogleFonts.lato(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          18,
                                                  color: Colors.indigo[400]),
                                            ),
                                          ],
                                        ),
                                        // durationWidget('h'),
                                        // durationWidget('m'),
                                        // durationWidget('s'),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(
                            height: 36,
                          ),
                          TextField(
                              controller: focusNoteController,
                              style:
                                  GoogleFonts.lato(color: Colors.indigo[400]),
                              cursorColor: Colors.indigo[400],
                              decoration: InputDecoration(
                                hintText: 'Note',
                                hintStyle:
                                    GoogleFonts.lato(color: Colors.indigo[400]),
                              )),
                          const SizedBox(
                            height: 36,
                          ),
                          (sessionStatus == FocusSessionStatus.active ||
                                  sessionStatus == FocusSessionStatus.paused)
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      "Time in focus: ${timeInFocus ~/ 3600}h ${(timeInFocus % 3600) ~/ 60}m ${(timeInFocus % 60)}s",
                                      style: GoogleFonts.lato(
                                        color: Colors.indigo[400],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    (sessionStatus == FocusSessionStatus.paused)
                                        ? ElevatedButton(
                                            style: ButtonStyle(
                                              shape:
                                                  const WidgetStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12)))),
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      Colors.indigo[900]),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                sessionStatus =
                                                    FocusSessionStatus.active;
                                                (isTimer)
                                                    ? startTimer()
                                                    : startStopwatch();
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Text(
                                                "Resume",
                                                style: GoogleFonts.lato(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          )
                                        : ElevatedButton(
                                            style: ButtonStyle(
                                              shape:
                                                  const WidgetStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12)))),
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      Colors.indigo[900]),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                sessionStatus =
                                                    FocusSessionStatus.paused;
                                                _timer.cancel();
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Text(
                                                "Pause",
                                                style: GoogleFonts.lato(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        shape: const WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12)))),
                                        backgroundColor: WidgetStatePropertyAll(
                                            Colors.indigo[900]),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          stopTimer();
                                          sessionStatus =
                                              FocusSessionStatus.inactive;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          "Stop",
                                          style: GoogleFonts.lato(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        shape: const WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12)))),
                                        backgroundColor: WidgetStatePropertyAll(
                                            Colors.indigo[900]),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _timer.cancel();
                                          sessionStatus =
                                              FocusSessionStatus.inactive;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          "Cancel",
                                          style: GoogleFonts.lato(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ElevatedButton(
                                  style: ButtonStyle(
                                    shape: const WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12)))),
                                    // backgroundColor:
                                    //     WidgetStatePropertyAll(Colors.indigo[900]),
                                    backgroundColor: WidgetStatePropertyAll(
                                        Colors.indigo[900]),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      sessionStatus = FocusSessionStatus.active;
                                      timeInFocus = 0;
                                      if (!isTimer) duration = 0;
                                      (isTimer)
                                          ? startTimer()
                                          : startStopwatch();
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      "Start",
                                      style:
                                          GoogleFonts.lato(color: Colors.white),
                                    ),
                                  ),
                                ),
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: [
                              Text(
                                "Link with habit: ",
                                style:
                                    GoogleFonts.lato(color: Colors.indigo[400]),
                              ),
                              DropdownButton(
                                dropdownColor:
                                    (kAppBackgroundColor == Colors.white)
                                        ? Colors.grey[200]
                                        : Colors.grey[850],
                                focusNode: habitPickerFocusNode,
                                value: selectedHabitIndex,
                                items: habits
                                    .map((habit) => DropdownMenuItem(
                                          value: habits.indexOf(habit),
                                          child: Text(
                                            habit['name']!,
                                            style: GoogleFonts.lato(
                                                color: Colors.indigo[400]),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (int? selectedValue) {
                                  setState(() {
                                    selectedHabitIndex = selectedValue!;
                                    habitPickerFocusNode.unfocus();
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}
