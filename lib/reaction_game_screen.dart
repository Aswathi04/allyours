import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ReactionGameScreen extends StatefulWidget {
  const ReactionGameScreen({super.key});

  @override
  _ReactionGameScreenState createState() => _ReactionGameScreenState();
}

class _ReactionGameScreenState extends State<ReactionGameScreen> {
  bool _gameStarted = false;
  bool _targetVisible = false;
  DateTime? _startTime;
  int _reactionTime = 0; // in milliseconds
  List<int> _reactionTimes = [];
  Timer? _targetTimer;
  final Random _random = Random();

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _targetVisible = false;
      _reactionTime = 0;
    });

    // Random delay between 1-5 seconds before showing target
    int delay = _random.nextInt(4000) + 1000;
    _targetTimer = Timer(Duration(milliseconds: delay), () {
      if (mounted) {
        setState(() {
          _targetVisible = true;
          _startTime = DateTime.now();
        });
      }
    });
  }

  void _targetTapped() {
    if (!_targetVisible) return;

    final now = DateTime.now();
    final reaction = now.difference(_startTime!).inMilliseconds;

    setState(() {
      _reactionTime = reaction;
      _reactionTimes.add(reaction);
      _gameStarted = false;
      _targetVisible = false;
    });

    _targetTimer?.cancel();
  }

  void _resetScores() {
    setState(() {
      _reactionTimes.clear();
    });
  }

  String _getAverageTime() {
    if (_reactionTimes.isEmpty) return "N/A";
    final sum = _reactionTimes.reduce((a, b) => a + b);
    return "${(sum / _reactionTimes.length).toStringAsFixed(0)} ms";
  }

  String _getBestTime() {
    if (_reactionTimes.isEmpty) return "N/A";
    return "${_reactionTimes.reduce((a, b) => a < b ? a : b)} ms";
  }

  @override
  void dispose() {
    _targetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reaction Time'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetScores,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Test your reaction speed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Tap the green target as soon as it appears.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _gameStarted
                ? _buildGameArea()
                : _buildResults(),
            SizedBox(height: 20),
            if (!_gameStarted)
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Start Test'),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Attempts', '${_reactionTimes.length}'),
                _buildStatCard('Best Time', _getBestTime()),
                _buildStatCard('Average', _getAverageTime()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameArea() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: _targetVisible ? Colors.green : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _targetTapped,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              _targetVisible
                  ? 'TAP NOW!'
                  : 'Wait...',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _reactionTime > 0
                  ? 'Your reaction time:'
                  : 'Ready?',
              style: TextStyle(fontSize: 20),
            ),
            if (_reactionTime > 0)
              Text(
                '$_reactionTime ms',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}