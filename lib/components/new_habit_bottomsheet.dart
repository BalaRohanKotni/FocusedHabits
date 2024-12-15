import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_habits/constants.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/firestore_operations.dart';

class NewHabitBottomSheet extends StatefulWidget {
  final BuildContext bottomSheetContext;
  const NewHabitBottomSheet({super.key, required this.bottomSheetContext});

  @override
  State<NewHabitBottomSheet> createState() => NewHabitBottomSheetState();
}

class NewHabitBottomSheetState extends State<NewHabitBottomSheet> {
  TextEditingController habitNameController = TextEditingController();
  String unitsValue = "reps";
  FocusNode unitsFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
        backgroundColor: kAppBackgroundColor,
        onClosing: () {},
        builder: (bottomSheetContext) {
          return Container(
            margin: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height / 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create a new Habit",
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    color: Colors.indigo[400],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      flex: 3,
                      child: TextField(
                        controller: habitNameController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'New Habit',
                          labelStyle: GoogleFonts.lato(
                            color: Colors.indigo[400],
                          ),
                        ),
                        style: GoogleFonts.lato(
                          color: Colors.indigo[400],
                        ),
                        cursorColor: Colors.indigo[400],
                        onSubmitted: (value) {
                          firestoreCreateHabit(
                            user: FirebaseAuth.instance.currentUser!,
                            habitData: {
                              "name": habitNameController.text,
                              "units": unitsValue,
                              "entries": [],
                            },
                          );
                          Navigator.pop(bottomSheetContext);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Units:",
                          style: GoogleFonts.lato(
                              color: Colors.indigo[400],
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        DropdownButton(
                          alignment: AlignmentDirectional.bottomEnd,
                          underline: Container(),
                          value: unitsValue,
                          focusNode: unitsFocusNode,
                          onChanged: (String? newValue) {
                            setState(() {
                              unitsValue = newValue!;
                              unitsFocusNode.unfocus();
                            });
                          },
                          style: GoogleFonts.lato(
                              color: Colors.indigo[400], fontSize: 16),
                          items: const [
                            DropdownMenuItem(
                                value: "time", child: Text("Time")),
                            DropdownMenuItem(
                                value: "reps", child: Text("Reps")),
                          ],
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(bottomSheetContext);
                          },
                          child: Text("Cancel",
                              style:
                                  GoogleFonts.lato(color: Colors.indigo[400])),
                        ),
                        TextButton(
                          onPressed: () {
                            firestoreCreateHabit(
                              user: FirebaseAuth.instance.currentUser!,
                              habitData: {
                                "name": habitNameController.text,
                                "units": unitsValue,
                                "entries": [],
                              },
                            );
                            Navigator.pop(bottomSheetContext);
                          },
                          child: Text(
                            "Add",
                            style: GoogleFonts.lato(
                                color: const Color(0xFF02925D)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}

// Future<dynamic> newHabitBottomSheet(BuildContext context) {}
