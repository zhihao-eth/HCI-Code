import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}
Map<DateTime, List<Map<String, dynamic>>> schedules = {};
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    CalendarPage(),
    MentalLoadIndicator(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

// Calendar Page with Calendar Grid and Daily Schedule Navigation


class CalendarPage extends StatefulWidget {
  final DateTime? selectedDate;

  CalendarPage({this.selectedDate});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedMonth = DateTime.now();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate ?? DateTime.now();
  }

  void _goToDailySchedule(DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailySchedulePage(selectedDate: date),
      ),
    );
  }

  void _goToNextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
    });
  }

  void _selectDateByInput() {
    final _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Date"),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              labelText: "Enter date (YYYY-MM-DD)",
              hintText: "e.g., 2024-11-24",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String input = _controller.text;
                try {
                  DateTime enteredDate = DateTime.parse(input);
                  setState(() {
                    selectedMonth = DateTime(enteredDate.year, enteredDate.month, 1);
                    selectedDate = enteredDate;
                  });
                  Navigator.of(context).pop(); // Close the dialog
                } catch (e) {
                  // Handle invalid date format
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Invalid date format. Please use YYYY-MM-DD.")),
                  );
                }
              },
              child: Text("Select"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    int daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    int firstDayOfWeek = DateTime(selectedMonth.year, selectedMonth.month, 1).weekday;

    List<Widget> dayCells = [];
    // Fill with empty cells for days before the start of the month
    for (int i = 1; i < firstDayOfWeek; i++) {
      dayCells.add(Container());
    }

    // Add days of the month with tap functionality
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime date = DateTime(selectedMonth.year, selectedMonth.month, day);
      bool isToday = date.day == DateTime.now().day &&
          date.month == DateTime.now().month &&
          date.year == DateTime.now().year;

      bool isSelected = selectedDate != null &&
          date.day == selectedDate!.day &&
          date.month == selectedDate!.month &&
          date.year == selectedDate!.year;

      dayCells.add(
        GestureDetector(
          onTap: () {
            _goToDailySchedule(date);
          },
          child: Container(
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue
                  : isToday
                  ? Colors.orange[200]
                  : Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                "$day",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(""),
          actions: [
            IconButton(
              icon: Icon(Icons.sunny),
              onPressed: () {
                setState(() {
                  selectedMonth = DateTime.now();
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.edit_calendar),
              onPressed: _selectDateByInput, // Trigger the dialog
            ),
          ],
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            // Detect swipe direction
            if (details.velocity.pixelsPerSecond.dx > 0) {
              // Swipe right: Go to previous month
              _goToPreviousMonth();

            }


            else if (details.velocity.pixelsPerSecond.dx < 0) {
              // Swipe left: Go to next day
              _goToNextMonth();
            }
          },
          child:
          Column(
            children: [
              // Month Navigation
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: _goToPreviousMonth,
                    ),
                    Text(
                      "${selectedMonth.month}/${selectedMonth.year}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: _goToNextMonth,
                    ),
                  ],
                ),
              ),
              // Days of the Week Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                      .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ),
              SizedBox(height: 8),
              // Calendar Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 7,
                  children: dayCells,
                ),
              ),
            ],
          ),
        )
    );
  }
}


class DailySchedulePage extends StatefulWidget {
  final DateTime selectedDate;

  DailySchedulePage({required this.selectedDate});

  @override
  _DailySchedulePageState createState() => _DailySchedulePageState();
}

