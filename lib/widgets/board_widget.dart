import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
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

class _BoardWidgetState extends State<BoardWidget> {
  PieceWidget currentPiece = PieceWidget(Tetromino.J);

  int currentScore = 0;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();

    startGame();
  }

  void startGame() {
    currentPiece.initializePiece();

    Duration frameRate = const Duration(milliseconds: 500);

    Timer.periodic(frameRate, (timer) {
      setState(() {
        clearLines();
        checkLanding();

        if (gameOver == true) {
          timer.cancel();
          showGameOverDialog();
        }

        currentPiece.movePiece(Direction.down);
      });
    });
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
              resetGame();

              Navigator.pop(context);
            },
            child: const Text('Jogar denovo'),
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
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: rowLength * colLength,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10),
              itemBuilder: (context, index) {
                int row = (index / rowLength).floor();
                int col = index % rowLength;

                if (currentPiece.position.contains(index)) {
                  return Center(
                    child: PixelWidget(
                      color: currentPiece.color,
                      child: index.toString(),
                    ),
                  );
                } else if (gameBoard[row][col] != null) {
                  final Tetromino? tetrominoType = gameBoard[row][col];
                  return PixelWidget(
                      color: tetrominoColors[tetrominoType], child: '');
                } else {
                  return Center(
                    child: PixelWidget(
                      color: Colors.grey[900],
                      child: index.toString(),
                    ),
                  );
                }
              },
            ),
          ),
          Text(
            'Score: $currentScore',
            style: const TextStyle(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: moveLeft,
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: rotatePiece,
                  icon: const Icon(Icons.rotate_right),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: moveRight,
                  icon: const Icon(Icons.arrow_forward),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
