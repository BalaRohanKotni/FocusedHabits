import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_habits/components/bottom_duration_picker.dart';
import 'package:focused_habits/components/focus_session_list_tile.dart';
import 'package:focused_habits/components/heatmap_tile.dart';
import 'package:focused_habits/constants.dart';
import 'package:focused_habits/controllers/firestore_operations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late DateTime initDate;
  late int monthIndex;
  bool isDark = false;
  TextEditingController yearTextEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    initDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
    );
    yearTextEditingController.text = initDate.year.toString();
    monthIndex = initDate.month - 1;
  }

  @override
  Widget build(BuildContext context) {
    DateTime finalDate = DateTime.fromMillisecondsSinceEpoch(
        DateTime(initDate.year, initDate.month + 1).millisecondsSinceEpoch - 1);
    return Scaffold(
      backgroundColor: kAppBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          DateTime date = (await showDatePicker(
              builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      dialogBackgroundColor: kAppBackgroundColor,
                      colorScheme: (kAppBackgroundColor == Colors.white)
                          ? ColorScheme.light(
                              primary: Colors.indigo,
                              onPrimary: kAppBackgroundColor,
                              onSurface: Colors.indigo,
                            )
                          : ColorScheme.dark(
                              primary: Colors.indigo,
                              onPrimary: kAppBackgroundColor,
                              onSurface: Colors.indigo,
                            ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.indigo[400],
                        ),
                      ),
                    ),
                    child: child!,
                  ),
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1980),
              lastDate: DateTime.now()))!;

          TimeOfDay? time = TimeOfDay.now();
          time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                dialogBackgroundColor: kAppBackgroundColor,
                colorScheme: (kAppBackgroundColor == Colors.white)
                    ? ColorScheme.light(
                        primary: Colors.indigo,
                        onPrimary: kAppBackgroundColor,
                        onSurface: Colors.indigo,
                      )
                    : ColorScheme.dark(
                        primary: Colors.indigo,
                        onPrimary: kAppBackgroundColor,
                        onSurface: Colors.indigo,
                      ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.indigo[400],
                  ),
                ),
              ),
              child: child!,
            ),
          );
          date = DateTime(
              date.year, date.month, date.day, time!.hour, time.minute);

          showModalBottomSheet(
              context: context,
              builder: (bottomSheetContext) {
                return BottomDurationPickerSheet(
                  isFocus: true,
                  bottomSheetContext: bottomSheetContext,
                  habitId: "unknown",
                  habitUnits: "time",
                  date: date,
                );
              });
        },
        backgroundColor: Colors.indigo[900],
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Container(
        color: kAppBackgroundColor,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<dynamic> parentSnapshot) {
            if (!parentSnapshot.hasData) {
              return const SizedBox(
                  height: 40,
                  width: 40,
                  child: Center(child: CircularProgressIndicator()));
            }
            String theme = parentSnapshot.data!['theme'];
            if (theme == "light") {
              kAppBackgroundColor = Colors.white;
              isDark = false;
            } else {
              kAppBackgroundColor = Colors.grey[900]!;
              isDark = true;
            }
            return Container(
              margin: const EdgeInsets.only(left: 16, right: 16, top: 32),
              child: SingleChildScrollView(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection("habits")
                        .snapshots(),
                    builder: (context, habitsSnapshot) {
                      TextEditingController userNameController =
                          TextEditingController();
                      userNameController.text = parentSnapshot.data['name'];
                      userNameController.addListener(
                        () {
                          firestoreSetUserName(
                              FirebaseAuth.instance.currentUser!,
                              userNameController.text);
                        },
                      );
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: userNameController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo[400],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      isDark = !isDark;
                                      // setState(() async {
                                      if (isDark) {
                                        setState(() {
                                          kAppBackgroundColor =
                                              Colors.grey[900]!;
                                        });
                                        await firestoreSetTheme(
                                            FirebaseAuth.instance.currentUser!,
                                            "dark");
                                      } else {
                                        setState(() {
                                          kAppBackgroundColor = Colors.white;
                                        });
                                        await firestoreSetTheme(
                                            FirebaseAuth.instance.currentUser!,
                                            "light");
                                      }
                                      // });
                                    },
                                    icon: Icon(
                                        (isDark)
                                            ? Icons.sunny
                                            : Icons.nightlight,
                                        color: Colors.indigo[400]),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      FirebaseAuth.instance.signOut();
                                    },
                                    child: Text(
                                      "Logout",
                                      style: TextStyle(
                                        color: Colors.indigo[400],
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection("focusSessions")
                                  .snapshots(),
                              builder: (bContext, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: Center(
                                          child: CircularProgressIndicator()));
                                }
                                Map<DateTime, int> focusDataSets = {};
                                Map<String, dynamic> focusDataSetsInRange = {};
                                List focusSessions = snapshot.data!.docs;
                                List focusSessionsInRange = [];
                                int focusDurationInSeconds = 0;
                                int focusDurationInSecondsInRange = 0;
                                for (var sessionData in focusSessions) {
                                  DateTime entryDateTime = DateTime
                                      .fromMillisecondsSinceEpoch(sessionData[
                                          'dateTimeMillisecondsSinceEpoch']);
                                  // Here calendar heat map is not registering entries if datetime is not perfectly on a day like correct: (2024-11-08 00:00:00.000) not 2024-11-08 23:59:59.999
                                  entryDateTime = DateTime(entryDateTime.year,
                                      entryDateTime.month, entryDateTime.day);

                                  focusDataSets[entryDateTime] =
                                      (focusDataSets[entryDateTime] != null)
                                          ? focusDataSets[entryDateTime]! +
                                              sessionData[
                                                  'timeInFocusInSeconds']
                                          : sessionData['timeInFocusInSeconds'];
                                  focusDurationInSeconds += int.parse(
                                      sessionData['timeInFocusInSeconds']
                                          .toString());
                                  if (initDate.millisecondsSinceEpoch <=
                                          sessionData[
                                              'dateTimeMillisecondsSinceEpoch'] &&
                                      finalDate.millisecondsSinceEpoch >=
                                          sessionData[
                                              'dateTimeMillisecondsSinceEpoch']) {
                                    focusDurationInSecondsInRange += int.parse(
                                        sessionData['timeInFocusInSeconds']
                                            .toString());
                                    focusDataSetsInRange[sessionData['id']] =
                                        sessionData;
                                    focusSessionsInRange.add(sessionData);
                                  }
                                }

                                List<Widget> focusSessionTiles = [];
                                focusSessionsInRange.sort((a, b) => a[
                                        'dateTimeMillisecondsSinceEpoch']
                                    .compareTo(
                                        b['dateTimeMillisecondsSinceEpoch']));

                                for (int index = 0;
                                    index < focusSessionsInRange.length;
                                    index++) {
                                  {
                                    var currentHabitEntry =
                                        focusSessionsInRange[index];
                                    String formattedHabitValue =
                                        "${(currentHabitEntry['timeInFocusInSeconds'] ~/ 3600).toString()}h ${((currentHabitEntry['timeInFocusInSeconds'] % 3600) ~/ 60)}m ${((currentHabitEntry['timeInFocusInSeconds'] % 60).toInt())}s";
                                    TextEditingController focusNoteController =
                                        TextEditingController();
                                    focusNoteController.text =
                                        focusSessionsInRange[index]
                                            ['focusNote'];
                                    bool isLinkedWithHabit =
                                        focusSessionsInRange[index]
                                            ['isLinkedWithHabit'];
                                    Map habitsList = {};
                                    for (var habit
                                        in habitsSnapshot.data!.docs) {
                                      habitsList[habit['id']] = habit['name'];
                                    }
                                    String habitName = (isLinkedWithHabit &&
                                            habitsList[
                                                    focusSessionsInRange[index]
                                                        ['habitID']] !=
                                                null)
                                        ? habitsList[focusSessionsInRange[index]
                                            ['habitID']]
                                        : "";
                                    focusSessionTiles.add(
                                      FocusSessionListTile(
                                        focusSession: currentHabitEntry,
                                        formattedFocusSessionValue:
                                            formattedHabitValue,
                                        focusNote: focusNoteController.text,
                                        focusSessionsInRange:
                                            focusSessionsInRange,
                                        index: index,
                                        isLinkedWithHabit: isLinkedWithHabit,
                                        habitName: habitName,
                                        habitID: focusSessionsInRange[index]
                                            ['habitID'],
                                      ),
                                    );
                                  }
                                }

                                focusSessionTiles =
                                    focusSessionTiles.reversed.toList();

                                focusSessions.sort((a, b) => a[
                                        'dateTimeMillisecondsSinceEpoch']
                                    .compareTo(
                                        b['dateTimeMillisecondsSinceEpoch']));
                                focusSessions = focusSessions.reversed.toList();
                                String formattedTotalFocusDuration =
                                    "${(focusDurationInSeconds ~/ 3600).toString()}h ${((focusDurationInSeconds % 3600) ~/ 60)}m ${((focusDurationInSeconds % 60).toInt())}s";
                                String formattedRangeFocusDuration =
                                    "${(focusDurationInSecondsInRange ~/ 3600).toString()}h ${((focusDurationInSecondsInRange % 3600) ~/ 60)}m ${((focusDurationInSecondsInRange % 60).toInt())}s";
                                return SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      HeatMapTile(
                                        habitName: "Focus",
                                        context: bContext,
                                        dataSets: focusDataSets,
                                        date: DateTime.now(),
                                        habitId: "unknown",
                                        showAddEntry: false,
                                        showHabitName: true,
                                        habitUnits: "time",
                                        size: ((MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    13.5) >
                                                34)
                                            ? 34
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                13.5,
                                        bottomWidget: Container(),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Total time in focus: $formattedTotalFocusDuration",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.indigo[400],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: 2,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 0,
                                        ),
                                        // width: double.maxFinite,
                                        color: Colors.grey[300],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              children: [
                                                const SizedBox(
                                                  height: 2,
                                                ),
                                                SizedBox(
                                                  width: 60,
                                                  height: 33,
                                                  child: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        initDate = DateTime(
                                                          initDate.year - 1,
                                                          monthIndex + 1,
                                                        );
                                                        yearTextEditingController
                                                                .text =
                                                            initDate.year
                                                                .toString();
                                                      });
                                                    },
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    style: ButtonStyle(
                                                      shape: WidgetStateProperty
                                                          .all<
                                                              RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                      ),
                                                    ),
                                                    icon: Icon(
                                                      Icons.arrow_drop_up,
                                                      size: 24,
                                                      color: Colors.indigo[400],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 65,
                                                  child: TextField(
                                                    onChanged:
                                                        (String newValue) {
                                                      setState(() {
                                                        if (yearTextEditingController
                                                            .text.isEmpty) {
                                                          yearTextEditingController
                                                              .text = '0';
                                                        } else {
                                                          yearTextEditingController
                                                              .text = int.parse(
                                                                  newValue)
                                                              .toString();
                                                        }
                                                        initDate = DateTime(
                                                            int.parse(
                                                                yearTextEditingController
                                                                    .text),
                                                            monthIndex + 1);
                                                      });
                                                    },
                                                    controller:
                                                        yearTextEditingController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.indigo[400],
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    decoration: const InputDecoration(
                                                        border:
                                                            OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide
                                                                        .none),
                                                        isDense: true,
                                                        contentPadding:
                                                            EdgeInsets.all(0),
                                                        labelText: "Year",
                                                        floatingLabelBehavior:
                                                            FloatingLabelBehavior
                                                                .never),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 60,
                                                  height: 30,
                                                  child: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        initDate = DateTime(
                                                          initDate.year + 1,
                                                          monthIndex + 1,
                                                        );
                                                        yearTextEditingController
                                                                .text =
                                                            initDate.year
                                                                .toString();
                                                      });
                                                    },
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    style: ButtonStyle(
                                                      shape: WidgetStateProperty
                                                          .all<
                                                              RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                      ),
                                                    ),
                                                    icon: Icon(
                                                      Icons.arrow_drop_down,
                                                      size: 24,
                                                      color: Colors.indigo[400],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Expanded(
                                              child: Column(
                                            children: [
                                              SizedBox(
                                                width: 60,
                                                height: 30,
                                                child: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      monthIndex =
                                                          (monthIndex > 0)
                                                              ? monthIndex - 1
                                                              : monthIndex;
                                                      initDate = DateTime(
                                                          int.parse(
                                                              yearTextEditingController
                                                                  .text),
                                                          monthIndex + 1);
                                                    });
                                                  },
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  style: ButtonStyle(
                                                    shape: WidgetStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                    ),
                                                  ),
                                                  icon: Icon(
                                                    Icons.arrow_drop_up,
                                                    size: 24,
                                                    color: Colors.indigo[400],
                                                  ),
                                                ),
                                              ),
                                              DropdownButton(
                                                isDense: true,
                                                underline: Container(),
                                                icon: Container(),
                                                value: monthIndex,
                                                items: months.map((month) {
                                                  return DropdownMenuItem(
                                                    alignment: Alignment.center,
                                                    value:
                                                        months.indexOf(month),
                                                    child: Text(
                                                      month,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.indigo[400],
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (newMonthIndex) {
                                                  setState(() {
                                                    monthIndex = newMonthIndex!;
                                                    initDate = DateTime(
                                                        int.parse(
                                                            yearTextEditingController
                                                                .text),
                                                        monthIndex + 1);
                                                  });
                                                },
                                              ),
                                              SizedBox(
                                                width: 60,
                                                height: 26,
                                                child: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      monthIndex =
                                                          (monthIndex < 11)
                                                              ? monthIndex + 1
                                                              : monthIndex;
                                                      initDate = DateTime(
                                                          int.parse(
                                                              yearTextEditingController
                                                                  .text),
                                                          monthIndex + 1);
                                                    });
                                                  },
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  style: ButtonStyle(
                                                    shape: WidgetStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                    ),
                                                  ),
                                                  icon: Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 24,
                                                    color: Colors.indigo[400],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ))
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Time in focus in ${months[monthIndex]} ${yearTextEditingController.text} : ",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.indigo[400],
                                            ),
                                          ),
                                          Text(
                                            formattedRangeFocusDuration,
                                            style: TextStyle(
                                                color: Colors.indigo[400]),
                                          ),
                                        ],
                                      ),
                                      ...focusSessionTiles,
                                    ],
                                  ),
                                );
                              }),
                        ],
                      );
                    }),
              ),
            );
          },
        ),
      ),
    );
  }
}
