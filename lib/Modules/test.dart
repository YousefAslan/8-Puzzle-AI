import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:puzzleastar/Modules/PuzzleBoard.dart';
import 'package:puzzleastar/Modules/PuzzleGame.dart';
import 'package:tuple/tuple.dart';

class MyItem {
  PuzzleBoard current;
  Queue<PuzzleBoard> rec;
  int cost, hur;

  int get total => cost + hur;

  MyItem(this.current, this.rec, this.cost, this.hur);

  bool areEqual(PuzzleBoard b) {
    if (this.current != b)
      return false;
    return false;
  }

  static int forSort(MyItem a, MyItem b) {
    int temp = a.total - b.total;
    if (temp == 0 || temp == 0.0)
      return a.hur - b.hur;
    else
      return temp;
  }
}

class MyPriority {
  List<MyItem> list;

  MyPriority() {
    list = [];
  }

  MyItem isContains(PuzzleBoard puzzleBoard) {
    MyItem toRet;
    list.forEach((element) {
      if (element.current == puzzleBoard) toRet = element;
    });
    return toRet;
  }

  void sort() {
    list.sort((MyItem a, MyItem b) {
      return MyItem.forSort(a, b);
    });
    print("total");
    String temp ='';
//    int t=0;
    for(int i =0; i< list.length;i++)
      {
        temp ='';
        temp += list[i].total.toString()+"hu:" + list[i].hur.toString() +"cost:" +list[i].cost.toString();
        print(temp);
      }
    print("finish");
  }

  bool add(MyItem myItem) {
    if (isContains(myItem.current) != null) {
      print("there is the same element in the priority");
      return false;
    }
    list.add(myItem);
    return true;
  }

  bool remove(MyItem myItem) {
    MyItem temp = isContains(myItem.current);
    if (temp == null) return false;
    list.remove(temp);
    print("element removed form priority");
    return true;
  }

  MyItem removeFirst() {
    if (list.length == 0) return null;
    this.sort();
    print("removeFirst");
    print(list[0].total);
    print(list[0].current);
    return list.removeAt(0);
  }
  MyItem getFirst() {
    if (list.length == 0) return null;
    this.sort();
    print("getFirst");
    print(list[0].total);
    print(list[0].current);
    return list[0];
  }


  bool get isNotEmpty => list.length > 0 ? true : false;
}

class MyGame extends ChangeNotifier {
  Tuple2<int, int> boardSize;
  PuzzleBoard gameBoard, goalBoard;

  MyGame();

  void init(
      {Map<Tuple2<int, int>, int> initBlocks,
      Map<Tuple2<int, int>, int> goalBlocks,
      Tuple2<int, int> boardSize}) {
    boardSize = boardSize;
    gameBoard = PuzzleBoard.fromMap(boardSize: boardSize, blocks: initBlocks);
    goalBoard = PuzzleBoard.fromMap(boardSize: boardSize, blocks: goalBlocks);
    notifyListeners();
  }

  void moveBlock(MovingDirection direction) {
    gameBoard.moveBlock(direction);
    if (gameBoard == goalBoard)
      print("----------------you win-----------------");
    notifyListeners();
  }

  int computeHeuristic2(PuzzleBoard puzzleBoard) {
    int toReturn = 0;
//    goalBoard.board.forEach((Tuple2 key, int value) {
//      if (puzzleBoard.board[key] != value) toReturn++;
//    });
//    return toReturn;

//    int toReturn = 0;
    var temp = puzzleBoard.board;
    var keys = temp.keys;
    goalBoard.board.forEach((key, value) {
      if (value == 0) return;
      Tuple2<int, int> tempLocation =
          keys.firstWhere((e) => temp[e] == value, orElse: () => null);
      toReturn += (tempLocation.item1 - key.item1).abs() +
          (tempLocation.item2 - key.item2).abs();
    });
    return toReturn;
  }

