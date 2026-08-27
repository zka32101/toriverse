import 'package:flutter/material.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';

/// 8x8 Othello board widget with 3-color stones
class BoardWidget extends StatelessWidget {
  final Board board;
  final List<List<int>> validMoves;
  final Function(int row, int col) onMoveTapped;

  const BoardWidget({
    Key? key,
    required this.board,
    required this.validMoves,
    required this.onMoveTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade700,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: 64,
          itemBuilder: (context, index) {
            final row = index ~/ 8;
            final col = index % 8;
            final stone = board.getStone(row, col);
            final isValidMove = validMoves.any((move) => move[0] == row && move[1] == col);

            return GestureDetector(
              onTap: isValidMove ? () => onMoveTapped(row, col) : null,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black26,
                    width: 0.5,
                  ),
                  color: isValidMove ? Colors.yellow.shade100 : null,
                ),
                child: Center(
                  child: _buildStone(stone),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStone(int stone) {
    switch (stone) {
      case Board.black:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        );
      case Board.white:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        );
      case Board.red:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
