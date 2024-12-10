import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:focused_habits/constants.dart';

HeatMapCalendar habitHeatMapCalendar(
  BuildContext context,
  Map<DateTime, int> dataSets,
  String habitName,
  double size,
  DateTime? initDateTime,
  String units,
) {
  return HeatMapCalendar(
    weekTextColor: Colors.indigo[400],
    // textColor: Colors.indigo[400],
    // showColorTip: false,
    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
    // defaultColor: Colors.grey[300],
    size: size,
    datasets: dataSets,
    colorMode: ColorMode.opacity,
    initDate: (initDateTime == null) ? DateTime.now() : initDateTime,
    colorsets: const {
      2: Colors.indigo,
    },
    onClick: (DateTime value) {
      String formattedValue = "";
      if (units == "reps") {
        formattedValue =
            ((dataSets[value] == null) ? 0 : dataSets[value]).toString();
      } else {
        int totalSeconds = dataSets[value]!;
        int hours = totalSeconds ~/ 3600;
        int minutes = (totalSeconds % 3600) ~/ 60;
        int seconds = totalSeconds % 60;
        List<String> parts = [];

        if (hours > 0) {
          parts.add('${hours.toString().padLeft(2, '0')}h');
        }
        if (minutes > 0 || hours > 0) {
          // Show minutes if there's an hour or minutes > 0
          parts.add('${minutes.toString().padLeft(2, '0')}m');
        }
        if (seconds > 0 || minutes > 0 || hours > 0) {
          // Show seconds if there's an hour or minute or seconds > 0
          parts.add('${seconds.toString().padLeft(2, '0')}s');
        }
        formattedValue = parts.join(' ');
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "$habitName - ${months[value.month - 1]} ${value.day} ${value.year}: $formattedValue")));
    },
  );
}
