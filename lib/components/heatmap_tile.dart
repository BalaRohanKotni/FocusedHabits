import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_habits/components/bottom_duration_picker.dart';
import 'package:focused_habits/components/heatmap_calendar.dart';
import 'package:focused_habits/constants.dart';
import 'package:focused_habits/controllers/firestore_operations.dart';

class HeatMapTile extends StatefulWidget {
  final DateTime date;
  final DateTime? initDate;
  final BuildContext context;
  final Map<DateTime, int> dataSets;
  final String habitName, habitId, habitUnits;
  final bool showHabitName, showAddEntry;
  final double size;
  final Widget bottomWidget;
  const HeatMapTile({
    super.key,
    required this.habitName,
    required this.context,
    required this.dataSets,
    required this.date,
    required this.habitId,
    required this.habitUnits,
    required this.size,
    required this.bottomWidget,
    required this.showHabitName,
    required this.showAddEntry,
    this.initDate,
  });

  @override
  State<HeatMapTile> createState() => _HeatMapTileState();
}

class _HeatMapTileState extends State<HeatMapTile> {
  DateTime date = DateTime.now();
  DateTime initDate = DateTime(DateTime.now().year, DateTime.now().month);
  @override
  void initState() {
    super.initState();
    date = widget.date;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // color: Colors.indigo[100],
        color: (kAppBackgroundColor == Colors.white)
            ? Colors.grey[200]
            : Colors.grey[850],
      ),
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
      child: Container(
        margin:
            const EdgeInsets.only(left: 20.0, bottom: 8, right: 20.0, top: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (widget.showHabitName)
                        ? Text(
                            widget.habitName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.indigo[400],
                            ),
                          )
                        : Container(),
                    Row(
                      children: [
                        (widget.showAddEntry)
                            ? TextButton(
                                style: ButtonStyle(
                                    padding: WidgetStateProperty.all<
                                        EdgeInsetsGeometry>(
                                      EdgeInsets.zero,
                                    ),
                                    shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                    )),
                                child: Text(
                                  "${months[date.month - 1]} ${date.day} ${date.year}: ",
                                  style: TextStyle(
                                    color: Colors.indigo[400],
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                onPressed: () async {
                                  date = (await showDatePicker(
                                      builder: (context, child) => Theme(
                                            data: Theme.of(context).copyWith(
                                              dialogBackgroundColor:
                                                  kAppBackgroundColor,
                                              colorScheme:
                                                  (kAppBackgroundColor ==
                                                          Colors.white)
                                                      ? ColorScheme.light(
                                                          primary:
                                                              Colors.indigo,
                                                          onPrimary:
                                                              kAppBackgroundColor,
                                                          onSurface:
                                                              Colors.indigo,
                                                        )
                                                      : ColorScheme.dark(
                                                          primary:
                                                              Colors.indigo,
                                                          onPrimary:
                                                              kAppBackgroundColor,
                                                          onSurface:
                                                              Colors.indigo,
                                                        ),
                                              textButtonTheme:
                                                  TextButtonThemeData(
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.indigo[400],
                                                ),
                                              ),
                                            ),
                                            child: child!,
                                          ),
                                      context: context,
                                      firstDate: DateTime(1980),
                                      initialDate: DateTime.now(),
                                      lastDate: DateTime.now()))!;
                                  TimeOfDay? time = TimeOfDay.now();
                                  time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder: (context, child) => Theme(
                                      data: Theme.of(context).copyWith(
                                        dialogBackgroundColor:
                                            kAppBackgroundColor,
                                        colorScheme: (kAppBackgroundColor ==
                                                Colors.white)
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
                                  date = DateTime(date.year, date.month,
                                      date.day, time!.hour, time.minute);
                                  setState(() {});
                                },
                              )
                            : Container(),
                        const SizedBox(
                          width: 8,
                        ),
                        SizedBox(
                          height: 28,
                          width: 28,
                          child: (widget.showAddEntry)
                              ? IconButton(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(0.0),
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all<Color>(
                                      Colors.indigo[800]!,
                                    ),
                                    shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (widget.habitUnits == "time") {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (bottomSheetContext) {
                                            return BottomDurationPickerSheet(
                                              isFocus: false,
                                              bottomSheetContext:
                                                  bottomSheetContext,
                                              habitId: widget.habitId,
                                              habitUnits: widget.habitUnits,
                                              date: date,
                                            );
                                          });
                                    } else {
                                      await firestoreAddEntryToHabit(
                                        user:
                                            FirebaseAuth.instance.currentUser!,
                                        habitId: widget.habitId,
                                        newEntryData: {
                                          "dateTimeMillisecondsSinceEpoch":
                                              date.millisecondsSinceEpoch,
                                          "isLinkedWithFocusSession": false,
                                          "focusSessionID": "unknown",
                                          "value": 1
                                        },
                                      );
                                    }
                                  },
                                )
                              : Container(),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.center,
                  // color: Colors.red,
                  child: habitHeatMapCalendar(
                    context,
                    widget.dataSets,
                    widget.habitName,
                    widget.size,
                    widget.initDate,
                    widget.habitUnits,
                  ),
                ),
              ],
            ),
            // const SizedBox(
            //   height: 16,
            // ),
            widget.bottomWidget,
          ],
        ),
      ),
    );
  }
}
