import 'package:flutter/material.dart';

class YourBlanketScreen extends StatelessWidget {
  final List<Map<String, dynamic>> games = const[
    {'title': 'Tic Tac Toe', 'route': '/tic_tac_toe'},
    {'title': 'Memory Game', 'route': '/memory_game'},
    {'title': 'Reaction Time', 'route': '/reaction_game'},
  ];

  const YourBlanketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chill Out 🎮')),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(games[index]['title']),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pushNamed(context, games[index]['route']),
            ),
          );
        },
      ),
    );
  }
}
