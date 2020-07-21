import 'dart:async';
import 'package:ai_first_project/Modules/PuzzleBoard.dart';
import 'package:ai_first_project/Modules/PuzzleGame.dart';
import 'package:ai_first_project/Widgets/board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:tuple/tuple.dart';

class PlayPage extends StatefulWidget {
  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage>
    with SingleTickerProviderStateMixin {
  StreamController<Tuple2<int, int>> locationStreamController;

  PuzzleBoardWidget boardWidget;
  bool boardInitialized = false;

  bool timerRunning = true;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  List<PuzzleBoard> solveMoves;

  AnimationController _animationController;
  Animation<Color> _colorTween;

  bool solving = false;

  @override
  void initState() {
    super.initState();
    locationStreamController = StreamController<Tuple2<int, int>>.broadcast();
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);

    solveMoves = List<PuzzleBoard>();

    _animationController = AnimationController(
      vsync: this,
    );
    _colorTween = _animationController.drive(
      ColorTween(
        begin: Color.fromRGBO(255, 186, 0, 1),
        end: Color.fromRGBO(255, 217, 59, 1),
      ),
    );
  }

  void solvePuzzle(BuildContext con) {
    solveMoves = Provider.of<PuzzleGame>(con, listen: false).solveTheProblem();
    if (solveMoves.isEmpty) return;

    PuzzleBoard nextState = solveMoves[0];
    moveAuto(con, nextState);
    solveMoves.removeAt(0);

    Timer.periodic(Duration(milliseconds: 400), (timer) {
      print(solveMoves.length);
      if (solveMoves.isEmpty) {
        timer.cancel();
        return;
      }
      PuzzleBoard nextState = solveMoves[0];
      moveAuto(con, nextState);
      solveMoves.removeAt(0);
    });
  }

  void solvePuzzleAsync(BuildContext con) async {
    List<PuzzleBoard> moves =
        await Provider.of<PuzzleGame>(con, listen: false).solveProblemStatic();
    setState(() {
      solving = false;
    });
    if (moves.isEmpty) return;
    PuzzleBoard nextState = moves[0];
    moveAuto(con, nextState);
    for (PuzzleBoard p in moves) {
      await Future.delayed(Duration(milliseconds: 200), () {
        moveAuto(con, p);
      });
    }
  }

  void hintAsync(BuildContext con) async {
    PuzzleBoard nextState =
        await Provider.of<PuzzleGame>(con, listen: false).hintAsunc();
    setState(() {
      solving = false;
    });
    moveAuto(con, nextState);
  }

  void hint(BuildContext con) {
    PuzzleBoard nextState =
        Provider.of<PuzzleGame>(context, listen: false).hint();
    moveAuto(context, nextState);

    setState(() {
      solving = false;
    });
  }

  void moveAuto(BuildContext con, PuzzleBoard nextState) {
    Tuple2<int, int> newEmptyLocation =
        Provider.of<PuzzleGame>(con, listen: false)
            .getEmptyBlockNewLocation(nextState);
    locationStreamController.add(newEmptyLocation);
  }

  @override
  Widget build(BuildContext context) {
    if (!boardInitialized) {
      boardWidget = PuzzleBoardWidget(
        locationStream: locationStreamController.stream,
        pb: Provider.of<PuzzleGame>(context, listen: false).gameBoard,
        moveBlcok: (MovingDirection direction) {
          Provider.of<PuzzleGame>(context, listen: false).moveBlock(direction);
          timerRunning = true;
        },
      );
      boardInitialized = true;
    }

    Widget timer = StreamBuilder<int>(
      stream: _stopWatchTimer.rawTime,
      initialData: 0,
      builder: (context, snap) {
        final value = snap.data;
        final displayTime = StopWatchTimer.getDisplayTime(
          value,
        );
        return Padding(
          padding: EdgeInsets.only(
            top: 30,
          ),
          child: Center(
            child: Text(
              displayTime,
              style: TextStyle(
                  fontSize: 50,
                  color: Color.fromRGBO(252, 163, 17, 1),
                  fontWeight: FontWeight.w900),
            ),
          ),
        );
      },
    );

    Widget progressBar = Container(
      padding: EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 25,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 50,
            height: 50,
            margin: EdgeInsets.only(
              right: 15,
            ),
            decoration: BoxDecoration(
              color: Color.fromRGBO(253, 238, 187, 1),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: 10,
                ),
                child: Text(
                  "Progress",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 270,
                height: 14,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey[200],
                  value: Provider.of<PuzzleGame>(context).progress1,
                  valueColor: _colorTween,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    Widget controlBar = Row(
      children: [
        Container(
          margin: EdgeInsets.only(
            left: 20,
          ),
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Color.fromRGBO(21, 146, 230, 1)),
          child: IconButton(
              icon: Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                setState(() {
                  solving = true;
                });
                solvePuzzleAsync(context);
              }),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Color.fromRGBO(21, 146, 230, 1)),
          child: IconButton(
              icon: Icon(
                Icons.lightbulb_outline,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                setState(() {
                  solving = true;
                });
                hintAsync(context);
              }),
        ),
        Container(
          margin: EdgeInsets.only(
            right: 35,
          ),
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Color.fromRGBO(21, 146, 230, 1)),
          child: IconButton(
              icon: Icon(
                timerRunning ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                if (timerRunning)
                  setState(() {
                    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                    timerRunning = false;
                  });
                else
                  setState(() {
                    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                    timerRunning = true;
                  });
              }),
        ),
        RaisedButton(
          color: Color.fromRGBO(21, 146, 230, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          onPressed: () {
            Provider.of<PuzzleGame>(context, listen: false).resetGame();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 18),
            child: Text(
              "Go Back",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );

    Widget solvingText = Opacity(
      opacity: solving ? 1 : 0,
      child: Padding(
        padding: EdgeInsets.only(
          top: 18,
          right: 290,
          bottom: 13,
        ),
        child: Text(
          "Solving...",
          style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
    );

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          timer,
          progressBar,
          Center(
            child: boardWidget,
          ),
          solvingText,
          controlBar,
        ],
      ),
    );
  }
}
