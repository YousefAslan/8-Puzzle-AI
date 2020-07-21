import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzleastar/Modules/PuzzleBoard.dart';
import 'package:puzzleastar/Modules/PuzzleGame.dart';
import 'package:tuple/tuple.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Testing());
  }
}

class Testing extends StatefulWidget {
  @override
  _TestingState createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  final Map<Tuple2<int, int>, int> block = {
    Tuple2(0, 0): 8,
    Tuple2(0, 1): 7,
    Tuple2(0, 2): 6,
    Tuple2(1, 0): 5,
    Tuple2(1, 1): 4,
    Tuple2(1, 2): 3,
    Tuple2(2, 0): 2,
    Tuple2(2, 1): 1,
    Tuple2(2, 2): 0
//
//     Tuple2(0, 0): 1,
//     Tuple2(0, 1): 2,
//     Tuple2(0, 2): 3,
//     Tuple2(1, 0): 4,
//     Tuple2(1, 1): 5,
//     Tuple2(1, 2): 6,
//     Tuple2(2, 0): 7,
//     Tuple2(2, 1): 8,
//     Tuple2(2, 2): 0
  };
  final Map<Tuple2<int, int>, int> block2 = {
    Tuple2(0, 0): 1,
    Tuple2(0, 1): 2,
    Tuple2(0, 2): 3,
    Tuple2(1, 0): 4,
    Tuple2(1, 1): 5,
    Tuple2(1, 2): 6,
    Tuple2(2, 0): 7,
    Tuple2(2, 1): 8,
    Tuple2(2, 2): 0
  };
  final Map<Tuple2<int, int>, int> block3 = {
    Tuple2(0, 0): 1,
    Tuple2(0, 1): 2,
    Tuple2(0, 2): 3,
    Tuple2(1, 0): 4,
    Tuple2(1, 1): 5,
    Tuple2(1, 2): 6,
    Tuple2(2, 0): 7,
    Tuple2(2, 1): 8,
    Tuple2(2, 2): 0
  };

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PuzzleGame>(create: (context) => PuzzleGame())
      ],
      child: SafeArea(
        child: SingleChildScrollView(child: Builder(builder: (context) {
          var game = Provider.of<PuzzleGame>(context, listen: false);
          return Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 20),
                height: 300,
                width: 300,
                child:
                    Consumer<PuzzleGame>(builder: (context, puzzleGame, child) {
                  var temp = game.gameBoard.toList();
                  return GridView.builder(
                    itemCount: (game.boardSize.item1 * game.boardSize.item2),
                    itemBuilder: (BuildContext ctxt, int index) {
                      return Container(
                        width: 90,
                        height: 90,
                        color: temp[index] != 0 ? (Colors.blueGrey) : null,
                        key: Key(temp[index].toString()),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(2),
                        margin: const EdgeInsets.all(8),
                        child: temp[index] != 0
                            ? Text(temp[index].toString())
                            : null,
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: game.boardSize.item1,
                    ),
                  );
                }),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                      child: Text("rebulid"),
                      onPressed: () => setState(() => print("rebulid"))),
                  RaisedButton(
                      child: Text("eqal"),
                      onPressed: () {
                        var temp = (game.gameBoard == game.theGoalBoard);
                        print("eqlallll:$temp");
                      }),
                  RaisedButton(
                      child: Text("ava"),
                      onPressed: () {
                        var temp = game.gameBoard.getAvailableMoves();
                        print("ava:$temp");
                      }),
                  RaisedButton(
                      child: Text("dialog"),
                      onPressed: () {
                        var t = DateTime.now();
                        List temp= game.solveTheProblem();
                        print((DateTime.now().difference(t)).toString());
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text((DateTime.now().difference(t)).toString()),
                              content: SingleChildScrollView(
                                child: Text(temp.toString())
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Approve'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }),RaisedButton(
                      child: Text("BFS"),
                      onPressed: () {
                        var t = DateTime.now();
                        var temp= game.bFS();
                        print((DateTime.now().difference(t)).toString());
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text((DateTime.now().difference(t)).toString()),
                              content: SingleChildScrollView(
                                  child: Text(temp.toString())
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Approve'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }),
                  RaisedButton(
                      child: Text("solve"),
                      onPressed: () async{
                        var t = DateTime.now();
                       List<PuzzleBoard>temp= game.solveTheProblem();
                        print((DateTime.now().difference(t)).toString());
                       print(temp);
                       print(temp.length);
                        const oneSec = const Duration(milliseconds: 300);
                        Timer.periodic(oneSec, (timer) {
                          if(temp.length !=0)
                            {
                              setState(() {
                                game.gameBoard = temp.removeAt(0);
                              });
                            }
                          else timer.cancel();
                        });
                      }),
                  RaisedButton(
                      child: Text("UP"),
                      onPressed: () {
                        // ignore: unnecessary_statements
                        (game.moveBlock(MovingDirection.UP));
                      }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                          child: Text("left"),
                          onPressed: () {
                            // ignore: unnecessary_statements
                            (game.moveBlock(MovingDirection.LEFT));
                          }),
                      RaisedButton(
                          child: Text("Right"),
                          onPressed: () {
                            // ignore: unnecessary_statements
                            (game.moveBlock(MovingDirection.RIGHT));
                          }),
                    ],
                  ),
                  RaisedButton(
                      child: Text("down"),
                      onPressed: () {
                        // ignore: unnecessary_statements
                        (game.moveBlock(MovingDirection.DOWN));
                      }),
                  RaisedButton(
                      child: Text("hu"),
                      onPressed: () {
                        print(game.computeHeuristic2(game.gameBoard));
                      }),
                  RaisedButton(
                      child: Text("hint"),
                      onPressed: () async {
//                        var t = DateTime.now();
                        game.hint();
                      }),
                  Column(
                    children: [
                      RaisedButton(
                          child: Text("init"),
                          onPressed: () {
                            game.gameInitializer(
                                boardSize: Tuple2(3, 3),
                                goalBlocks: block2,
                                initBlocks: block,
                                secondGoal: block3,
                                heuristicType: HeuristicType.manhattanDistance);
                          }),
                      RaisedButton(
                          child: Text("display"),
                          onPressed: () {
                            print("bfhfhjfjf");
                            print(game.gameBoard);
                            print("------------------------");
                            print(game.theGoalBoard);
                            print("------------------------");
                            print(game.secondGoal);
                            print("------------------------");
                            print("bfhfhjfjf");
                          }),
                    ],
                  )
                ],
              )
            ],
          );
        })),
      ),
    );
  }
}
