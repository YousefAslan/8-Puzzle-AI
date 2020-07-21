import 'dart:collection';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:puzzleastar/Modules/modified-heap-priorityQueue.dart';
import 'package:tuple/tuple.dart';
import 'PuzzleBoard.dart';

enum HeuristicType {
  tilesDifferences,
  manhattanDistance,
  nilssonSequenceScore,
}

class PuzzleGame extends ChangeNotifier {
  bool _win;
  Tuple2<int, int> boardSize;
  PuzzleBoard gameBoard, theGoalBoard, secondGoal;
  HeuristicType heuristicType;
  int maxDifference = 0;
  int maxDistance = 0;

  PuzzleGame() {
    _win = false;
  }

  get win => _win;

  bool gameInitializer(
      {Map<Tuple2<int, int>, int> initBlocks,
      Map<Tuple2<int, int>, int> goalBlocks,
      Map<Tuple2<int, int>, int> secondGoal,
      Tuple2<int, int> boardSize,
      HeuristicType heuristicType}) {
    _win = false;
    this.heuristicType = heuristicType;
    this.boardSize = boardSize;
    this.gameBoard =
        PuzzleBoard.fromMap(boardSize: boardSize, blocks: initBlocks);
    this.theGoalBoard =
        PuzzleBoard.fromMap(boardSize: boardSize, blocks: goalBlocks);
    this.secondGoal =
        PuzzleBoard.fromMap(boardSize: boardSize, blocks: secondGoal);
    maxDifference = pow(boardSize.item1, 2) - 1;

    maxDistance = pow(boardSize.item1, 2);
    if (maxDistance.isOdd) maxDistance--;
    maxDistance -= ((boardSize.item1 - 1) * 2);

    notifyListeners();
    return true;
  }

  bool moveBlock(MovingDirection direction) {
    gameBoard.moveBlock(direction);
    if (gameBoard == theGoalBoard || gameBoard == secondGoal) _win = true;
    notifyListeners();
    return true;
  }

  int computeHeuristic1(PuzzleBoard puzzleBoard) {
    int toReturn = 0;
    int toReturn2 = 0;
    puzzleBoard.board.forEach((Tuple2 key, int value) {
      if (value != 0) {
        if (theGoalBoard.board[key] != value) toReturn++;
        if (secondGoal.board[key] != value) toReturn2++;
      }
    });
    return toReturn < toReturn2 ? toReturn : toReturn2;
  }

  int computeHeuristic2(PuzzleBoard puzzleBoard) {
    int toReturn = 0;
    int toReturn2 = 0;

    var temp = theGoalBoard.board;
    var keys = temp.keys;

    var temp2 = secondGoal.board;
    var keys2 = temp2.keys;

    puzzleBoard.board.forEach((key, value) {
      if (value != 0) {
        Tuple2<int, int> tempLocation =
            keys.firstWhere((e) => temp[e] == value, orElse: () => null);
        toReturn += (tempLocation.item1 - key.item1).abs() +
            (tempLocation.item2 - key.item2).abs();

        tempLocation =
            keys2.firstWhere((e) => temp2[e] == value, orElse: () => null);
        toReturn2 += (tempLocation.item1 - key.item1).abs() +
            (tempLocation.item2 - key.item2).abs();
      }
    });
    return toReturn < toReturn2 ? toReturn : toReturn2;
  }

  int get progress1 => maxDistance - computeHeuristic1(gameBoard);

  int get progress2 => maxDifference - computeHeuristic2(gameBoard);


  int computeHeuristic3(PuzzleBoard puzzleBoard) {
    //TODO: not implemented yet
    return 0;
  }

  int computeHeuristic(PuzzleBoard puzzleBoard) {
    int toReturn = 0;

    toReturn += computeHeuristic1(puzzleBoard);
    switch (heuristicType) {
      case HeuristicType.tilesDifferences:
        toReturn += computeHeuristic1(puzzleBoard);
        break;
      case HeuristicType.manhattanDistance:
        toReturn += computeHeuristic2(puzzleBoard);
        break;
      case HeuristicType.nilssonSequenceScore:
        toReturn = computeHeuristic3(puzzleBoard);
        break;
    }
    return toReturn;
  }