class _DailySchedulePageState extends State<DailySchedulePage> {
  late List<Map<String, dynamic>> sharedTimeTable;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeScheduleForDate(widget.selectedDate);
  }

  void _initializeScheduleForDate(DateTime date) {
    DateTime normalizedDate = DateTime(date.year, date.month, date.day);

    if (!schedules.containsKey(normalizedDate)) {
      schedules[normalizedDate] = [
        {"time": "08:00 - 09:00", "user": "me", "title": "Exercise"},
        {"time": "08:00 - 10:15", "user": "partner", "title": "Team Meeting"},
        {"time": "11:00 - 12:30", "user": "me", "title": "Work on Project"},
        {"time": "14:00 - 15:00", "user": "me", "title": "Lecture"},
        {"time": "16:00 - 17:00", "user": "partner", "title": "Study in the Library"},
      ];
    }

    // Sort events by start time
    schedules[normalizedDate]!.sort((a, b) {
      final startTimeA = _parseTime(a["time"].split(" - ")[0]);
      final startTimeB = _parseTime(b["time"].split(" - ")[0]);
      return startTimeA.compareTo(startTimeB);
    });

    sharedTimeTable = schedules[normalizedDate]!;
  }

  DateTime _parseTime(String time) {
    final parts = time.split(":");
    return DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double pixelPerMinute = 2.0; // 1 minute = 1 pixel
    List<Widget> meColumnWidgets = [];
    List<Widget> partnerColumnWidgets = [];
    List<Widget> columnWidgets = [];
    //List<Widget> timelineWidgets = [];
    DateTime currentTimeMe = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      6,
      0,
    );
    DateTime currentTimePartner = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      6,
      0,
    );

    for (int i = 0; i < sharedTimeTable.length; i++) {
      final slot = sharedTimeTable[i];
      final timeRange = slot["time"].split(" - ");
      final startTime = _parseTime(timeRange[0]);
      final endTime = _parseTime(timeRange[1]);
      final durationInMinutes = endTime.difference(startTime).inMinutes;

      // Add free time for both columns





      if (currentTimeMe.isBefore(startTime)&&currentTimePartner.isBefore(startTime)) {
        if (currentTimePartner.isBefore(currentTimeMe)){
          partnerColumnWidgets.add(_buildGapPartner(currentTimeMe.difference(currentTimePartner).inMinutes*pixelPerMinute, currentTimePartner, currentTimeMe));
          currentTimePartner = currentTimeMe;
        }
        if (currentTimePartner.isAfter(currentTimeMe)){
          meColumnWidgets.add(_buildGap(currentTimePartner.difference(currentTimeMe).inMinutes*pixelPerMinute, currentTimeMe, currentTimePartner));
          currentTimeMe = currentTimePartner;
        }







        columnWidgets.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: Column(children: meColumnWidgets,)),
              Expanded(child: Column(children: partnerColumnWidgets)),
            ]
        ),
        );

        meColumnWidgets = [];
        partnerColumnWidgets = [];
        final gapDuration = startTime.difference(currentTimeMe).inMinutes;

        columnWidgets.add(_buildFreeTime(gapDuration * pixelPerMinute, currentTimeMe, startTime));

        //timelineWidgets.add(_buildTimelineGap(gapDuration * pixelPerMinute));
        currentTimeMe = startTime;
        currentTimePartner = startTime;

      }

      // Add event
      if (slot["user"] == "me") {
        if(currentTimeMe.isBefore(startTime)){
          final gapDuration = startTime.difference(currentTimeMe).inMinutes;
          meColumnWidgets.add(_buildGap(gapDuration * pixelPerMinute, currentTimeMe, startTime));
        }
        meColumnWidgets.add(_buildEventMe(
            title: slot["title"],
            height: durationInMinutes * pixelPerMinute,
            color: Colors.blue[100]!,
            startTime:startTime,
            endTime:endTime
        ));
        currentTimeMe = endTime;

      } else if (slot["user"] == "partner") {

        if(currentTimePartner.isBefore(startTime)){
          final gapDuration = startTime.difference(currentTimePartner).inMinutes;
          partnerColumnWidgets.add(_buildGapPartner(gapDuration * pixelPerMinute, currentTimePartner, startTime));
        }
        partnerColumnWidgets.add(_buildEvent(
          title: slot["title"],
          height: durationInMinutes * pixelPerMinute,
          color: Colors.orange[100]!,
        ));
        currentTimePartner = endTime;
      } else if (slot["user"] == "both") {
        if (currentTimePartner.isBefore(currentTimeMe)){
          partnerColumnWidgets.add(_buildGapPartner(-currentTimePartner.difference(currentTimeMe).inMinutes*pixelPerMinute, currentTimePartner, currentTimeMe));
          currentTimePartner = currentTimeMe;
        }
        else if(currentTimePartner.isAfter(currentTimeMe)){
          meColumnWidgets.add(_buildGap(currentTimePartner.difference(currentTimeMe).inMinutes*pixelPerMinute, currentTimeMe, currentTimePartner));
          currentTimeMe = currentTimePartner;
        }

        columnWidgets.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: Column(children: meColumnWidgets,)),
              Expanded(child: Column(children: partnerColumnWidgets)),
            ]
        ),
        );
        meColumnWidgets = [];
        partnerColumnWidgets = [];


        columnWidgets.add(_buildEventMe(
            title: slot["title"],
            height: durationInMinutes * pixelPerMinute,
            color: Colors.purple[100]!,
            startTime: startTime,
            endTime: endTime
        ));
        currentTimeMe = endTime;
        currentTimePartner = endTime;
      }

      // Add to timeline
      //timelineWidgets.add(_buildTimelineLabel("${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}"));

      // Update current time
    }

    // Handle remaining time after the last event
    DateTime endOfDay = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      22,
      0,
    );

    if (currentTimeMe.isBefore(endOfDay)||currentTimePartner.isBefore(endOfDay)) {
      if (currentTimePartner.isBefore(currentTimeMe)){
        partnerColumnWidgets.add(_buildGapPartner(-currentTimePartner.difference(currentTimeMe).inMinutes*pixelPerMinute, currentTimePartner, currentTimeMe));
        currentTimePartner = currentTimeMe;
      }
      else if(currentTimePartner.isAfter(currentTimeMe)){
        meColumnWidgets.add(_buildGap(currentTimePartner.difference(currentTimeMe).inMinutes*pixelPerMinute, currentTimeMe, currentTimePartner));
        currentTimeMe = currentTimePartner;
      }

      columnWidgets.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: Column(children: meColumnWidgets,)),
            Expanded(child: Column(children: partnerColumnWidgets)),
          ]
      ),
      );
      meColumnWidgets = [];
      partnerColumnWidgets = [];
      final gapDuration = endOfDay.difference(currentTimeMe).inMinutes;

      columnWidgets.add(_buildFreeTime(gapDuration * pixelPerMinute, currentTimeMe, endOfDay));




      currentTimeMe = endOfDay;
      currentTimePartner = endOfDay;
    }

    DateTime today = widget.selectedDate;

    // Get the next day
    DateTime nextDay = today.add(Duration(days: 1));

    // Get the previous day
    DateTime previousDay = today.subtract(Duration(days: 1));

    return Scaffold(
        appBar: AppBar(
          title: Text("Schedule for ${DateFormat('dd/MM/yyyy').format(widget.selectedDate)}"),
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            // Detect swipe direction
            if (details.velocity.pixelsPerSecond.dx > 0) {
              // Swipe right: Go to previous day
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      DailySchedulePage(selectedDate: previousDay),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(-1.0, 0.0); // Slide from right
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 200), // Adjust duration
                ),
              );

            } else if (details.velocity.pixelsPerSecond.dx < 0) {
              // Swipe left: Go to next day
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      DailySchedulePage(selectedDate: nextDay),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // Slide from right
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 200), // Adjust duration
                ),
              );


            }
          },
          child:Column(
            children: [
              // Add your new widget here
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (index) {
                        DateTime startOfWeek = widget.selectedDate.subtract(Duration(days: widget.selectedDate.weekday - 1));
                        DateTime day = startOfWeek.add(Duration(days: index));
                        bool isSelected = day.day == widget.selectedDate.day;

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    DailySchedulePage(selectedDate: day),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(-1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  if(widget.selectedDate.isAfter(day)){

                                  }else{
                                    // Slide from right
                                    const begin1 = Offset(1.0, 0.0);

                                    tween = Tween(begin: begin1, end: end).chain(CurveTween(curve: curve));
                                  }
                                  var offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 200), // Adjust duration
                              ),
                            );

                          },
                          child: Column(
                            children: [
                              Text(
                                day.day.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.blue : Colors.black,
                                ),
                              ),
                              Text(
                                ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"][day.weekday - 1],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected ? Colors.blue : Colors.black,
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  margin: EdgeInsets.only(top: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                  // Profile Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              child: Icon(Icons.person, size: 30),
                              backgroundColor: Colors.blue[100],
                            ),
                            SizedBox(height: 8),
                            Text("Me", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              child: Icon(Icons.person_outline, size: 30),
                              backgroundColor: Colors.orange[100],
                            ),
                            SizedBox(height: 8),
                            Text("Partner", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // SingleChildScrollView goes here
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimelineLabel(),
                      Expanded(child: Column(children: columnWidgets)),

                    ],
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget _buildGap(double height, DateTime startTime, DateTime endTime) {
    return GestureDetector(
        onTap: () => _addPrivateEvent(startTime, endTime),
        child:
        Container(
          height: height,
          margin: EdgeInsets.all(0),

          color: Colors.white,

        )
    );
  }

  Widget _buildGapPartner(double height, DateTime startTime, DateTime endTime) {
    return GestureDetector(

        child:
        Container(
          height: height,
          margin: EdgeInsets.all(0),

          color: Colors.white,

        )
    );
  }

  Widget _buildFreeTime(
      double height,
      DateTime startTime,
      DateTime endTime

      ) {
    return GestureDetector(
        onTap: () => _addEvent(startTime, endTime),
        child:
        Container(
          height: height,
          margin: EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 248, 232, 235),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: Center(
            child: Text(
              "Free Time For Both",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        )
    );
  }


  Widget _buildEventMe({
    required String title,
    required double height,
    required Color color,
    required DateTime startTime,
    required DateTime endTime
  }) {
    return GestureDetector(
        onLongPress: () => _delete(title, startTime, endTime),
        child:
        Container(
          height: height,
          margin: EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        )
    );
  }

  void _delete(String title, DateTime startTime, DateTime endTime) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this event?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      int j = -1;

      for (int i = 0; i < sharedTimeTable.length; i++) {
        final slot = sharedTimeTable[i];
        final timeRange = slot["time"].split(" - ");
        final _startTime = _parseTime(timeRange[0]);
        final _endTime = _parseTime(timeRange[1]);

        if (title == slot["title"] && startTime == _startTime && endTime == _endTime) {
          j = i;
          break;
        }
      }

      if (j != -1) {
        setState(() {
          schedules[widget.selectedDate]!.removeAt(j);

          // Sort events and refresh the schedule
          _initializeScheduleForDate(widget.selectedDate);
        });
      }
    }
  }



  Widget _buildEvent({
    required String title,
    required double height,
    required Color color,
  }) {return
    Container(
      height: height,
      margin: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }



  Widget _buildTimelineLabel() {
    const double hourHeight = 60.0 * 2; // 1 hour = 60 pixels (1 minute = 1 pixel)

    List<Widget> timelineWidgets = [];
    for (int hour = 6; hour < 22; hour++) {
      timelineWidgets.add(
        Container(
          height: hourHeight,
          width: 50,
          alignment: Alignment.topCenter,
          child: Text(
            "${hour.toString().padLeft(2, '0')}:00",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(children: timelineWidgets);
  }

  void _addEvent(DateTime startTime, DateTime endTime) async {
    final TextEditingController titleController = TextEditingController();
    TimeOfDay? selectedStartTime = TimeOfDay.fromDateTime(startTime);
    TimeOfDay? selectedEndTime = TimeOfDay.fromDateTime(endTime);
    String selectedUser = "both"; // Default to "both"

    final newEvent = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Add New Event"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: "Event Title"),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text("Start Time:"),
                      TextButton(
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(startTime),
                          );

                          if (pickedTime != null) {
                            if (DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isBefore(startTime)) {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Invalid Time"),
                                  content: Text("Start time must be after ${TimeOfDay.fromDateTime(startTime).format(context)}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isBefore(endTime)) {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Invalid Time"),
                                  content: Text("Start time must be before ${TimeOfDay.fromDateTime(endTime).format(context)}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            if(selectedEndTime != null){
                              if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isBefore
                                (DateTime(startTime.year,startTime.month, startTime.day,selectedEndTime!.hour,selectedEndTime!.minute))) {
                                showDialog<void>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Invalid Time"),
                                    content: Text("End time must be after start time"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                            }
                            setState(() {
                              selectedStartTime = pickedTime;
                            });
                          }


                        },
                        child: Text(
                          selectedStartTime?.format(context) ?? "Select",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("End Time:"),
                      TextButton(
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(endTime),
                          );
                          if (pickedTime != null) {
                            if (DateTime(endTime.year,endTime.month, endTime.day,pickedTime.hour,pickedTime.minute).isAfter(endTime)) {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Invalid Time"),
                                  content: Text("End time must be before ${TimeOfDay.fromDateTime(endTime).format(context)}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isAfter
                              (startTime)) {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Invalid Time"),
                                  content: Text("End time must be after ${TimeOfDay.fromDateTime(startTime).format(context)}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            if (selectedStartTime != null) {
                              if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isAfter
                                (DateTime(startTime.year,startTime.month, startTime.day,selectedStartTime!.hour,selectedStartTime!.minute))) {
                                showDialog<void>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Invalid Time"),
                                    content: Text("End time must be after start time"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                            }


                            setState(() {
                              selectedEndTime = pickedTime;
                            });
                          }
                        },
                        child: Text(
                          selectedEndTime?.format(context) ?? "Select",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("For:"),
                      Flexible(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: "me",
                              groupValue: selectedUser,
                              onChanged: (value) {
                                setState(() {
                                  selectedUser = value!;
                                });
                              },
                            ),
                            Text("Me"),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: "both",
                              groupValue: selectedUser,
                              onChanged: (value) {
                                setState(() {
                                  selectedUser = value!;
                                });
                              },
                            ),
                            Text("Both"),
                          ],
                        ),
                      ),
                    ],
                  )

                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        selectedStartTime != null &&
                        selectedEndTime != null) {
                      Navigator.of(context).pop({
                        "title": titleController.text,
                        "startTime": selectedStartTime,
                        "endTime": selectedEndTime,
                        "user": selectedUser,
                      });
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );

    if (newEvent != null) {
      // Extract event details
      String title = newEvent["title"];
      TimeOfDay startTime = newEvent["startTime"];
      TimeOfDay endTime = newEvent["endTime"];
      String user = newEvent["user"];

      // Add the event
      setState(() {
        schedules[widget.selectedDate]!.add({
          "time": "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}",
          "user": user,
          "title": title,
        });

        // Sort events and refresh the schedule
        _initializeScheduleForDate(widget.selectedDate);
      });
    }
  }


  void _addPrivateEvent(DateTime startTime, DateTime endTime) async {
    final TextEditingController titleController = TextEditingController();
    TimeOfDay? selectedStartTime = TimeOfDay.fromDateTime(startTime);
    TimeOfDay? selectedEndTime = TimeOfDay.fromDateTime(endTime);

    final newEvent = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Add New Event"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: "Event Title"),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text("Start Time:"),
                      TextButton(
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(startTime),
                          );

                          if (pickedTime != null) {
                            if (DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isBefore(startTime)) {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Invalid Time"),
                                  content: Text("Start time must be after ${TimeOfDay.fromDateTime(startTime).format(context)}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isBefore(endTime)) {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Invalid Time"),
                                  content: Text("Start time must be before ${TimeOfDay.fromDateTime(endTime).format(context)}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            if(selectedEndTime != null){
                              if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isBefore
                                (DateTime(startTime.year,startTime.month, startTime.day,selectedEndTime!.hour,selectedEndTime!.minute))) {
                                showDialog<void>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Invalid Time"),
                                    content: Text("End time must be after start time"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                            }
                            setState(() {
                              selectedStartTime = pickedTime;
                            });
                          }


                        },
                        child: Text(
                          selectedStartTime?.format(context) ?? "Select",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("End Time:"),
                      TextButton(
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(endTime),
                          );
                          if (pickedTime != null) {
                            if (DateTime(endTime.year,endTime.month, endTime.day,pickedTime.hour,pickedTime.minute).isAfter(endTime)) {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Invalid Time"),
                                  content: Text("End time must be before ${TimeOfDay.fromDateTime(endTime).format(context)}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isAfter
                              (startTime)) {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Invalid Time"),
                                  content: Text("End time must be after ${TimeOfDay.fromDateTime(startTime).format(context)}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            if (selectedStartTime != null) {
                              if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isAfter
                                (DateTime(startTime.year,startTime.month, startTime.day,selectedStartTime!.hour,selectedStartTime!.minute))) {
                                showDialog<void>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Invalid Time"),
                                    content: Text("End time must be after start time"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                            }


                            setState(() {
                              selectedEndTime = pickedTime;
                            });
                          }
                        },
                        child: Text(
                          selectedEndTime?.format(context) ?? "Select",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        selectedStartTime != null &&
                        selectedEndTime != null) {
                      Navigator.of(context).pop({
                        "title": titleController.text,
                        "startTime": selectedStartTime,
                        "endTime": selectedEndTime,
                        "user": "me",
                      });
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );

    if (newEvent != null) {
      // Extract event details
      String title = newEvent["title"];
      TimeOfDay startTime = newEvent["startTime"];
      TimeOfDay endTime = newEvent["endTime"];
      String user = newEvent["user"];

      // Add the event
      setState(() {
        schedules[widget.selectedDate]!.add({
          "time": "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}",
          "user": user,
          "title": title,
        });

        // Sort events and refresh the schedule
        _initializeScheduleForDate(widget.selectedDate);
      });
    }
  }
}




// Home Page with Arbitrary Time and Weather Display
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String userTime = DateFormat('hh:mm a').format(now); // 用户时间
    String partnerTime = DateFormat('hh:mm a').format(now.add(Duration(hours: 8))); // 伴侣时间

    return Scaffold(
      appBar: AppBar(
        title: Text("Homepage", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.emoji_emotions),
            onPressed: () {
              // 设置状态
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左侧用户信息
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/images/user.png'), // 替换为真实头像路径
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          SizedBox(width: 4),
                          Text("Zhihao", style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(userTime, style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/sunny.svg', // 替换为晴天图标路径
                            height: 24,
                            width: 24,
                          ),
                          SizedBox(width: 8),
                          Text("Sunny, 20°C", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  // 右侧伴侣信息
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/images/partner.png'), // 替换为真实头像路径
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          SizedBox(width: 4),
                          Text("Me", style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.green),
                          SizedBox(width: 4),
                          Text(partnerTime, style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/cloudy.svg', // 替换为多云图标路径
                            height: 24,
                            width: 24,
                          ),
                          SizedBox(width: 8),
                          Text("Cloudy, 18°C", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Notifications",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            NotificationCard(
              title: "Video Calling",
              description: "It seems like we haven't called for a long time.",
              iconPath: 'assets/icons/bell.svg',
            ),
            NotificationCard(
              title: "Watch Movie",
              description: "Watch movies together remotely!",
              iconPath: 'assets/icons/bell.svg',
            ),
            NotificationCard(
              title: "Send Gifts",
              description: "Don’t forget to send birthday gifts  :)",
              iconPath: 'assets/icons/bell.svg',
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconPath;

  NotificationCard({
    required this.title,
    required this.description,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  iconPath,
                  height: 40,
                  width: 40,
                  color: Colors.blue,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 接受事件
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600, // 字体加粗
                      color: Colors.black,
                    ),
                  ),
                  child: Text(
                    "Accept",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    // 拒绝事件
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600, // 字体加粗
                      color: Colors.black,
                    ),
                  ),
                  child: Text(
                    "Decline",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



// Mental Load Indicator Page
class MentalLoadIndicator extends StatelessWidget {
  final double userLoad; // 用户负荷百分比
  final double partnerLoad; // 伴侣负荷百分比

  MentalLoadIndicator({this.userLoad = 70, this.partnerLoad = 30});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mental Load Indicator", style: TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your Mental Load",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularPercentage(
              percentage: userLoad,
              gradient: LinearGradient(
                colors: [Colors.red, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            SizedBox(height: 40),
            Text(
              "Partner's Mental Load",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularPercentage(
              percentage: partnerLoad,
              gradient: LinearGradient(
                colors: [Colors.green, Colors.lightGreenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularPercentage extends StatelessWidget {
  final double percentage;
  final Gradient gradient;

  CircularPercentage({required this.percentage, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(150, 150),
          painter: GradientCirclePainter(percentage, gradient),
        ),
        Text(
          "${percentage.toInt()}%", // 在圆环中心显示百分比
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class GradientCirclePainter extends CustomPainter {
  final double percentage;
  final Gradient gradient;

  GradientCirclePainter(this.percentage, this.gradient);

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 10.0;
    Paint backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = (size.width - strokeWidth) / 2;

    // 绘制背景圆环
    canvas.drawCircle(center, radius, backgroundPaint);

    // 设置渐变
    Rect gradientRect = Rect.fromCircle(center: center, radius: radius);
    Paint gradientPaint = Paint()
      ..shader = gradient.createShader(gradientRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 绘制彩色圆弧
    double sweepAngle = 2 * pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // 起始角度
      sweepAngle,
      false,
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


// Profile Page
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const ProfilePic(),
            SizedBox(height: 8),
            SizedBox(width: 4),
            Text("Yuki", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),
            ProfileMenu(
              text: "My Account",
              icon: "assets/icons/user icon.svg",
              press: () => {},
            ),
            ProfileMenu(
              text: "Notifications",
              icon: "assets/icons/bell.svg",
              press: () {},
            ),
            ProfileMenu(
              text: "Settings",
              icon: "assets/icons/settings.svg",
              press: () {},
            ),
            ProfileMenu(
              text: "Help Center",
              icon: "assets/icons/question mark.svg",
              press: () {},
            ),
            ProfileMenu(
              text: "Log Out",
              icon: "assets/icons/log out.svg",
              press: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          const CircleAvatar(
            backgroundImage:
            AssetImage("assets/images/partner.png"),
          ),
          Positioned(
            right: -16,
            bottom: 0,
            child: SizedBox(
              height: 46,
              width: 46,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFF5F6F9),
                ),
                onPressed: () {},
                child: SvgPicture.string(cameraIcon),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.text,
    required this.icon,
    this.press,
  }) : super(key: key);

  final String text, icon;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF156CE7),
          padding: const EdgeInsets.all(20),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: const Color(0xFFF5F6F9),
        ),
        onPressed: press,
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              colorFilter:
              const ColorFilter.mode(Color(0xFF156CE7), BlendMode.srcIn),
              width: 22,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF757575),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF757575),
            ),
          ],
        ),
      ),
    );
  }
}

const cameraIcon =
'''<svg width="20" height="16" viewBox="0 0 20 16" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M10 12.0152C8.49151 12.0152 7.26415 10.8137 7.26415 9.33902C7.26415 7.86342 8.49151 6.6619 10 6.6619C11.5085 6.6619 12.7358 7.86342 12.7358 9.33902C12.7358 10.8137 11.5085 12.0152 10 12.0152ZM10 5.55543C7.86698 5.55543 6.13208 7.25251 6.13208 9.33902C6.13208 11.4246 7.86698 13.1217 10 13.1217C12.133 13.1217 13.8679 11.4246 13.8679 9.33902C13.8679 7.25251 12.133 5.55543 10 5.55543ZM18.8679 13.3967C18.8679 14.2226 18.1811 14.8935 17.3368 14.8935H2.66321C1.81887 14.8935 1.13208 14.2226 1.13208 13.3967V5.42346C1.13208 4.59845 1.81887 3.92664 2.66321 3.92664H4.75C5.42453 3.92664 6.03396 3.50952 6.26604 2.88753L6.81321 1.41746C6.88113 1.23198 7.06415 1.10739 7.26604 1.10739H12.734C12.9358 1.10739 13.1189 1.23198 13.1877 1.41839L13.734 2.88845C13.966 3.50952 14.5755 3.92664 15.25 3.92664H17.3368C18.1811 3.92664 18.8679 4.59845 18.8679 5.42346V13.3967ZM17.3368 2.82016H15.25C15.0491 2.82016 14.867 2.69466 14.7972 2.50917L14.2519 1.04003C14.0217 0.418041 13.4113 0 12.734 0H7.26604C6.58868 0 5.9783 0.418041 5.74906 1.0391L5.20283 2.50825C5.13302 2.69466 4.95094 2.82016 4.75 2.82016H2.66321C1.19434 2.82016 0 3.98846 0 5.42346V13.3967C0 14.8326 1.19434 16 2.66321 16H17.3368C18.8057 16 20 14.8326 20 13.3967V5.42346C20 3.98846 18.8057 2.82016 17.3368 2.82016Z" fill="#757575"/>
</svg>
''';




