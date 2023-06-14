import 'package:flutter/material.dart';

int rowLength = 10;
int colLength = 15;

enum Direction {
  right,
  left,
  down,
}

enum Tetromino {
  L,
  J,
  I,
  O,
  S,
  Z,
  T,
}

Map<Tetromino, Color> tetrominoColors = {
  Tetromino.I: const Color(0xFF4285F4), // Azul
  Tetromino.O: const Color(0xFFF44336), // Vermelho
  Tetromino.T: const Color(0xFFFFEB3B), // Amarelo
  Tetromino.S: const Color(0xFF4CAF50), // Verde
  Tetromino.Z: const Color(0xFFFF9800), // Laranja
  Tetromino.J: const Color(0xFF9C27B0), // Roxo
  Tetromino.L: const Color(0xFFF06292), // Rosa
};
