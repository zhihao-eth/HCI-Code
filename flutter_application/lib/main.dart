import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

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
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    HomePage(),
    CalendarPage(),
    MentalLoadIndicator(),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Mental Load'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Calendar Page with Calendar Grid and Daily Schedule Navigation
class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedMonth = DateTime.now();

  void _goToDailySchedule(DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailySchedulePage(selectedDate: date),
      ),
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
      dayCells.add(
        GestureDetector(
          onTap: () => _goToDailySchedule(date),
          child: Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                "$day",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Calendar"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "${selectedMonth.month}/${selectedMonth.year}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              children: dayCells,
            ),
          ],
        ),
      ),
    );
  }
}

// Daily Schedule Page with the Detailed Layout
class DailySchedulePage extends StatelessWidget {
  final DateTime selectedDate;

  DailySchedulePage({required this.selectedDate});

  // Sample schedules for demonstration
  final List<Map<String, dynamic>> mySchedule = [
    {"time": "08:00 - 10:00", "title": "Tutorial: Embedded System", "color": Colors.blue, "icon": Icons.school},
    {"time": "12:00 - 14:00", "title": "Lecture: Computer Vision", "color": Colors.red, "icon": Icons.book},
    {"time": "16:00 - 18:00", "title": "Free time for both", "color": Colors.pink, "icon": Icons.people},
    {"time": "18:00 - 20:00", "title": "Party with Bob", "color": Colors.purple, "icon": Icons.celebration},
  ];

  final List<Map<String, dynamic>> partnerSchedule = [
    {"time": "10:00 - 12:00", "title": "Study in the library", "color": Colors.green, "icon": Icons.local_library},
    {"time": "14:00 - 16:00", "title": "Afternoon tea with Anna", "color": Colors.orange, "icon": Icons.local_cafe},
    {"time": "16:00 - 18:00", "title": "Free time for both", "color": Colors.pink, "icon": Icons.people},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Schedule for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
      ),
      body: Column(
        children: [
          // Date Selector Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                DateTime date = selectedDate.add(Duration(days: index - 3));
                bool isSelected = date.day == selectedDate.day;

                return GestureDetector(
                  onTap: () {
                    // Optionally handle other date selections if needed
                  },
                  child: Column(
                    children: [
                      Text(
                        "${date.day}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue : Colors.black,
                        ),
                      ),
                      Text(
                        "${["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"][date.weekday - 1]}",
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.blue : Colors.black,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 8,
                          height: 8,
                          margin: EdgeInsets.only(top: 4),
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
          Divider(),
          Text(
            "My and my partner's schedule",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                // My Schedule Column
                Expanded(
                  child: ScheduleColumn(
                    title: "Me",
                    avatarColor: Colors.blue,
                    schedule: mySchedule,
                  ),
                ),
                VerticalDivider(),
                // Partner's Schedule Column
                Expanded(
                  child: ScheduleColumn(
                    title: "Partner",
                    avatarColor: Colors.orange,
                    schedule: partnerSchedule,
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          // Schedule Legend
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Set schedule",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text("Don't forget schedule for tomorrow"),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    CategoryChip(label: "Meeting", color: Colors.yellow),
                    CategoryChip(label: "Hangout", color: Colors.purple),
                    CategoryChip(label: "Lecture", color: Colors.red),
                    CategoryChip(label: "Study", color: Colors.green),
                    CategoryChip(label: "Weekend", color: Colors.blue),
                    CategoryChip(label: "Tutorial", color: Colors.cyan),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Schedule Column Widget with Event Details
class ScheduleColumn extends StatelessWidget {
  final String title;
  final Color avatarColor;
  final List<Map<String, dynamic>> schedule;

  ScheduleColumn({
    required this.title,
    required this.avatarColor,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: avatarColor,
          child: Icon(Icons.person, color: Colors.white, size: 30),
        ),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Expanded(
          child: ListView.builder(
            itemCount: schedule.length,
            itemBuilder: (context, index) {
              final item = schedule[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item['color'],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(item['icon'], color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Text(
                            item['time'],
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Category Chip Widget for Legend
class CategoryChip extends StatelessWidget {
  final String label;
  final Color color;

  CategoryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}

// Home Page with Arbitrary Time and Weather Display
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String arbitraryTimeUser = '09:30 AM';
    String arbitraryTimePartner = '08:15 PM';

    return Scaffold(
      appBar: AppBar(
        title: Text("Homepage"),
        actions: [
          IconButton(icon: Icon(Icons.emoji_emotions), onPressed: () {/* Set Status */}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("User Time: $arbitraryTimeUser"),
                    Text("User Weather: Sunny, 20°C"), // Placeholder
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Partner Time: $arbitraryTimePartner"),
                    Text("Partner Weather: Cloudy, 18°C"), // Placeholder
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Mental Load Indicator Page
class MentalLoadIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mental Load Indicator")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Your Mental Load: __%"),
            Text("Partner's Mental Load: __%"),
          ],
        ),
      ),
    );
  }
}
