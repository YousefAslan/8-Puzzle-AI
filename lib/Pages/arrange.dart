import 'dart:collection';
import 'package:ai_first_project/Modules/PuzzleBoard.dart';
import 'package:ai_first_project/Modules/PuzzleGame.dart';
import 'package:ai_first_project/Pages/playpage.dart';
import 'package:ai_first_project/Widgets/board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ArrangePage extends StatefulWidget {
  final Tuple2<int, int> boardSize;
  final HeuristicType selectedAlgorithm;
  const ArrangePage({Key key, this.boardSize, this.selectedAlgorithm})
      : super(key: key);

  @override
  _ArrangePageState createState() => _ArrangePageState();
}

class _ArrangePageState extends State<ArrangePage> {
  HashMap<Tuple2<int, int>, int> firstGoalBlocks;
  HashMap<Tuple2<int, int>, int> secondGoalBlocks;
  bool secondGoal = false;

  PuzzleBoard firstGoalPB;
  PuzzleBoard secondGoalPB;

  @override
  void initState() {
    super.initState();

    firstGoalBlocks = HashMap<Tuple2<int, int>, int>();
    for (int i = 0; i < widget.boardSize.item1 * widget.boardSize.item1; i++) {
      Tuple2<int, int> location = Tuple2<int, int>(
          (i ~/ widget.boardSize.item1), (i % widget.boardSize.item1));
      firstGoalBlocks[location] = i;
    }

    secondGoalBlocks = HashMap<Tuple2<int, int>, int>();
    for (int i = 0; i < widget.boardSize.item1 * widget.boardSize.item1; i++) {
      Tuple2<int, int> location = Tuple2<int, int>(
          (i ~/ widget.boardSize.item1), (i % widget.boardSize.item1));
      secondGoalBlocks[location] = i;
    }

    firstGoalPB = PuzzleBoard.fromMap(
      blocks: firstGoalBlocks,
      boardSize: widget.boardSize,
    );

    secondGoalPB = PuzzleBoard.fromMap(
      blocks: secondGoalBlocks,
      boardSize: widget.boardSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget title = Container(
      padding: EdgeInsets.only(
        top: 14,
        left: 25,
      ),
      child: Text(
        "8 Puzzle",
        style: TextStyle(
          fontSize: 35,
            fontWeight: FontWeight.w600,
            fontFamily: 'relway-semibold'
        ),
      ),
    );

    Widget subtitle = Container(
      padding: EdgeInsets.only(
        top: 22,
        left: 25,
        bottom: 65,
      ),
      child: Text(
        "Arrange the goal blocks",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    Widget board = Center(
      child: PuzzleBoardWidget(
        pb: secondGoal ? secondGoalPB : firstGoalPB,
      ),
    );

    Widget controlBar = Padding(
      padding: EdgeInsets.only(
        top: 50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Opacity(
            opacity: secondGoal ? 0 : 1,
            child: RaisedButton(
              color: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              onPressed: () {
                setState(() {
                  secondGoal = true;
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Add another Goal",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          RaisedButton(
            color: Color.fromRGBO(21, 146, 230, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            onPressed: () {
              HashMap<Tuple2<int, int>, int> gameBlocks =
                  HashMap<Tuple2<int, int>, int>();
              int size = widget.boardSize.item1;
              List<int> randomBlockDigits = [];

              for (int i = 0; i < size * size; i++) {
                randomBlockDigits.add(i);
              }
              do {
                randomBlockDigits.shuffle();

                for (int i = 0; i < size * size; i++) {
                  Tuple2<int, int> location =
                      Tuple2<int, int>(i ~/ size, i % size);
                  gameBlocks[location] = randomBlockDigits[i];
                }
              } while (!PuzzleGame.isSolvable(gameBlocks, firstGoalBlocks,
                      firstGoalPB.boardSize.item1) &&
                  !PuzzleGame.isSolvable(gameBlocks, secondGoalBlocks,
                      firstGoalPB.boardSize.item1));

              Provider.of<PuzzleGame>(context, listen: false).gameInitializer(
                secondGoal: secondGoal
                    ? secondGoalPB.board
                    : Map.from(firstGoalPB.board),
                heuristicType: widget.selectedAlgorithm,
                boardSize: widget.boardSize,
                goalBlocks: firstGoalPB.board,
                initBlocks: gameBlocks,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayPage(),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Let's Play",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            title,
            subtitle,
            board,
            controlBar,
          ],
        ),
      ),
    );
  }
}
