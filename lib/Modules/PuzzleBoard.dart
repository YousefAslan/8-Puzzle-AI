import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';
import 'package:quiver/core.dart';

enum MovingDirection { UP, RIGHT, LEFT, DOWN, NONE }

class PuzzleBoard {
  static int emptyBlock = 0;
  Tuple2<int, int> boardSize;
  HashMap<Tuple2<int, int>, int> board;

  PuzzleBoard.fromMap({this.boardSize, Map<Tuple2<int, int>, int> blocks}) {
    board = HashMap.from(blocks);
  }

  PuzzleBoard.copy(
      {@required PuzzleBoard puzzleBoard, @required this.boardSize}) {
    this.board = HashMap.fromEntries(puzzleBoard.board.entries);
  }

  bool addToBoard(Tuple2<int, int> location, int value) {
    if (board.containsKey(location) || board.containsValue(value)) return false;
    if (location.item1 < 0 ||
        location.item2 < 0 ||
        location.item1 >= boardSize.item1 ||
        location.item2 >= boardSize.item2) return false;

    board[location] = value;
    return true;
  }

  List<PuzzleBoard> getAvailableMoves() {
    int tempValue;
    PuzzleBoard tempBoard;
    Tuple2<int, int> temp, key;
    List<PuzzleBoard> toReturnedList = [];
    key = board.keys
        .firstWhere((key) => board[key] == emptyBlock, orElse: () => null);

    for (int i = -1; i <= 1; i++) {
      if (i == 0) continue;
      temp = key.withItem1(key.item1 + i);
      if (temp.item1 >= 0 &&
          temp.item2 >= 0 &&
          temp.item1 < boardSize.item1 &&
          temp.item2 < boardSize.item2) {
        tempBoard =
            PuzzleBoard.copy(puzzleBoard: this, boardSize: this.boardSize);
        tempValue = tempBoard.board[temp];
        tempBoard.board[temp] = tempBoard.board[key];
        tempBoard.board[key] = tempValue;
        toReturnedList.add(tempBoard);
      }
      temp = key.withItem2(key.item2 + i);
      if (temp.item1 >= 0 &&
          temp.item2 >= 0 &&
          temp.item1 < boardSize.item1 &&
          temp.item2 < boardSize.item2) {
        tempBoard =
            PuzzleBoard.copy(puzzleBoard: this, boardSize: this.boardSize);
        tempValue = tempBoard.board[temp];
        tempBoard.board[temp] = tempBoard.board[key];
        tempBoard.board[key] = tempValue;
        toReturnedList.add(tempBoard);
      }
    }
    return toReturnedList;
  }

  bool moveBlock(MovingDirection direction) {
    int tempValue;
    Tuple2<int, int> oldLocation, newLocation;

    oldLocation = board.keys
        .firstWhere((key) => board[key] == emptyBlock, orElse: () => null);
    switch (direction) {
      case MovingDirection.LEFT:
        newLocation = oldLocation.withItem2(oldLocation.item2 - 1);
        break;
      case MovingDirection.DOWN:
        newLocation = oldLocation.withItem1(oldLocation.item1 + 1);
        break;
      case MovingDirection.UP:
        newLocation = oldLocation.withItem1(oldLocation.item1 - 1);
        break;
      case MovingDirection.RIGHT:
        newLocation = oldLocation.withItem2(oldLocation.item2 + 1);
        break;
    }
    if (newLocation.item1 >= 0 &&
        newLocation.item2 >= 0 &&
        newLocation.item1 < boardSize.item1 &&
        newLocation.item2 < boardSize.item2) {
      tempValue = this.board[oldLocation];
      this.board[oldLocation] = this.board[newLocation];
      this.board[newLocation] = tempValue;
      return true;
    }
    return false;
  }

  List toList() {
    List temp = [];
    for (int i = 0; i < boardSize.item1; i++) {
      for (int j = 0; j < boardSize.item1; j++) {
        temp.add(board[Tuple2(i, j)]);
      }
    }
    return temp;
  }

  @override
  String toString() {
    String temp = "";
    for (int i = 0; i < boardSize.item1; i++) {
      for (int j = 0; j < boardSize.item2; j++) {
        temp += Tuple2(i, j).toString() +
            " : " +
            this.board[Tuple2(i, j)].toString() +
            " ";
      }
      temp += '\n';
    }
    return temp;
  }

  @override
  bool operator ==(other) {
    bool toReturn = true;
    if (this == null || other == null) return false;
    if (!(other is PuzzleBoard)) return false;
    // ignore: test_types_in_equals
    if (this.boardSize != (other as PuzzleBoard).boardSize) {
      return false;
    }

    this.board.forEach((Tuple2 key, int value) {
      if (toReturn == false) return;
      if ((!other.board.containsKey(key)) || (other.board[key] != value)) {
        toReturn = false;
      }
    });
    return toReturn;
  }

  @override
  int get hashCode => hash2(2, boardSize.hashCode);
}

class QueueEntityBoard implements Comparable {
  final PuzzleBoard currentBoard;
  final int cost;
  final int heuristic;
//  Queue<PuzzleBoard> recommendedSteps;
  List<PuzzleBoard> recommendedSteps1;

  QueueEntityBoard(
      {this.currentBoard, this.cost, this.heuristic, this.recommendedSteps1});
//      {this.currentBoard, this.cost, this.heuristic, this.recommendedSteps,this.recommendedSteps1});

  int total() => cost + heuristic;

  @override
  int compareTo(other) {
    int temp = (total()) - ((other as QueueEntityBoard).total());
    return temp != 0 ? temp : heuristic - other.heuristic;
  }
}
