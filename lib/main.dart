import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:allyours/drawing_canvas_screen.dart';
import 'package:allyours/memory_game_screen.dart';
import 'package:allyours/your_blanket_screen.dart';
import 'package:allyours/tic_tac_toe_screen.dart';
import 'package:allyours/reaction_game_screen.dart';
import 'dart:async';
import 'notification_service.dart';
void main() async {
  // This line is required when doing initialization work before runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();
  
  runApp(MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'All Yours',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/todo': (context) => TodoScreen(),
        '/alarm': (context) => AlarmScreen(),
        '/calendar': (context) => CalendarScreen(),
        '/canvas': (context) => DrawingCanvasScreen(),
        '/games': (context) => YourBlanketScreen(),
        '/memory_game': (context) => MemoryGameScreen(),
        '/tic_tac_toe': (context) => TicTacToeScreen(),
        '/reaction_game': (context) => ReactionGameScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> features = const [
    {'title': 'Alarm', 'icon': Icons.alarm, 'route': '/alarm'},
    {'title': 'Calendar', 'icon': Icons.calendar_today, 'route': '/calendar'},
    {'title': 'To-Do List', 'icon': Icons.check_box, 'route': '/todo'},
    {'title': 'Your Blanket', 'icon': Icons.videogame_asset, 'route': '/games'},
    {'title': 'Drawing Canvas', 'icon': Icons.brush, 'route': '/canvas'},
    {'title': 'Buddy', 'icon': Icons.chat, 'route': '/buddy'},
  ];

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Yours')),
      body: ListView.builder(
        itemCount: features.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(features[index]['icon'], color: Colors.teal),
              title: Text(features[index]['title']),
              onTap: () {
                Navigator.pushNamed(context, features[index]['route']);
              },
            ),
          );
        },
      ),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<String> _tasks = [];
  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _tasks.add(text);
        _controller.clear();
      });
    }
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('To-Do List')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter a task',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ),
              onSubmitted: (value) => _addTask(),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _tasks.isEmpty
                  ? Center(child: Text('No tasks yet.'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_tasks[index]),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _removeTask(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  TimeOfDay? _selectedTime;
  bool _alarmActive = false;
  Timer? _alarmTimer;
  NotificationService _notificationService = NotificationService();
  
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadSavedAlarm();
  }
  
  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }
  
  Future<void> _loadSavedAlarm() async {
    // You could use SharedPreferences to load saved alarm time
    // For brevity, we'll skip the implementation here
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _alarmActive = false;
      });
    }
  }
  
  void _setAlarm() {
    if (_selectedTime == null) return;
    
    final now = DateTime.now();
    var alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    
    // If the time has already passed today, set for tomorrow
    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(Duration(days: 1));
    }
    
    final difference = alarmTime.difference(now);
    
    setState(() {
      _alarmActive = true;
      _alarmTimer?.cancel();
      _alarmTimer = Timer(difference, _triggerAlarm);
    });
    
    // Schedule the morning question notification
    _notificationService.scheduleMorningQuestion(_selectedTime!);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alarm set for ${_selectedTime!.format(context)}'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _triggerAlarm() {
    // In a real app, you'd play a sound here
    _showDayModeDialog();
  }
  
  void _cancelAlarm() {
    setState(() {
      _alarmActive = false;
      _alarmTimer?.cancel();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alarm canceled'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _showDayModeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DayModeDialog(),
    );
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set Alarm')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _selectedTime == null
                  ? 'No alarm set'
                  : 'Alarm set for ${_selectedTime!.format(context)}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 8),
            if (_alarmActive)
              Text(
                'Alarm active',
                style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _pickTime,
              icon: Icon(Icons.access_time),
              label: Text('Pick Time'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _selectedTime != null && !_alarmActive ? _setAlarm : null,
                  icon: Icon(Icons.alarm_on),
                  label: Text('Set Alarm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    disabledBackgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _alarmActive ? _cancelAlarm : null,
                  icon: Icon(Icons.alarm_off),
                  label: Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    disabledBackgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            // For testing purposes:
            ElevatedButton(
              onPressed: _showDayModeDialog,
              child: Text('Test Day Mode Dialog'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final Map<DateTime, List<String>> _events = {};
  final TextEditingController _eventController = TextEditingController();

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _addEvent() {
    final eventText = _eventController.text.trim();
    if (eventText.isEmpty) return;

    final eventDate = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    setState(() {
      if (_events[eventDate] != null) {
        _events[eventDate]!.add(eventText);
      } else {
        _events[eventDate] = [eventText];
      }
      _eventController.clear();
    });
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(title: Text('Calendar')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: _getEventsForDay,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.tealAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _eventController,
              decoration: InputDecoration(
                labelText: 'Add Event',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addEvent,
                ),
              ),
              onSubmitted: (_) => _addEvent(),
            ),
            SizedBox(height: 20),
            Expanded(
              child: selectedEvents.isEmpty
                  ? Center(child: Text('No events for this day.'))
                  : ListView.builder(
                      itemCount: selectedEvents.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(selectedEvents[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
class DayModeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Day Mode'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Get Shit Done'),
            onTap: () {
              Navigator.of(context).pop('productive');
            },
          ),
          ListTile(
            title: Text('Leave Me Alone'),
            onTap: () {
              Navigator.of(context).pop('relaxed');
            },
          ),
        ],
      ),
    );
  }
}