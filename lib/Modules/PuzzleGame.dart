import 'dart:collection';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';
import 'PuzzleBoard.dart';
import 'modified-heap-priorityQueue.dart';

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
  bool tilesDifferenceIsSelected, manhattanDistanceIsSelected;

  PuzzleGame() {
    _win = false;
  }

  get win => _win;

  void resetGame() {
    _win = false;
  }

  bool gameInitializer(
      {Map<Tuple2<int, int>, int> initBlocks,
      Map<Tuple2<int, int>, int> goalBlocks,
      Map<Tuple2<int, int>, int> secondGoal,
      Tuple2<int, int> boardSize,
      HeuristicType heuristicType,
      bool tilesDifferenceIsSelected,
      bool manhattanDistanceIsSelected}) {
    _win = false;
    this.heuristicType = heuristicType;
    this.boardSize = boardSize;
    this.gameBoard =
        PuzzleBoard.fromMap(boardSize: boardSize, blocks: initBlocks);
    this.theGoalBoard =
        PuzzleBoard.fromMap(boardSize: boardSize, blocks: goalBlocks);
    secondGoal == null
        ? this.secondGoal = this.theGoalBoard
        : this.secondGoal =
            PuzzleBoard.fromMap(boardSize: boardSize, blocks: secondGoal);

    maxDifference = pow(boardSize.item1, 2) - 1;

    maxDistance = pow(boardSize.item1, 2);
    if (maxDistance.isOdd) maxDistance--;
    maxDistance *= boardSize.item1;
    maxDistance -= ((boardSize.item1 - 1) * 2);

    this.tilesDifferenceIsSelected = tilesDifferenceIsSelected;
    this.manhattanDistanceIsSelected = manhattanDistanceIsSelected;
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

  static int computeHeuristic1Static(PuzzleBoard puzzleBoard,
      PuzzleBoard theGoalBoard, PuzzleBoard secondGoal) {
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

  static int computeHeuristic2Static(PuzzleBoard puzzleBoard,
      PuzzleBoard theGoalBoard, PuzzleBoard secondGoal) {
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

  double get progress1 =>
      (maxDistance - computeHeuristic2(gameBoard)) / (maxDistance.toDouble());

  double get progress2 =>
      (maxDifference - computeHeuristic1(gameBoard)) /
      (maxDifference.toDouble());

  int computeHeuristic(PuzzleBoard puzzleBoard) {
    int toReturn = 0;

    if (tilesDifferenceIsSelected) toReturn += computeHeuristic1(puzzleBoard);
    if (manhattanDistanceIsSelected) toReturn += computeHeuristic2(puzzleBoard);
    return toReturn;
  }

  static int computeHeuristicStatic(
      PuzzleBoard puzzleBoard,
      PuzzleBoard goalBoard,
      PuzzleBoard secondGoal,
      bool tilesDifferenceIsSelected,
      bool manhattanDistanceIsSelected) {
    int toReturn = 0;

    if (tilesDifferenceIsSelected)
      toReturn += computeHeuristic1Static(puzzleBoard, goalBoard, secondGoal);
    if (manhattanDistanceIsSelected)
      toReturn += computeHeuristic2Static(puzzleBoard, goalBoard, secondGoal);

    return toReturn;
  }

  bool isEqual(QueueEntityBoard a, QueueEntityBoard b) {
    return (a.currentBoard == b.currentBoard);
  }

  static bool isEqualStatic(QueueEntityBoard a, QueueEntityBoard b) {
    return (a.currentBoard == b.currentBoard);
  }

  int compare(QueueEntityBoard a, QueueEntityBoard b) {
    int theTotalDifference = a.total() - b.total();
    if (theTotalDifference != 0)
      return theTotalDifference;
    else
      return a.heuristic - b.heuristic;
  }

  static int compareStatic(QueueEntityBoard a, QueueEntityBoard b) {
    int theTotalDifference = a.total() - b.total();
    if (theTotalDifference != 0)
      return theTotalDifference;
    else
      return a.heuristic - b.heuristic;
  }

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

//    int j = 0;
    while (open.isNotEmpty) {
//      print("iteration #${j++}");
      best = open.removeFirst();
      if (best.currentBoard == theGoalBoard ||
          best.currentBoard == secondGoal) {
//        print("find solution${best.currentBoard}");
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
        childEntity = QueueEntityBoard(
            currentBoard: child,
            cost: cost,
            heuristic: heuristic,
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

  static List<PuzzleBoard> aStarAlgortihmStatic(Map<dynamic, dynamic> args) {
    PuzzleBoard puzzleState = args['puzzleState'];
    PuzzleBoard goalState = args['goalState'];
    PuzzleBoard secondGoalState = args['secondGoalState'];
    bool tilesDifferenceIsSelected = args['tilesDifferenceIsSelected'];
    bool manhattanDistanceIsSelected = args['manhattanDistanceIsSelected'];

    ModifiedHeapPriorityQueue<QueueEntityBoard> open =
        ModifiedHeapPriorityQueue(isEqualStatic, compareStatic);
    HashMap<PuzzleBoard, int> closeList = HashMap();

    int cost = 0,
        heuristic = computeHeuristicStatic(
          puzzleState,
          goalState,
          secondGoalState,
          tilesDifferenceIsSelected,
          manhattanDistanceIsSelected,
        );
//    Queue<PuzzleBoard> steps = Queue<PuzzleBoard>();
    List<PuzzleBoard> steps2 = [];
    QueueEntityBoard best = QueueEntityBoard(
        currentBoard: puzzleState,
        cost: cost,
        heuristic: heuristic,
//        recommendedSteps: steps,
        recommendedSteps1: steps2);
    open.add(best);

    List<PuzzleBoard> children;
    QueueEntityBoard childEntity, insideOpen;

//    int j = 0;
    while (open.isNotEmpty) {
//      print("iteration #${j++}");
      best = open.removeFirst();
      if (best.currentBoard == goalState ||
          best.currentBoard == secondGoalState) {
//        print("find solution${best.currentBoard}");
//        return best.recommendedSteps;
        return best.recommendedSteps1;
      }
      cost = best.cost + 1;
      children = best.currentBoard.getAvailableMoves();
      for (PuzzleBoard child in children) {
        if (best.recommendedSteps1.length != 0 &&
            child == best.recommendedSteps1.last) continue;
        heuristic = computeHeuristicStatic(
          child,
          goalState,
          secondGoalState,
          tilesDifferenceIsSelected,
          manhattanDistanceIsSelected,
        );
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
        } else if (insideOpen != null &&
            compareStatic(childEntity, insideOpen) < 0) {
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
    PuzzleBoard nextState;
    if (solution.length > 0) nextState = solution[0];
    notifyListeners();
    return nextState;
  }

  Future<PuzzleBoard> hintAsunc() async {
    Map<dynamic, dynamic> args = Map<dynamic, dynamic>();
    args['puzzleState'] = this.gameBoard;
    args['goalState'] = this.theGoalBoard;
    args['secondGoalState'] = this.secondGoal;
    args['tilesDifferenceIsSelected'] = this.tilesDifferenceIsSelected;
    args['manhattanDistanceIsSelected'] = this.manhattanDistanceIsSelected;
    List solution = await compute(aStarAlgortihmStatic, args);
    PuzzleBoard nextState;
    if (solution.length > 0) nextState = solution[0];
    notifyListeners();
    return nextState;
  }

  List<PuzzleBoard> solveTheProblem() {
    List solution = aStarAlgorithm();
    return solution;
  }

  Future<List<PuzzleBoard>> solveProblemStatic() {
    Map<dynamic, dynamic> args = Map<dynamic, dynamic>();
    args['puzzleState'] = this.gameBoard;
    args['goalState'] = this.theGoalBoard;
    args['secondGoalState'] = this.secondGoal;
    args['tilesDifferenceIsSelected'] = this.tilesDifferenceIsSelected;
    args['manhattanDistanceIsSelected'] = this.manhattanDistanceIsSelected;

    return compute(aStarAlgortihmStatic, args);
  }

  Tuple2<int, int> getEmptyBlockNewLocation(PuzzleBoard nextState) {
    if (nextState == null) {
      return null;
    }
    Tuple2<int, int> emptyOldLocation = Tuple2<int, int>(-1, -1);
    int size = gameBoard.boardSize.item1;
    for (Tuple2<int, int> location in gameBoard.board.keys)
      if (gameBoard.board[location] == 0) {
        emptyOldLocation = location;
        break;
      }

    Tuple2<int, int> emptyNewLocation = Tuple2<int, int>(-1, -1);

    //Up
    if (emptyOldLocation.item1 - 1 >= 0 &&
        nextState.board[Tuple2<int, int>(
                emptyOldLocation.item1 - 1, emptyOldLocation.item2)] ==
            0)
      emptyNewLocation =
          Tuple2<int, int>(emptyOldLocation.item1 - 1, emptyOldLocation.item2);
    //Right
    else if (emptyOldLocation.item2 + 1 < size &&
        nextState.board[Tuple2<int, int>(
                emptyOldLocation.item1, emptyOldLocation.item2 + 1)] ==
            0)
      emptyNewLocation =
          Tuple2<int, int>(emptyOldLocation.item1, emptyOldLocation.item2 + 1);
    //Down
    else if (emptyOldLocation.item1 + 1 < size &&
        nextState.board[Tuple2<int, int>(
                emptyOldLocation.item1 + 1, emptyOldLocation.item2)] ==
            0)
      emptyNewLocation =
          Tuple2<int, int>(emptyOldLocation.item1 + 1, emptyOldLocation.item2);
    //Left
    else if (emptyOldLocation.item2 - 1 >= 0 &&
        nextState.board[Tuple2<int, int>(
                emptyOldLocation.item1, emptyOldLocation.item2 - 1)] ==
            0)
      emptyNewLocation =
          Tuple2<int, int>(emptyOldLocation.item1, emptyOldLocation.item2 - 1);
    return emptyNewLocation;
  }

  static bool isSolvable(HashMap<Tuple2<int, int>, int> gameBoard,
      HashMap<Tuple2<int, int>, int> goalBoard, int size) {
    //Find the conversion map
    HashMap<int, int> conversionMap = HashMap<int, int>();
    conversionMap[0] = 0;
    int count = 1;
    for (int i = 0; i < size * size; i++) {
      Tuple2<int, int> location = Tuple2<int, int>(i ~/ size, i % size);
      if (goalBoard[location] == 0) continue;
      conversionMap[goalBoard[location]] = count;
      count++;
    }
    //Get the ordered Game Board
    HashMap<Tuple2<int, int>, int> convertedMap =
        HashMap<Tuple2<int, int>, int>();
    for (int i = 0; i < size * size; i++) {
      Tuple2<int, int> location = Tuple2<int, int>(i ~/ size, i % size);

      convertedMap[location] = conversionMap[gameBoard[location]];
    }

    //Calculate the number of inversions
    int inv_count = 0;
    for (int i = 0; i < size * size - 1; i++) {
      Tuple2<int, int> locationI = Tuple2<int, int>(i ~/ size, i % size);
      for (int j = i + 1; j < size * size; j++) {
        Tuple2<int, int> locationJ = Tuple2<int, int>(j ~/ size, j % size);
        if (convertedMap[locationJ] != 0 &&
            convertedMap[locationI] != 0 &&
            convertedMap[locationI] > convertedMap[locationJ]) inv_count++;
      }
    }

    return (inv_count % 2 == 0);
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
