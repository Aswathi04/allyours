import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  // Notification IDs
  static const int morningQuestionId = 0;
  static const int todoNotification1Id = 1;
  static const int todoNotification2Id = 2;
  static const int todoNotification3Id = 3;
  static const int canvasNotificationId = 4;

  // Initialize notifications
  Future<void> initialize() async {
    tz_init.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification taps
        final String? payload = response.payload;
        if (payload != null) {
          debugPrint('Notification payload: $payload');
          // You can navigate to different screens based on payload
        }
      },
    );
  }

  // Request notification permissions
  Future<void> requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
            
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Schedule the morning question notification
  Future<void> scheduleMorningQuestion(TimeOfDay alarmTime) async {
    // Cancel any existing morning question notification
    await _flutterLocalNotificationsPlugin.cancel(morningQuestionId);
    
    // Calculate the next alarm time
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      alarmTime.hour,
      alarmTime.minute,
    );
    
    // If the time is already passed for today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'morning_question_channel',
      'Morning Question',
      channelDescription: 'Daily morning question notification',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      morningQuestionId,
      'Good Morning!',
      'What kind of day are you looking forward to?',
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'morning_question',
    );
    
    debugPrint('Morning question scheduled for $scheduledDate');
  }

  // Schedule "Get Shit Done" mode notifications
  Future<void> scheduleProductiveNotifications() async {
    // Clear any existing notifications
    await cancelAllNotifications();
    
    final now = DateTime.now();
    
    // Distribute 3 notifications throughout the day
    final notification1Time = now.add(const Duration(hours: 2)); // 2 hours later
    final notification2Time = DateTime(now.year, now.month, now.day, 13, 0); // 1:00 PM
    final notification3Time = DateTime(now.year, now.month, now.day, 16, 0); // 4:00 PM
    
    // Adjust times if they've already passed
    final List<DateTime> notificationTimes = [
      notification1Time.isAfter(now) ? notification1Time : now.add(const Duration(minutes: 30)),
      notification2Time.isAfter(now) ? notification2Time : now.add(const Duration(hours: 3)),
      notification3Time.isAfter(now) ? notification3Time : now.add(const Duration(hours: 5)),
    ];
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'todo_reminder_channel',
      'To-Do Reminders',
      channelDescription: 'Reminders for your to-do list',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    
    final List<String> messages = [
      'Time to check your to-do list!',
      'How are you progressing with your tasks today?',
      'Don\'t forget to complete your important tasks!',
    ];
    
    // Schedule the notifications
    for (int i = 0; i < 3; i++) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        todoNotification1Id + i,
        'Task Reminder',
        messages[i],
        tz.TZDateTime.from(notificationTimes[i], tz.local),
        platformDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'todo_reminder',
      );
      
      debugPrint('Todo notification ${i+1} scheduled for ${notificationTimes[i]}');
    }
    
    // Save user preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('productiveMode', true);
  }

  // Schedule "Leave me alone" mode notifications (just canvas suggestion)
  Future<void> scheduleRelaxedNotifications() async {
    // Clear any existing notifications
    await cancelAllNotifications();
    
    final now = DateTime.now();
    
    // Schedule a single notification in the afternoon
    var scheduledTime = DateTime(now.year, now.month, now.day, 15, 0); // 3:00 PM
    
    // If 3:00 PM has already passed, schedule for 2 hours from now
    if (scheduledTime.isBefore(now)) {
      scheduledTime = now.add(const Duration(hours: 2));
    }
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'canvas_suggestion_channel',
      'Canvas Suggestions',
      channelDescription: 'Suggestions for using the drawing canvas',
     importance: Importance.defaultImportance,
     priority: Priority.defaultPriority,
    );
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      canvasNotificationId,
      'Feeling Stressed?',
      'Try squiggling it out in the canvas!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'canvas_suggestion',
    );
    
    debugPrint('Canvas notification scheduled for $scheduledTime');
    
    // Save user preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('productiveMode', false);
  }

  // Cancel all pending notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
  
  // Get the current mode from shared preferences
  Future<bool> isProductiveMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('productiveMode') ?? true;
  }
}