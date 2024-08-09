import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

// Custom formatter to allow only digits and dashes
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;
    final newText = text.replaceAll(RegExp(r'[^0-9-]'), ''); // Allow only numbers and dashes
    return newValue.copyWith(
      text: newText,
      selection: newValue.selection,
    );
  }
}

class PeriodTrackingPage extends StatefulWidget {
  final String email; // Add email parameter

  PeriodTrackingPage({required this.email});

  @override
  _PeriodTrackingPageState createState() => _PeriodTrackingPageState();
}

class _PeriodTrackingPageState extends State<PeriodTrackingPage> {
  late final ValueNotifier<List<DateTime>> _markedDays;
  late DateTime _selectedDate;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _periodDurationController = TextEditingController();
  final TextEditingController _cycleLengthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _markedDays = ValueNotifier([]);
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _markedDays.dispose();
    _startDateController.dispose();
    _periodDurationController.dispose();
    _cycleLengthController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
    });

    // Perform calculation for the next period cycle
    _calculateNextPeriodCycle(selectedDay);
  }

  void _calculateNextPeriodCycle(DateTime selectedDay) {
    final periodDuration = int.tryParse(_periodDurationController.text) ?? 5;
    final cycleLength = int.tryParse(_cycleLengthController.text) ?? 28;

    // Validate cycle length
    if (cycleLength < 21 || cycleLength > 45) {
      _showCycleLengthAlert();
    }

    // Parse start date
    DateTime startDate;
    try {
      startDate = DateTime.parse(_startDateController.text);
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid Date'),
            content: Text('Please enter a valid start date in YYYY-MM-DD format.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Mark the period dates
    _markPeriodDates(startDate, periodDuration, cycleLength);
  }

  void _markPeriodDates(DateTime startDate, int periodDuration, int cycleLength) {
    _markedDays.value.clear(); // Clear previous markings

    final today = DateTime.now();
    DateTime periodStart = startDate;
    while (periodStart.isBefore(today.add(Duration(days: 365 * 2)))) { // Mark for the next 2 years
      final periodEnd = periodStart.add(Duration(days: periodDuration - 1));
      for (DateTime date = periodStart; date.isBefore(periodEnd.add(Duration(days: 1))); date = date.add(Duration(days: 1))) {
        if (date.isAfter(today)) {
          _markedDays.value.add(date);
        }
      }
      periodStart = periodStart.add(Duration(days: cycleLength));
    }

    setState(() {});
  }

  void _showCycleLengthAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cycle Length Concern'),
          content: Text('Cycle length is concerning. Please consult a doctor.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              FadeInUp(
                duration: Duration(milliseconds: 1000),
                child: Text(
                  'HI ${widget.email}', // Display the email here
                  style: GoogleFonts.gupter(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              FadeInUp(
                duration: Duration(milliseconds: 1200),
                child: Text(
                  'TRACK YOUR PERIODS',
                  style: GoogleFonts.gupter(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              FadeInUp(
                duration: Duration(milliseconds: 1400),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: DateTime.now(),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDate, day);
                  },
                  onDaySelected: _onDaySelected,
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (_markedDays.value.any((d) => isSameDay(d, date))) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          width: 6,
                          height: 6,
                        );
                      }
                      return null;
                    },
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleTextStyle: GoogleFonts.gupter(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(color: Colors.black),
                    holidayTextStyle: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 20),
              FadeInUp(
                duration: Duration(milliseconds: 1500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Start Date (YYYY-MM-DD):', style: GoogleFonts.gupter(fontSize: 16)),
                    TextField(
                      controller: _startDateController,
                      keyboardType: TextInputType.text, // Use text keyboard for symbols
                      inputFormatters: [DateInputFormatter()], // Apply the custom formatter
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'e.g. 2024-08-01',
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Period Duration (days):', style: GoogleFonts.gupter(fontSize: 16)),
                    TextField(
                      controller: _periodDurationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'e.g. 5'),
                    ),
                    SizedBox(height: 20),
                    Text('Cycle Length (days):', style: GoogleFonts.gupter(fontSize: 16)),
                    TextField(
                      controller: _cycleLengthController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'e.g. 28'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _calculateNextPeriodCycle(_selectedDate);
                      },
                      child: Text('Update Calendar', style: GoogleFonts.gupter(
                        fontSize: 15,
                        color: Colors.black,
                      )),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