  Queue<PuzzleBoard> testing()
  {
    MyPriority open = MyPriority(), close = MyPriority();

    int heretic = computeHeuristic2(gameBoard);
    int cost =0;
    MyItem bestNode = MyItem(gameBoard, Queue(), cost, heretic);
    open.add(bestNode);
    List<PuzzleBoard> children =[];
    int index =0;
    MyItem child, temp;
    Queue<PuzzleBoard> tempQueue = Queue<PuzzleBoard>();

    while(open.isNotEmpty)
      {
        bestNode = open.getFirst();
        if(bestNode.current == goalBoard) return bestNode.rec;
        children = bestNode.current.getAvailableMoves();
        for(index =0;index<children.length;index++ )
          {
            heretic = computeHeuristic2(children[index]);
            cost = bestNode.cost +1;
            temp = open.isContains(children[index]);
            if(temp != null)
              {
                if(cost <= temp.cost) continue;
              }
            else if ((temp = close.isContains(children[index]) )!= null)
              {
                if(cost <= temp.cost) continue;
                close.remove(temp);
                temp.cost =cost;
              }
            else
              {
                tempQueue = Queue.of(bestNode.rec.whereType<PuzzleBoard>());
                tempQueue.add(children[index]);
                child = MyItem(children[index], tempQueue, cost, heretic);
                open.add(child);
              }
          }
        close.add(bestNode);
        open.remove(bestNode);
      }
      print("dont find the solution");
      return null;
  }

  Queue<PuzzleBoard> aStar() {
    MyPriority open = MyPriority(), close = MyPriority();

    int costing = 0, hur = computeHeuristic2(gameBoard);
    MyItem best = MyItem(gameBoard, Queue(), costing, hur);
    open.add(best);
    List tempList = [];

    MyItem temp ;
    Queue<PuzzleBoard> tempQueue;
    int j=0;
    while (open.isNotEmpty) {
      j++;
      print("form a* $j");


      best = open.getFirst();


      print("is it equal");
      print(best.current==(goalBoard));
      if (best.current == (goalBoard)) return best.rec;

      tempList = [];
      tempList = best.current.getAvailableMoves();
      MyItem temp2;

      for (PuzzleBoard child in tempList)
      {
        hur = computeHeuristic2(child);
        tempQueue =
            Queue.of(best.rec.whereType<PuzzleBoard>());
        tempQueue.add(child);
        temp = null;
        temp = MyItem(child, tempQueue, best.cost+1, hur);
        if((open.isContains(child) == null) && ( close.isContains(child) == null))
          {
            open.add(temp);
          }
        else if(true)
          {
            temp2 = open.isContains(child);
            if(temp2 != null && MyItem.forSort(temp, temp2) < 0)
              {
                print("open");
                open.remove(temp2);
                open.add(temp);
              }
            temp2 = close.isContains(child);
            if(temp2 != null && MyItem.forSort(temp, temp2) < 0)
              {
                print("close");
                close.remove(temp2);
                open.add(temp2);
              }

          }
      }
      open.remove(best);
      close.add(best);

    }
    return null;
  }

  void hint() {
    Queue solution = aStar();
    gameBoard = solution.removeFirst();
    notifyListeners();
  }

  void solveTheProblem() {
    var t = DateTime.now();
    Queue<PuzzleBoard> solution = aStar();
    int i=0;
    print((DateTime.now().difference(t)).toString());
    while (solution.isNotEmpty) {
        print(i++);
        gameBoard = solution.removeFirst();
        notifyListeners();
    }
  }

  void gameInitializer({Tuple2<int, int> boardSize, Map<Tuple2<int, int>, int> goalBlocks, Map<Tuple2<int, int>, int> initBlocks, HeuristicType heuristicType}) {
//    if (_initializeBoard) return false;
//    this.heuristicType = heuristicType;
//    this._initializeBoard = true;
    this.boardSize = boardSize;
    this.gameBoard =
        PuzzleBoard.fromMap(boardSize: boardSize, blocks: initBlocks);
    this.goalBoard =
        PuzzleBoard.fromMap(boardSize: boardSize, blocks: goalBlocks);
    notifyListeners();
  }
}
