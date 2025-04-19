import 'package:flutter/material.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  // 0 = empty, 1 = X, 2 = O
  List<List<int>> _board = List.generate(3, (_) => List.filled(3, 0));
  int _currentPlayer = 1; // 1 = X, 2 = O
  bool _gameOver = false;
  String _winner = "";

  void _resetGame() {
    setState(() {
      _board = List.generate(3, (_) => List.filled(3, 0));
      _currentPlayer = 1;
      _gameOver = false;
      _winner = "";
    });
  }

  void _makeMove(int row, int col) {
    if (_board[row][col] != 0 || _gameOver) {
      return;
    }

    setState(() {
      _board[row][col] = _currentPlayer;
      _checkWinner(row, col);
      if (!_gameOver) {
        _currentPlayer = _currentPlayer == 1 ? 2 : 1;
      }
    });
  }

  void _checkWinner(int row, int col) {
    // Check row
    if (_board[row][0] == _currentPlayer &&
        _board[row][1] == _currentPlayer &&
        _board[row][2] == _currentPlayer) {
      _setWinner();
      return;
    }

    // Check column
    if (_board[0][col] == _currentPlayer &&
        _board[1][col] == _currentPlayer &&
        _board[2][col] == _currentPlayer) {
      _setWinner();
      return;
    }

    // Check diagonals
    if (row == col &&
        _board[0][0] == _currentPlayer &&
        _board[1][1] == _currentPlayer &&
        _board[2][2] == _currentPlayer) {
      _setWinner();
      return;
    }

    if (row + col == 2 &&
        _board[0][2] == _currentPlayer &&
        _board[1][1] == _currentPlayer &&
        _board[2][0] == _currentPlayer) {
      _setWinner();
      return;
    }

    // Check for draw
    bool isDraw = true;
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        if (_board[i][j] == 0) {
          isDraw = false;
          break;
        }
      }
    }

    if (isDraw) {
      setState(() {
        _gameOver = true;
        _winner = "It's a draw!";
      });
    }
  }

  void _setWinner() {
    _gameOver = true;
    _winner = "Player ${_currentPlayer == 1 ? 'X' : 'O'} wins!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tic Tac Toe')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _gameOver
                ? _winner
                : "Player ${_currentPlayer == 1 ? 'X' : 'O'}'s turn",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 300),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  color: Colors.teal.shade100,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      int row = index ~/ 3;
                      int col = index % 3;
                      return GestureDetector(
                        onTap: () => _makeMove(row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Text(
                              _board[row][col] == 0
                                  ? ''
                                  : _board[row][col] == 1
                                      ? 'X'
                                      : 'O',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: _board[row][col] == 1
                                    ? Colors.blue
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              textStyle: TextStyle(fontSize: 18),
            ),
            child: Text('New Game'),
          ),
        ],
      ),
    );
  }
}