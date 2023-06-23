import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tetrisflutter/constants/value.dart';
import 'package:tetrisflutter/widgets/piece_widget.dart';
import 'package:tetrisflutter/widgets/pixel_widget.dart';

List<List<Tetromino?>> gameBoard =
    List.generate(colLength, (i) => List.generate(rowLength, (j) => null));

class BoardWidget extends StatefulWidget {
  const BoardWidget({super.key});

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget>
    with TickerProviderStateMixin {
  PieceWidget currentPiece = PieceWidget(Tetromino.I);

  late Ticker _ticker;

  int currentScore = 0;
  bool gameOver = false;

  int _frameCount = 0;
  int _framesPerUpdate = 35;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void startGame() {
    currentPiece.initializePiece();
    _ticker = createTicker((elapsed) {
      _frameCount++;

      if (_frameCount >= _framesPerUpdate) {
        _frameCount = 0;

        setState(() {
          clearLines();

          checkLanding();

          if (gameOver == true) {
            _ticker.stop();
            showGameOverDialog();
          }

          currentPiece.movePiece(Direction.down);
        });
      }
    });
    _ticker.start();
  }

  bool checkCollision(Direction direction) {
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      if (row >= colLength || col < 0 || col >= rowLength) {
        return true;
      }

      if (row > 0 && col > 0) {
        if (gameBoard[row][col] != null) {
          return true;
        }
      }
    }

    return false;
  }

  void checkLanding() {
    if (checkCollision(Direction.down)) {
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;

        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }
      createNewPeace();
    }
  }

  void createNewPeace() {
    _framesPerUpdate = 35;

    Random rand = Random();

    Tetromino randomType =
        Tetromino.values[(rand.nextInt(Tetromino.values.length))];

    currentPiece = PieceWidget(randomType);
    currentPiece.initializePiece();

    if (isGameOver()) {
      gameOver = true;
    }
  }

  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void moveLeft() {
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  void clearLines() {
    for (int row = colLength - 1; row >= 0; row--) {
      bool isRowFull = true;
      for (int col = 0; col < rowLength; col++) {
        if (gameBoard[row][col] == null) {
          isRowFull = false;
          break;
        }
      }

      if (isRowFull) {
        for (int r = row; r > 0; r--) {
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }

        gameBoard[0] = List.generate(row, (index) => null);

        currentScore++;
      }
    }
  }

  bool isGameOver() {
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }

    return false;
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Seu score é: $currentScore'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Fechar'),
          ),
          TextButton(
            onPressed: () {
              resetGame();

              Navigator.pop(context);
            },
            child: const Text('Jogar novamente'),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    gameBoard =
        List.generate(colLength, (i) => List.generate(rowLength, (j) => null));

    gameOver = false;
    currentScore = 0;

    createNewPeace();

    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final screenHeight = constraints.maxHeight;
                  final itemWidth = screenWidth / 10;
                  final itemHeight =
                      screenHeight / (rowLength * colLength / 10);

                  return GridView.builder(
                    itemCount: rowLength * colLength,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 10,
                      childAspectRatio: itemWidth / itemHeight,
                    ),
                    itemBuilder: (context, index) {
                      int row = (index / rowLength).floor();
                      int col = index % rowLength;

                      if (currentPiece.position.contains(index)) {
                        return Center(
                          child: PixelWidget(
                            color: currentPiece.color,
                          ),
                        );
                      } else if (gameBoard[row][col] != null) {
                        final Tetromino? tetrominoType = gameBoard[row][col];
                        return PixelWidget(
                          color: tetrominoColors[tetrominoType],
                        );
                      } else {
                        return Center(
                          child: PixelWidget(
                            color: Colors.grey[900],
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 25),
            Text(
              gameOver == false ? 'Score: $currentScore' : '',
              style: const TextStyle(color: Colors.white),
            ),
            gameOver == false
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: moveLeft,
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                      ),
                      IconButton(
                        onPressed: moveRight,
                        icon: const Icon(Icons.arrow_forward),
                        color: Colors.white,
                      ),
                      IconButton(
                        onPressed: () {
                          _framesPerUpdate -= 25;
                        },
                        icon: const Icon(Icons.arrow_downward),
                        color: Colors.white,
                      ),
                      IconButton(
                        onPressed: rotatePiece,
                        icon: const Icon(Icons.rotate_right),
                        color: Colors.white,
                      ),
                    ],
                  )
                : IconButton(
                    onPressed: resetGame,
                    icon: const Icon(Icons.restart_alt),
                    color: Colors.white,
                  ),
            const SizedBox(height: 25),
          ],
        );
      }),
    );
  }
}