  bool isEqual(QueueEntityBoard a, QueueEntityBoard b) {
    return (a.currentBoard == b.currentBoard);
  }

  int compare(QueueEntityBoard a, QueueEntityBoard b) {
    int theTotalDifference = a.total() - b.total();
    if (theTotalDifference != 0)
      return theTotalDifference;
    else
      return a.heuristic - b.heuristic;
  }

//  Queue<PuzzleBoard> aStarAlgorithm() {
  List<PuzzleBoard> aStarAlgorithm() {
    ModifiedHeapPriorityQueue<QueueEntityBoard> open =
        ModifiedHeapPriorityQueue(isEqual, compare);
    HashMap<PuzzleBoard, int> closeList = HashMap();

    int cost = 0, heuristic = computeHeuristic(gameBoard);
//    Queue<PuzzleBoard> steps = Queue<PuzzleBoard>();
    List<PuzzleBoard> steps2 = [];
    QueueEntityBoard best = QueueEntityBoard(
        currentBoard: gameBoard,
        cost: cost,
        heuristic: heuristic,
//        recommendedSteps: steps,
        recommendedSteps1: steps2);
    open.add(best);

    List<PuzzleBoard> children;
    QueueEntityBoard childEntity, insideOpen;

    int j = 0;
    while (open.isNotEmpty) {
      print("iteration #${j++}");
      best = open.removeFirst();
      if (best.currentBoard == theGoalBoard ||
          best.currentBoard == secondGoal) {
        print("find solution${best.currentBoard}");
//        return best.recommendedSteps;
        return best.recommendedSteps1;
      }
      cost = best.cost + 1;
      children = best.currentBoard.getAvailableMoves();
      for (PuzzleBoard child in children) {
        if (best.recommendedSteps1.length != 0 &&
            child == best.recommendedSteps1.last) continue;
        heuristic = computeHeuristic(child);
        steps2 = []
          ..addAll(best.recommendedSteps1)
          ..add(child);
//        steps = Queue.of(best.recommendedSteps.whereType<PuzzleBoard>());
//        steps.add(child);
        childEntity = QueueEntityBoard(
            currentBoard: child,
            cost: cost,
            heuristic: heuristic,
//            recommendedSteps: steps,
            recommendedSteps1: steps2);
        insideOpen = open.containsObject(childEntity);
        if (insideOpen == null && !closeList.containsKey(child)) {
          open.add(childEntity);
        } else if (insideOpen != null && compare(childEntity, insideOpen) < 0) {
          open.remove(insideOpen);
          open.add(childEntity);
        } else if (closeList.containsKey(child) &&
            childEntity.cost - closeList[child] < 0) {
          closeList.remove(child);
          open.add(childEntity);
        }
      }
      closeList[best.currentBoard] = best.cost;
    }
    return null;
  }

  PuzzleBoard hint() {
    List solution = aStarAlgorithm();
    gameBoard = solution[0];
    notifyListeners();
    return gameBoard;
  }

  List<PuzzleBoard> solveTheProblem() {
    List solution = aStarAlgorithm();
    return solution;
  }

  PuzzleBoard bFS() {
    Queue<PuzzleBoard> open = Queue<PuzzleBoard>();
    HashMap<PuzzleBoard, int> visited = HashMap<PuzzleBoard, int>();

    open.add(gameBoard);
    PuzzleBoard temp;
    List<PuzzleBoard> children;

    int i = 0;
    while (open.isNotEmpty) {
      print(i++);
      temp = open.removeFirst();
      visited[temp] = 0;

      if (temp == theGoalBoard) return temp;
      children = temp.getAvailableMoves();
      children.forEach((element) {
        if (!visited.containsKey(element)) open.add(element);
      });
    }
    return null;
  }
}
