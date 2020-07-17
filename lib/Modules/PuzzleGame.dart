import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';
import 'PuzzleBoard.dart';
import 'package:async/async.dart';

class PuzzleGame extends ChangeNotifier {
  bool _initializeBoard, _win,_solvingCalled;
  Tuple2<int, int> boardSize;
  PuzzleBoard gameBoard, theGoalBoard;

  PuzzleGame() {
    _solvingCalled = false;
    _initializeBoard = false;
    _win = false;
  }

  get win => _win;

  bool gameInitializer(
      {Map<Tuple2<int, int>, int> initBlocks,
      Map<Tuple2<int, int>, int> goalBlocks,
      Tuple2<int, int> boardSize}) {
    if (_initializeBoard) return false;

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
    theGoalBoard.board.forEach((key, value){
      Tuple2<int, int> tempLocation = keys.firstWhere((e) => temp[e] == value, orElse: () => null);
      toReturn += (tempLocation.item1 - key.item1).abs() + (tempLocation.item2 - key.item2).abs();
    });
    return toReturn;
  }

  int computeHeuristic3(PuzzleBoard puzzleBoard) {
    //TODO: not implemented yet
    return 0;
  }

  Queue<PuzzleBoard> aStarAlgorithm() {
    HashMap<PuzzleBoard, int> closeHash = HashMap();
    MyPriorityQueue openQueue = MyPriorityQueue();

    List<PuzzleBoard> children;
    QueueEntityBoard childEntity;
    int cost = 0;
    Queue<PuzzleBoard> tempQueue;

    int tempHeuristic = computeHeuristic1(gameBoard);
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
        tempHeuristic = computeHeuristic1(child);
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
              openQueue.add(childEntity);
            }
          }
        }
      }
      closeHash[bestEntity.currentBoard] = bestEntity.total();
    } while (openQueue.isNotEmpty);

    return null;
  }
  void hint()
  {
    Queue solution = aStarAlgorithm();
    gameBoard = solution.removeFirst();
    notifyListeners();
  }
  void solveTheProblem()
  {
    if(_solvingCalled)  return;
    _solvingCalled = true;
    Queue solution = aStarAlgorithm();
    while(solution.isNotEmpty)
      {
        gameBoard = solution.removeFirst();
        notifyListeners();
        print("hello");
        Future.delayed(Duration(milliseconds: 1000));
      }
    _solvingCalled = false;
  }
}

class MyPriorityQueue {
  List<QueueEntityBoard> _list;

  MyPriorityQueue() {
    _list = [];
  }

  void add(QueueEntityBoard toAdd) {
    _list.add(toAdd);
    _list.sort((QueueEntityBoard a, QueueEntityBoard b) {
      return a.total() - b.total();
    });
  }

  QueueEntityBoard get first => _list.first;

  bool get isNotEmpty => _list.length > 0;

  bool get isEmpty => _list.length <= 0;

  List<QueueEntityBoard> get list => _list;

  void removeFirst() {
    _list.removeAt(0);
    _list.sort((QueueEntityBoard a, QueueEntityBoard b) {
      return a.total() - b.total();
    });
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
    int i = 0;

    _list.forEach((element) {
      i++;
      if (temp) return;
      if (element.currentBoard == childEntity.currentBoard) {
        _list.removeAt(i);
        temp = true;
        return;
      }
    });
    _list.sort((QueueEntityBoard a, QueueEntityBoard b) {
      return a.total() - b.total();
    });
  }
}
