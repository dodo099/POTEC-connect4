import 'package:flutter/material.dart';

void main() {
  runApp(const Connect4App());
}

class Connect4App extends StatelessWidget {
  const Connect4App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POTEC project',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Connect4Page(),
    );
  }
}

class Connect4Page extends StatefulWidget {
  const Connect4Page({Key? key}) : super(key: key);

  @override
  State<Connect4Page> createState() => _Connect4PageState();
}

class _Connect4PageState extends State<Connect4Page> {
  static const int rows = 6;
  static const int cols = 7;
  late List<List<int>> board; // 0 = puste, 1 = czerwony, 2 = żółty
  late List<List<bool>> winningCells; // podświetlanie wygranej
  int currentPlayer = 1;
  String message = 'Ruch: czerwony';

  @override
  void initState() {
    super.initState();
    _resetBoard();
    // Poczekaj aż ekran się załaduje i wtedy pokaż komunikat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStartupDialog();
    });
  }

  void _showStartupDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('O aplikacji'),
      content: const Text(
        'Ta aplikacja została stworzona na podstawie układu z programu Logisim Evolution '
        'na potrzeby projektu na przedmiot POTEC w semestrze 25L.\n\n'

        'Autor: Kinga Konieczna\nInżynieria Internetu Rzeczy, EiTI, Politechnika Warszawska.'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}


  void _resetBoard() {
    board = List.generate(rows, (_) => List.filled(cols, 0));
    winningCells = List.generate(rows, (_) => List.filled(cols, false));
    currentPlayer = 1;
    message = 'Ruch: czerwony';
  }

  bool _makeMove(int col) {
    for (int row = rows - 1; row >= 0; row--) {
      if (board[row][col] == 0) {
        setState(() {
          board[row][col] = currentPlayer;
          if (_checkWin(row, col, currentPlayer)) {
            message = (currentPlayer == 1 ? 'Czerwony' : 'Żółty') + ' wygrywa!';
          } else if (_isBoardFull()) {
            message = 'Remis!';
          } else {
            currentPlayer = 3 - currentPlayer;
            message = 'Ruch: ' + (currentPlayer == 1 ? 'czerwony' : 'żółty');
          }
        });
        return true;
      }
    }
    return false;
  }

  bool _isBoardFull() {
    for (var row in board) {
      for (var cell in row) {
        if (cell == 0) return false;
      }
    }
    return true;
  }

  bool _checkWin(int row, int col, int player) {
    return _checkDirection(row, col, player, 1, 0) || // poziomo
        _checkDirection(row, col, player, 0, 1) || // pionowo
        _checkDirection(row, col, player, 1, 1) || // ukośnie \
        _checkDirection(row, col, player, 1, -1); // ukośnie /
  }

  bool _checkDirection(int row, int col, int player, int deltaRow, int deltaCol) {
    List<List<int>> coords = [];

    int r = row;
    int c = col;

    // W tył
    while (_inBounds(r, c) && board[r][c] == player) {
      coords.add([r, c]);
      r -= deltaRow;
      c -= deltaCol;
    }

    // W przód (z pominięciem środkowego pola)
    r = row + deltaRow;
    c = col + deltaCol;
    while (_inBounds(r, c) && board[r][c] == player) {
      coords.add([r, c]);
      r += deltaRow;
      c += deltaCol;
    }

    if (coords.length >= 4) {
      for (var [rr, cc] in coords) {
        winningCells[rr][cc] = true;
      }
      return true;
    }

    return false;
  }

  bool _inBounds(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text('POTEC project'),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _resetBoard();
            });
          },
          child: const Text(
            'Nowa gra',
            style: TextStyle(
              color: Colors.black, // ważne, bo AppBar ma ciemne tło
              fontSize: 16,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            setState(() {
              _resetBoard();
            });
          },
          tooltip: 'Restartuj grę',
        ),
      ],
    ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          _buildBoard(),
        ],
      ),
    );
  }

  Widget _buildBoard() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(rows, (row) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(cols, (col) {
          int cell = board[row][col];
          bool isWinning = winningCells[row][col];

          Widget content;

          if (cell == 1) {
            content = Image.asset('assets/images/czerwona-small.png', width: 48, height: 48);
          } else if (cell == 2) {
            content = Image.asset('assets/images/zolta-small.png', width: 48, height: 48);
          } else {
            content = Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
              ),
            );
          }

          return GestureDetector(
            onTap: message.contains('wygrywa') || message == 'Remis!'
                ? null
                : () {
                    _makeMove(col);
                  },
            child: Container(
              margin: const EdgeInsets.all(4),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
                color: isWinning ? Colors.green : null,
              ),
              child: ClipOval(child: content),
            ),
          );
        }),
      );
    }),
  );
}
}