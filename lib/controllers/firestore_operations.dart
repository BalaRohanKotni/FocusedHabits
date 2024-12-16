import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String firestoreCollection = "users";

Future firestoreCreateUserCollection(User user, String name) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .set(
    {
      'name': name,
      'habits': [],
      'focusSessions': [],
      'habitIndex': 0,
      'focusIndex': 0,
      'theme': "light",
      'defaultTabIndex': 1,
      'hideTabBarInHabitsOverview': false,
    },
  );
}

Future firestoreSetDefaultTabIndex(User user, int index) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({"defaultTabIndex": index});
}

Future firestoreSetHideTabBarInHabitsOverview(User user, bool value) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({"hideTabBarInHabitsOverview": value});
}

Future firestoreGetHideTabBarInHabitsOverview(User user) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .get()
      .then((value) => value.data()!["hideTabBarInHabitsOverview"]);
}

Future firestoreSetTheme(User user, String theme) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({"theme": theme});
}

Future firestoreSetUserName(User user, String userName) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({"name": userName});
}

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
      List.generate(len, (index) => r.nextInt(33) + 89));
}

Future firestoreCreateFocusSession({
  required User user,
  required Map<String, dynamic> sessionData,
}) async {
  String randId = generateRandomString(18);
  sessionData['id'] = randId;
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .collection("focusSessions")
      .add(sessionData)
      .then((value) {
    sessionData['id'] = value.id;
    firestoreUpdateFocusSession(
      user: user,
      updatedSessionData: sessionData,
      id: value.id,
    );
  });
  return sessionData['id'];
}

Future firestoreUpdateFocusSession({
  required User user,
  required Map<String, dynamic> updatedSessionData,
  required String id,
}) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .collection("focusSessions")
      .doc(id)
      .update(updatedSessionData);
}

Future firestoreDeleteFocusSession({
  required User user,
  required String id,
}) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .collection("focusSessions")
      .doc(id)
      .delete();
}

Future firestoreGetHabitsFromUser({required User user}) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .collection("habits")
      .get()
      .then((value) => value.docs.map((e) => e.data()));
}

Future firestoreGetHabitIndex({required User user}) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .get()
      .then((value) => value.data()!["habitIndex"]);
}

Future firestoreSetHabitIndex({required User user, required int index}) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .update({"habitIndex": index});
}

Future firestoreCreateHabit({
  required User user,
  required Map<String, dynamic> habitData,
}) async {
  String randId = generateRandomString(18);
  habitData['id'] = randId;
  habitData['index'] = await firestoreGetHabitIndex(user: user);
  await firestoreSetHabitIndex(user: user, index: habitData['index'] + 1);
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .collection("habits")
      .add(habitData)
      .then((value) {
    habitData['id'] = value.id;
    firestoreUpdateHabit(
      user: user,
      updatedHabit: habitData,
      id: value.id,
    );
  });
}

Future firestoreUpdateHabit({
  required User user,
  required Map<String, dynamic> updatedHabit,
  required String id,
}) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .collection("habits")
      .doc(id)
      .update(updatedHabit);
}

Future firestoreDeleteHabit({
  required User user,
  required String id,
}) async {
  FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .collection("habits")
      .doc(id)
      .delete();
}

Future firestoreGetEntriesFromHabit({
  required User user,
  required String habitId,
}) async {
  return await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .collection("habits")
      .doc(habitId)
      .get()
      .then((value) => value.data()!["entries"]);
}

Future firestoreAddEntryToHabit({
  required User user,
  required Map<String, dynamic> newEntryData,
  required String habitId,
}) async {
  List entries =
      await firestoreGetEntriesFromHabit(user: user, habitId: habitId);
  entries.add(newEntryData);
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .collection("habits")
      .doc(habitId)
      .update({"entries": entries});
}

Future firestoreUpdateEntryInHabit({
  required User user,
  required List newEntryData,
  required String habitId,
}) async {
  await FirebaseFirestore.instance
      .collection(firestoreCollection)
      .doc(user.uid)
      .collection("habits")
      .doc(habitId)
      .update({"entries": newEntryData});
}
