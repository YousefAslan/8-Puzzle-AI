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
                height: 250,
                width: 250,
                child:
                    Consumer<PuzzleGame>(builder: (context, puzzleGame, child) {
                  var temp = game.gameBoard.toList();
                  return GridView.builder(
                    itemCount: (game.boardSize.item1 * game.boardSize.item2),
                    itemBuilder: (BuildContext ctxt, int index) {
                      return Container(
                        key: Key(temp[index].toString()),
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(8),
                        child: Text(temp[index].toString()),
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
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
                      child: Text("solve"),
                      onPressed: () {
                        var temp = game.solveTheProblem();
                      }),
                  RaisedButton(
                      child: Text("UP"),
                      onPressed: () {
                        print(game.moveBlock(MovingDirection.UP));
                      }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                          child: Text("Right"),
                          onPressed: () {
                            print(game.moveBlock(MovingDirection.RIGHT));
                          }),
                      RaisedButton(
                          child: Text("left"),
                          onPressed: () {
                            print(game.moveBlock(MovingDirection.LEFT));
                          }),
                    ],
                  ),
                  RaisedButton(
                      child: Text("down"),
                      onPressed: () {
                        print(game.moveBlock(MovingDirection.DOWN));
                      }),
                  RaisedButton(
                      child: Text("hu"),
                      onPressed: () {
                        print(game.computeHeuristic1(game.gameBoard));
                      }),
                  RaisedButton(
                      child: Text("hint"),
                      onPressed: () {
                        var temp = game.aStarAlgorithm();
                        print("nhnhjdnjd");
                        print(temp);
//                        game.gameBoard = temp.removeFirst();
                      }),
                  Column(
                    children: [
                      RaisedButton(
                          child: Text("init"),
                          onPressed: () {
                            game.gameInitializer(
                                boardSize: Tuple2(3, 3),
                                goalBlocks: block2,
                                initBlocks: block);
                          }),
                      RaisedButton(
                          child: Text("display"),
                          onPressed: () {
                            print(game.gameBoard);
                            print("------------------------");
                            print(game.theGoalBoard);
                            print("------------------------");
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
