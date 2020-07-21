import 'dart:async';

import 'package:ai_first_project/Modules/PuzzleBoard.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class PuzzleTile extends StatefulWidget {
  final int digit;
  final MovingDirection possibleMove;
  final Function moveBlocks;
  final Stream<Tuple2<int, int>> locationStream;
  final Tuple2<int, int> location;
  final int boardSize;

  void statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      switch (possibleMove) {
        case MovingDirection.UP:
          moveBlocks(MovingDirection.DOWN);
          break;
        case MovingDirection.RIGHT:
          moveBlocks(MovingDirection.LEFT);
          break;
        case MovingDirection.DOWN:
          moveBlocks(MovingDirection.UP);
          break;
        case MovingDirection.LEFT:
          moveBlocks(MovingDirection.RIGHT);
          break;
        case MovingDirection.NONE:
          moveBlocks(MovingDirection.NONE);
          break;
      }
    }
  }

  PuzzleTile({
    Key key,
    this.digit,
    this.possibleMove,
    this.moveBlocks,
    this.locationStream,
    this.location,
    this.boardSize,
  }) : super(key: key);
  @override
  _PuzzleTileState createState() => _PuzzleTileState();
}

class _PuzzleTileState extends State<PuzzleTile> with TickerProviderStateMixin {
  Animation<double> horizontalAnimation;
  AnimationController horizontalAnimationController;
  Animation<double> verticalAnimation;
  AnimationController verticalAnimationController;

  bool moving = false;

  void move() {
    if (widget.possibleMove == MovingDirection.NONE) return;
    if (widget.possibleMove == MovingDirection.LEFT ||
        widget.possibleMove == MovingDirection.RIGHT)
      horizontalAnimationController.forward();
    else if (widget.possibleMove == MovingDirection.UP ||
        widget.possibleMove == MovingDirection.DOWN)
      verticalAnimationController.forward();
  }

  @override
  void initState() {
    super.initState();
    horizontalAnimationController =
        AnimationController(duration: Duration(milliseconds: 150), vsync: this);
    verticalAnimationController =
        AnimationController(duration: Duration(milliseconds: 150), vsync: this);

    horizontalAnimation = Tween<double>(begin: 0, end: 370 / widget.boardSize)
        .animate(horizontalAnimationController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            // widget.statusListener(status);
            // if (status == AnimationStatus.completed) {
            //   moving = true;
            // }
          });

    verticalAnimation = Tween<double>(begin: 0, end: 355 / widget.boardSize)
        .animate(verticalAnimationController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            // widget.statusListener(status);
            // if (status == AnimationStatus.completed) {
            //   moving = true;
            // }
          });
  }

  @override
  void dispose() {
    horizontalAnimationController.dispose();
    verticalAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Tuple2<int, int>>(
        stream: widget.locationStream,
        builder: (context, snapshot) {
          if ((!moving) &&
              !(snapshot.hasError) &&
              (snapshot.hasData) &&
              snapshot.data == widget.location) {
            move();
            moving = true;
          }
          double xOffset, yOffset;
          if (widget.possibleMove == MovingDirection.DOWN ||
              widget.possibleMove == MovingDirection.RIGHT) {
            xOffset = horizontalAnimation.value;
            yOffset = verticalAnimation.value;
          } else if (widget.possibleMove == MovingDirection.UP ||
              widget.possibleMove == MovingDirection.LEFT) {
            xOffset = -1 * horizontalAnimation.value;
            yOffset = -1 * verticalAnimation.value;
          } else {
            xOffset = 0;
            yOffset = 0;
          }
          return GestureDetector(
            onTap: move,
            child: Transform.translate(
              offset: Offset(xOffset, yOffset),
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 3.725 / widget.boardSize,
                  vertical: 6.165 / widget.boardSize,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 1),
                      color: Color.fromRGBO(14, 36, 23, .4),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "${widget.digit}",
                    style: TextStyle(
                        color: Color.fromRGBO(252, 163, 17, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 60 / widget.boardSize),
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class EmptyPuzzleTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
