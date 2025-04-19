import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:allyours/drawing_canvas_screen.dart';
import 'package:allyours/memory_game_screen.dart';
import 'package:allyours/your_blanket_screen.dart';
import 'package:allyours/tic_tac_toe_screen.dart';
import 'package:allyours/reaction_game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'notification_service.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

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
        primarySwatch: Colors.purple,
        colorScheme: ColorScheme.light(
          primary: Colors.purple,
          secondary: Colors.amber,
          tertiary: Colors.teal,
          background: Colors.yellow[100]!,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        textTheme: GoogleFonts.comicNeueTextTheme(
          Theme.of(context).textTheme.copyWith(
            headlineMedium: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.purple[800],
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Colors.purple[900],
            ),
          ),
        ),
        scaffoldBackgroundColor: Colors.yellow[100],
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
    {
      'title': 'Wake Up!',
      'icon': Icons.alarm,
      'route': '/alarm',
      'color': Colors.redAccent
    },
    {
      'title': 'Calendar',
      'icon': Icons.calendar_today,
      'route': '/calendar',
      'color': Colors.blueAccent
    },
    {
      'title': 'To-Do List',
      'icon': Icons.check_box,
      'route': '/todo',
      'color': Colors.greenAccent
    },
    {
      'title': 'Chill Out',
      'icon': Icons.videogame_asset,
      'route': '/games',
      'color': Colors.purpleAccent
    },
    {
      'title': 'Drawing Canvas',
      'icon': Icons.brush,
      'route': '/canvas',
      'color': Colors.orangeAccent
    },
  ];

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Yours',
          style: GoogleFonts.comicNeue(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.yellow[100],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.yellow[200]!,
              Colors.yellow[100]!,
            ],
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return Hero(
              tag: features[index]['route'],
              child: TweenAnimationBuilder(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, features[index]['route']);
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: features[index]['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              features[index]['icon'],
                              color: features[index]['color'],
                              size: 32,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            features[index]['title'],
                            style: GoogleFonts.comicNeue(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTasks = prefs.getStringList('todoTasks');
    if (savedTasks != null) {
      for (final task in savedTasks) {
        _tasks.add(task);
      }
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('todoTasks', _tasks);
  }

  void _addTask() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _tasks.insert(0, text);
        _listKey.currentState?.insertItem(0);
        _controller.clear();
        _saveTasks();
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _removeTask(int index) {
    final removedItem = _tasks[index];
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: _buildTaskItem(removedItem, index, animation),
        ),
      ),
    );
    setState(() {
      _tasks.removeAt(index);
      _saveTasks();
    });
    HapticFeedback.lightImpact();
  }

  Widget _buildTaskItem(String task, int index, Animation<double>? animation) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${_tasks.length - index}',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          title: Text(
            task,
            style: TextStyle(fontSize: 16),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[300]),
            onPressed: () => _removeTask(index),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Add a new task...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.purple),
                  onPressed: _addTask,
                ),
              ),
              onSubmitted: (value) => _addTask(),
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No tasks yet!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Add your first task above',
                          style: TextStyle(
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  )
                : AnimatedList(
                    key: _listKey,
                    initialItemCount: _tasks.length,
                    padding: EdgeInsets.all(16),
                    itemBuilder: (context, index, animation) {
                      return SizeTransition(
                        sizeFactor: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: _buildTaskItem(_tasks[index], index, animation),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('alarmHour');
    final minute = prefs.getInt('alarmMinute');
    if (hour != null && minute != null) {
      setState(() {
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
        _alarmActive = true;
      });
    }
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

  void _setAlarm() async {
    if (_selectedTime == null) return;

    final now = DateTime.now();
    var alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(Duration(days: 1));
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('alarmHour', _selectedTime!.hour);
    await prefs.setInt('alarmMinute', _selectedTime!.minute);

    final difference = alarmTime.difference(now);

    setState(() {
      _alarmActive = true;
      _alarmTimer?.cancel();
      _alarmTimer = Timer(difference, _triggerAlarm);
    });

    _notificationService.scheduleMorningQuestion(_selectedTime!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alarm set for ${_selectedTime!.format(context)}'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _triggerAlarm() {
    _showDayModeDialog();
  }

  void _cancelAlarm() {
    setState(() {
      _alarmActive = false;
      _alarmTimer?.cancel();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alarm canceled'), duration: Duration(seconds: 2)),
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
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _selectedTime != null && !_alarmActive ? _setAlarm : null,
                  icon: Icon(Icons.alarm_on),
                  label: Text('Set Alarm'),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _alarmActive ? _cancelAlarm : null,
                  icon: Icon(Icons.alarm_off),
                  label: Text('Cancel'),
                ),
              ],
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
  final TextEditingController _eventController = TextEditingController();
  Map<String, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('calendarEvents');
    if (stored != null) {
      final Map<String, dynamic> decoded = jsonDecode(stored);
      setState(() {
        _events = decoded.map((key, value) => MapEntry(key, List<String>.from(value)));
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calendarEvents', jsonEncode(_events));
  }

  List<String> _getEventsForDay(DateTime day) {
    final key = _formatDate(day);
    return _events[key] ?? [];
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  void _addEvent() {
    final eventText = _eventController.text.trim();
    if (eventText.isEmpty) return;

    final dateKey = _formatDate(_selectedDay);
    setState(() {
      if (_events[dateKey] == null) {
        _events[dateKey] = [];
      }
      _events[dateKey]!.add(eventText);
      _eventController.clear();
    });
    _saveEvents();
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
