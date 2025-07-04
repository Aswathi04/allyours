import 'package:flutter/material.dart';
import 'package:allyours/notification_service.dart';

class DayModeDialog extends StatelessWidget {
  const DayModeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('What kind of day are you looking forward to?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOptionButton(
            context,
            'Let\'s Get Shit Done',
            Icons.task_alt,
            Colors.teal,
            () async {
              await NotificationService().scheduleProductiveNotifications();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Productive mode activated! We\'ll remind you about your tasks.'),
                  backgroundColor: Colors.teal,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildOptionButton(
            context,
            'Leave me alone',
            Icons.do_not_disturb_on,
            Colors.grey[700]!,
            () async {
              await NotificationService().scheduleRelaxedNotifications();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Relaxed mode activated. We\'ll give you some space today.'),
                  backgroundColor: Colors.grey[700],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(double.infinity, 0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}