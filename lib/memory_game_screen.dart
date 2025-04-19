import 'dart:async';
import 'package:flutter/material.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<String> _emoji = ['🍎', '🍌', '🍇', '🍓', '🍍', '🍒'];
  List<String> _shuffled = [];
  List<bool> _revealed = [];
  int? _firstSelected;
  bool _canTap = true;

  int _score = 0;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _shuffled = List.from(_emoji)..addAll(_emoji);
    _shuffled.shuffle();
    _revealed = List.filled(_shuffled.length, false);
    _firstSelected = null;
    _score = 0;
    _seconds = 0;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
    setState(() {});
  }

  void _onCardTap(int index) {
    if (_revealed[index] || !_canTap) return;

    setState(() {
      _revealed[index] = true;
    });

    if (_firstSelected == null) {
      _firstSelected = index;
    } else {
      _canTap = false;
      if (_shuffled[_firstSelected!] == _shuffled[index]) {
        _score += 10;
        _firstSelected = null;
        _canTap = true;

        // Check if game is complete
        if (_revealed.every((e) => e)) {
          _timer?.cancel();
        }
      } else {
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _revealed[_firstSelected!] = false;
            _revealed[index] = false;
            _firstSelected = null;
            _canTap = true;
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formatTime(int seconds) {
      final mins = seconds ~/ 60;
      final secs = seconds % 60;
      return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }

    return Scaffold(
      appBar: AppBar(title: Text('Memory Match')),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text('Time: ${formatTime(_seconds)}', style: TextStyle(fontSize: 20)),
          Text('Score: $_score', style: TextStyle(fontSize: 20)),
          SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _shuffled.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onCardTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _revealed[index] ? _shuffled[index] : '',
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              textStyle: TextStyle(fontSize: 18),
            ),
            child: Text('Restart'),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
