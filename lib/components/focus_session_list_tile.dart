import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_habits/constants.dart';
import 'package:focused_habits/controllers/firestore_operations.dart';
import 'package:intl/intl.dart';

class FocusSessionListTile extends StatefulWidget {
  final dynamic focusSession;
  final int index;
  final String formattedFocusSessionValue, habitName, habitID, focusNote;
  final dynamic focusSessionsInRange;
  final bool isLinkedWithHabit;
  const FocusSessionListTile({
    super.key,
    this.focusSession,
    required this.index,
    required this.formattedFocusSessionValue,
    this.focusSessionsInRange,
    required this.habitName,
    required this.isLinkedWithHabit,
    required this.habitID,
    required this.focusNote,
  });

  @override
  State<FocusSessionListTile> createState() => _FocusSessionListTileState();
}

class _FocusSessionListTileState extends State<FocusSessionListTile> {
  FocusNode focusNode = FocusNode();
  bool hasFocus = false;
  TextEditingController focusNoteController = TextEditingController();
  @override
  void initState() {
    super.initState();
    focusNoteController.text = widget.focusNote;
    focusNoteController.addListener(() {
      firestoreUpdateFocusSession(
        user: FirebaseAuth.instance.currentUser!,
        updatedSessionData: {
          'focusNote': focusNoteController.text,
        },
        id: widget.focusSessionsInRange[widget.index]['id'],
      );
    });
    focusNode.addListener(() {
      setState(() {
        hasFocus = focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    focusNoteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: (kAppBackgroundColor == Colors.white)
            ? Colors.grey[100]
            : Colors.grey[850],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        key: Key(
            widget.focusSession['dateTimeMillisecondsSinceEpoch'].toString()),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  (widget.isLinkedWithHabit)
                      ? Text(
                          widget.habitName,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.indigo[400]),
                        )
                      : Container(),
                  TextField(
                    controller: focusNoteController,
                    focusNode: focusNode,
                    textAlignVertical: TextAlignVertical.top,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.indigo[400],
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: "Add a note",
                      hintStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.indigo[400],
                      ),
                      suffix: (hasFocus)
                          ? IconButton(
                              onPressed: () {
                                firestoreUpdateFocusSession(
                                  user: FirebaseAuth.instance.currentUser!,
                                  updatedSessionData: {
                                    'focusNote': focusNoteController.text,
                                  },
                                  id: widget.focusSessionsInRange[widget.index]
                                      ['id'],
                                );
                              },
                              icon: Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.indigo[400],
                              ),
                            )
                          : const SizedBox(
                              width: 3,
                              height: 13,
                            ),
                    ),
                    onSubmitted: (newValue) {
                      firestoreUpdateFocusSession(
                        user: FirebaseAuth.instance.currentUser!,
                        updatedSessionData: {
                          'focusNote': newValue,
                        },
                        id: widget.focusSessionsInRange[widget.index]['id'],
                      );
                    },
                  ),
                  Text(
                    DateFormat('MMM dd, y').format(
                        DateTime.fromMillisecondsSinceEpoch(widget
                            .focusSession['dateTimeMillisecondsSinceEpoch'])),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.indigo[400],
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(widget
                            .focusSession['dateTimeMillisecondsSinceEpoch'])),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.indigo[400],
                    ),
                  ),
                  Text(
                    widget.formattedFocusSessionValue,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo[400],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 80,
              child: IconButton(
                icon: Icon(
                  Icons.delete_forever,
                  size: 20,
                  color: Colors.indigo[400],
                ),
                onPressed: () {
                  firestoreDeleteFocusSession(
                      user: FirebaseAuth.instance.currentUser!,
                      id: widget.focusSessionsInRange[widget.index]
                          .data()['id']);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
