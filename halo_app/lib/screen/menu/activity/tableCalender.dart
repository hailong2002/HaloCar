import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TableCalender extends StatefulWidget {
  TableCalender({Key? key, required this.onDaySelected, required this.initialSelectedDate}) : super(key: key);
  final Function(DateTime) onDaySelected;
  DateTime initialSelectedDate;

  @override
  State<TableCalender> createState() => _TableCalenderState();
}

class _TableCalenderState extends State<TableCalender> {

  late DateTime today;

  @override
  void initState() {
    super.initState();
    today = widget.initialSelectedDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Roboto', color: Colors.black),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TableCalendar(
                  calendarStyle: const CalendarStyle(
                      defaultTextStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                      outsideDaysVisible: true,
                      outsideTextStyle:TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                      selectedTextStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: Colors.white),
                      selectedDecoration: BoxDecoration(color: Colors.blue,
                        shape: BoxShape.circle,
                        ),
                      todayTextStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: Colors.white) ,
                      weekendTextStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: Colors.orange),
                  ),
                  daysOfWeekStyle:const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: Colors.blue, fontSize: 16),
                    weekendStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: Colors.orange, fontSize: 16)
                  ),
                  focusedDay: today,
                  firstDay: DateTime.now(),
                  lastDay: DateTime.utc(2030, 12, 31),
                  headerStyle:const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, fontFamily: 'Roboto', color: Colors.red)
                  ),
                  availableGestures: AvailableGestures.all,
                  onDaySelected: (day, focusDay){
                    setState(() {
                      today = day;
                    });
                    widget.onDaySelected(today);
                  },
                  selectedDayPredicate: (day)=> isSameDay(day, today),

                ),

              ],
            ),
          ),
        ),

    );

  }

}
