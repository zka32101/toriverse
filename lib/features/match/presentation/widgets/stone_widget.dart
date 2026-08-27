import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../domain/entities/board.dart';

/// Individual stone widget with 3-color support
class StoneWidget extends StatelessWidget {
  final int stoneValue; // 0=black, 1=white, 2=red, 3=empty
  final bool isValidMove;
  final double size;
  final VoidCallback? onTap;
  final bool isAnimating;

  const StoneWidget({
    required this.stoneValue,
    required this.size,
    this.isValidMove = false,
    this.onTap,
    this.isAnimating = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stoneValue == Board.empty) {
      return _buildEmptyCell();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ToriverseTheme.getStoneColor(stoneValue),
        boxShadow: isAnimating
            ? [
                BoxShadow(
                  color: ToriverseTheme.getStoneColor(stoneValue)
                      .withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: stoneValue == Board.white
              ? Center(
                  child: Container(
                    width: size * 0.85,
                    height: size * 0.85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildEmptyCell() {
    if (isValidMove) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ToriverseTheme.validMoveHighlight.withOpacity(0.3),
          border: Border.all(
            color: ToriverseTheme.validMoveHighlight,
            width: 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            splashColor: ToriverseTheme.validMoveHighlight.withOpacity(0.3),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ToriverseTheme.validMoveHighlight,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
    );
  }
}
