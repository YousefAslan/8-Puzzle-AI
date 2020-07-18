import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';
import 'PuzzleBoard.dart';
import 'package:async/async.dart';

enum HeuristicType {
  tilesDifferences,
  manhattanDistance,
  nilssonSequenceScore,
}

class PuzzleGame extends ChangeNotifier {
  bool _initializeBoard, _win;
  Tuple2<int, int> boardSize;
  PuzzleBoard gameBoard, theGoalBoard;
  HeuristicType heuristicType;

  PuzzleGame() {
    heuristicType = HeuristicType.manhattanDistance;
    _initializeBoard = false;
    _win = false;
  }

  get win => _win;

  bool gameInitializer(
      {Map<Tuple2<int, int>, int> initBlocks,
      Map<Tuple2<int, int>, int> goalBlocks,
      Tuple2<int, int> boardSize,HeuristicType heuristicType}) {
    if (_initializeBoard) return false;
    this.heuristicType = heuristicType;
    this._initializeBoard = true;
    this.boardSize = boardSize;
    this.gameBoard =
        PuzzleBoard.fromMap(boardSize: boardSize, blocks: initBlocks);
    this.theGoalBoard =
        PuzzleBoard.fromMap(boardSize: boardSize, blocks: goalBlocks);
    notifyListeners();
    return true;
  }

  bool moveBlock(MovingDirection direction) {
    gameBoard.moveBlock(direction);
    if (gameBoard == theGoalBoard) _win = true;
    notifyListeners();
    return true;
  }

  int computeHeuristic1(PuzzleBoard puzzleBoard) {
    int toReturn = 0;
    theGoalBoard.board.forEach((Tuple2 key, int value) {
      if (puzzleBoard.board[key] != value) toReturn++;
    });
    return toReturn;
  }

  int computeHeuristic2(PuzzleBoard puzzleBoard) {
    Tuple2<int, int> tempLocation;
    int toReturn = 0;
    var temp = puzzleBoard.board;
    var keys = temp.keys;
    theGoalBoard.board.forEach((key, value) {
      if(value ==  0 ) return;
      Tuple2<int, int> tempLocation =
          keys.firstWhere((e) => temp[e] == value, orElse: () => null);
      toReturn += (tempLocation.item1 - key.item1).abs() +
          (tempLocation.item2 - key.item2).abs();
    });
    return toReturn;
  }

  int computeHeuristic3(PuzzleBoard puzzleBoard) {
    //TODO: not implemented yet
    return 0;
  }

  int computeHeuristic(PuzzleBoard puzzleBoard) {
    int toReturn = 0;
    switch (heuristicType) {
      case HeuristicType.tilesDifferences:
        toReturn = computeHeuristic1(puzzleBoard);
        break;
      case HeuristicType.manhattanDistance:
        toReturn = computeHeuristic2(puzzleBoard);
        break;
      case HeuristicType.nilssonSequenceScore:
        toReturn = computeHeuristic3(puzzleBoard);
        break;
    }
    print("hu: $toReturn");
    return toReturn;
  }

  Queue<PuzzleBoard> aStarAlgorithm() {
    HashMap<PuzzleBoard,int> closeHash = HashMap();
    MyPriorityQueue openQueue = MyPriorityQueue();
    MyPriorityQueue closeQueue = MyPriorityQueue();

    List<PuzzleBoard> children;
    QueueEntityBoard childEntity;
    int cost = 0;
    Queue<PuzzleBoard> tempQueue;

    int tempHeuristic = computeHeuristic(gameBoard);
    QueueEntityBoard bestEntity = QueueEntityBoard(
        currentBoard: gameBoard,
        cost: cost,
        heuristic: tempHeuristic,
        recommendedSteps: Queue());
    openQueue.add(bestEntity);

    do {
      if (openQueue.isEmpty) return null;
      bestEntity = openQueue.first;
      openQueue.removeFirst();
      if (bestEntity.currentBoard == theGoalBoard)
        return bestEntity.recommendedSteps;

      children = bestEntity.currentBoard.getAvailableMoves();
      for (PuzzleBoard child in children) {
        tempHeuristic = computeHeuristic(child);
        cost = bestEntity.cost + 1;
        tempQueue =
            Queue.of(bestEntity.recommendedSteps.whereType<PuzzleBoard>());
        tempQueue.add(child);
        childEntity = QueueEntityBoard(
            currentBoard: child,
            cost: cost,
            heuristic: tempHeuristic,
            recommendedSteps: tempQueue);

        if (!(openQueue.contains(child)) && !(closeHash.containsKey(child))) {
          openQueue.add(childEntity);
        } else {
          if (openQueue.contains(child)) {
            if (openQueue.getTotal(child) > childEntity.total()) {
              openQueue.remove(childEntity);
              openQueue.add(childEntity);
            }
          } else if (closeHash.containsKey(child)) {
            if (closeHash[child] > childEntity.total()) {
              closeHash.remove(child);
//              closeQueue.remove(childEntity);
              openQueue.add(childEntity);
            }
          }
        }
      }
//      closeQueue.add(bestEntity);
      closeHash[bestEntity.currentBoard] = bestEntity.total();
    } while (openQueue.isNotEmpty);

    return null;
  }

  PuzzleBoard hint() {
    Queue solution = aStarAlgorithm();
    gameBoard = solution.removeFirst();
    notifyListeners();
    return gameBoard;
  }

  Queue<PuzzleBoard> solveTheProblem()  {
    var t = DateTime.now();
    Queue solution = aStarAlgorithm();
    return solution;
    int i =0;
    while (solution.isNotEmpty) {
      print(i++);
      gameBoard = solution.removeFirst();
      notifyListeners();
      print((DateTime.now().difference(t)).toString());
//      Future.delayed(Duration(seconds: 5));
    }
  }
}

class MyPriorityQueue {
  List<QueueEntityBoard> _list;

  MyPriorityQueue() {
    _list = [];
  }

  void add(QueueEntityBoard toAdd) {
    _list.add(toAdd);
    _list.sort(compare);
  }

  QueueEntityBoard get first => _list.first;

  bool get isNotEmpty => _list.length > 0;

  bool get isEmpty => _list.length <= 0;

  List<QueueEntityBoard> get list => _list;

  void removeFirst() {
    _list.removeAt(0);
    _list.sort(compare);
  }

  bool contains(PuzzleBoard puzzleBoard) {
    bool toReturn = false;
    _list.forEach((element) {
      if (toReturn) return;
      if (element.currentBoard == puzzleBoard) {
        toReturn = true;
        return;
      }
    });
    return toReturn;
  }

  int getTotal(PuzzleBoard puzzleBoard) {
    var toReturn;
    bool temp = false;
    _list.forEach((element) {
      if (temp) return;
      if (element.currentBoard == puzzleBoard) {
        temp = true;
        toReturn = element.total();
        return;
      }
    });
    return toReturn;
  }

  void remove(QueueEntityBoard childEntity) {
    bool temp = false;
    List toRemove = [];

    _list.forEach((element) {
      if (temp) return;
      if (element.currentBoard == childEntity.currentBoard) {
        toRemove.add(element);
        temp = true;
        return;
      }
    });
    _list.removeWhere((element) => toRemove.contains(element));
    _list.sort(compare);
  }

  int compare(QueueEntityBoard a, QueueEntityBoard b) {
    int temp = (a.total()) - b.total();
    return temp != 0 ? temp : temp;
  }
}
