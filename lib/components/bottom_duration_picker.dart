import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_habits/constants.dart';
import 'package:focused_habits/controllers/firestore_operations.dart';

class BottomDurationPickerSheet extends StatefulWidget {
  final String? habitId, habitUnits;
  final bool isFocus;
  final BuildContext bottomSheetContext;
  final DateTime date;
  const BottomDurationPickerSheet(
      {super.key,
      required this.habitId,
      required this.habitUnits,
      required this.bottomSheetContext,
      required this.date,
      required this.isFocus});

  @override
  State<BottomDurationPickerSheet> createState() =>
      _BottomDurationPickerSheetState();
}

class _BottomDurationPickerSheetState extends State<BottomDurationPickerSheet> {
  int duration = 0;

  TextEditingController hoursController = TextEditingController(),
      minutesController = TextEditingController(),
      secondsController = TextEditingController(),
      focusNoteController = TextEditingController();
  @override
  void initState() {
    super.initState();
    hoursController.text = "0";
    minutesController.text = "0";
    secondsController.text = "0";
  }

  @override
  Widget build(BuildContext context) {
    hoursController.text = (duration ~/ 3600).toString();
    minutesController.text = ((duration % 3600) ~/ 60).toString();
    secondsController.text = ((duration % 60).toInt()).toString();
    return Container(
      decoration: BoxDecoration(
        color: (kAppBackgroundColor == Colors.white)
            ? Colors.grey[200]
            : Colors.grey[850],
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(27), topRight: Radius.circular(27)),
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Duration: ",
              style: TextStyle(
                color: Colors.indigo[400],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                durationWidget('h'),
                durationWidget('m'),
                durationWidget('s'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(widget.bottomSheetContext);
                  },
                  child: Text("Cancel",
                      style: TextStyle(color: Colors.indigo[400])),
                ),
                TextButton(
                  onPressed: () async {
                    if (!widget.isFocus) {
                      await firestoreAddEntryToHabit(
                        user: FirebaseAuth.instance.currentUser!,
                        habitId: widget.habitId!,
                        newEntryData: {
                          "dateTimeMillisecondsSinceEpoch":
                              widget.date.millisecondsSinceEpoch,
                          "isLinkedWithFocusSession": false,
                          "focusSessionID": "unknown",
                          "value": (widget.habitUnits == "time") ? duration : 1
                        },
                      );
                    } else {
                      Map<String, dynamic> focusSessionData = {
                        "dateTimeMillisecondsSinceEpoch":
                            widget.date.millisecondsSinceEpoch,
                        "timeInFocusInSeconds": duration,
                        "focusNote": focusNoteController.text,
                        "isLinkedWithHabit": false,
                        "habitID": "unknown",
                      };
                      await firestoreCreateFocusSession(
                        user: FirebaseAuth.instance.currentUser!,
                        sessionData: focusSessionData,
                      );
                    }
                    // ignore: use_build_context_synchronously
                    Navigator.pop(widget.bottomSheetContext);
                  },
                  child: const Text(
                    "Add",
                    style: TextStyle(color: Color(0xFF02925D)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                  color: Colors.indigo[100],
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
                        ),
                      ),
                    ),
                    icon: Icon(
                      Icons.add,
                      size: MediaQuery.of(context).size.width / 16,
                      color: Colors.indigo[900],
                    )),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.indigo[100],
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
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 14,
                            color: Colors.indigo[900],
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
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 18,
                          color: Colors.indigo[900],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.indigo[100],
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
                        ),
                      ),
                    ),
                    icon: Icon(
                      Icons.remove,
                      size: MediaQuery.of(context).size.width / 16,
                      color: Colors.indigo[900],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
