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

  void _showEndGameDialog(String resultMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,  // wymusza kliknięcie OK
      builder: (context) => AlertDialog(
        title: const Text('Koniec gry'),
        content: Text(resultMessage, style: const TextStyle(fontSize: 20)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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

        if (_checkWin(row, col, currentPlayer)) {
          Future.delayed(const Duration(seconds: 1), () {
            _showEndGameDialog(message);
          });
        } else if (_isBoardFull()) {
          Future.delayed(const Duration(seconds: 1), () {
            _showEndGameDialog(message);
          });
        }

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
      for (var coord in coords) {
        winningCells[coord[0]][coord[1]] = true;
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
                color: Colors.black,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            _buildBoard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16), // <-- margines po bokach
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade300],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(rows, (row) {
          return Row(
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
                    color: Colors.white70,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                );
              }

              return Flexible(
                child: GestureDetector(
                  onTap: message.contains('wygrywa') || message == 'Remis!'
                      ? null
                      : () {
                          _makeMove(col);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.all(6),
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isWinning ? Colors.yellow.withOpacity(0.5) : Colors.transparent,
                      boxShadow: isWinning
                          ? [
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.7),
                                blurRadius: 12,
                                spreadRadius: 4,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                    ),
                    child: ClipOval(child: content),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    ),
  );
}
}
