//import 'dart:collection';
//
//import 'package:flutter/cupertino.dart';
//import 'package:tuple/tuple.dart';
//
//class Board {
//  HashMap<Tuple2<int, int>, int> board;
//  HashMap<int, Tuple2<int, int>> boardKey;
//  Tuple2<int, int> size;
//
//  Board();
//
//  Board.copy({@required Board board, @required this.size}) {
//    this.board = HashMap.fromEntries(board.board.entries);
//    this.boardKey = HashMap.fromEntries(board.boardKey.entries);
//  }
//
//  void init() {}
//
//  List<Board> getAvailableMoves() {
//    Board toAdd;
//    Tuple2<int, int> empty, tempKey;
//    int tempValue;
//    List<Board> toReturn = [];
//
//    empty = boardKey[0];
//
//    for (int i = -1; i <= 1; i++) {
//      if (i == 0) continue;
//      tempKey = empty.withItem1(empty.item1 + i);
//      if (tempKey.item1 >= 0 &&
//          tempKey.item2 >= 0 &&
//          tempKey.item1 < size.item1 &&
//          tempKey.item2 < size.item2) {
//        toAdd = Board.copy(board: this, size: size);
//
//        tempValue = toAdd.board[tempKey];
//        toAdd.board[tempKey] = toAdd.board[empty];
//        toAdd.board[empty] = tempValue;
//
//        tempKey = toAdd.boardKey[tempValue];
//
//        toAdd.boardKey[tempKey] = toAdd.board[empty];
//        toAdd.board[empty] = tempValue;
//
//        tempValue = tempBoard.board[temp];
//        tempBoard.board[temp] = tempBoard.board[key];
//        tempBoard.board[key] = tempValue;
//        toReturnedList.add(tempBoard);
//      }
//      temp = key.withItem2(key.item2 + i);
//      if (temp.item1 >= 0 &&
//          temp.item2 >= 0 &&
//          temp.item1 < boardSize.item1 &&
//          temp.item2 < boardSize.item2) {
//        tempBoard =
//            PuzzleBoard.copy(puzzleBoard: this, boardSize: this.boardSize);
//        tempValue = tempBoard.board[temp];
//        tempBoard.board[temp] = tempBoard.board[key];
//        tempBoard.board[key] = tempValue;
//        toReturnedList.add(tempBoard);
//      }
//    }
//
//    return null;
//  }
//}
