import 'package:ai_first_project/Modules/PuzzleGame.dart';
import 'package:ai_first_project/Pages/arrange.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';

class MainPanel extends StatefulWidget {
  @override
  _MainPanelState createState() => _MainPanelState();
}

class _MainPanelState extends State<MainPanel> {
  List<HeuristicType> selectedAlgorithm = [HeuristicType.tilesDifferences];
  int size;

  @override
  void initState() {
    super.initState();
    size = 3;
  }

  @override
  Widget build(BuildContext context) {
    Widget title = Container(
      padding: EdgeInsets.only(
        top: 20,
        bottom: 10,
      ),
      child: Text(
        "8 Puzzle",
        style: TextStyle(
          color: Colors.white,
          fontSize: 35,
          fontWeight: FontWeight.w600,
            fontFamily: 'relway-semibold'
        ),
      ),
    );

    Widget subtitle = Text(
      "Try solving the very famous 8 Puzzle and compete with puzzle solvers from all around the world!",
      softWrap: true,
      style: TextStyle(
          fontSize: 20,
          height: 1.2,
          color: Colors.white,
          fontWeight: FontWeight.bold),
    );

    Widget sizeText = Container(
      child: Text(
        "Please select the board size",
        style: TextStyle(
            color: Color.fromRGBO(252, 163, 17, 1),
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
    );

    Widget sizeFeild = Theme(
      data: ThemeData(
        primaryColor: Colors.white,
        primaryColorDark: Colors.red,
      ),
      child: Container(
        width: 250,
        child: TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
          onChanged: (value) {
            int newSize = int.parse(value);
            if (newSize > 0) {
              size = newSize;
            }
          },
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly,
          ],
        ),
      ),
    );

    Widget heuristicText = Container(
//      padding: EdgeInsets.only(
//        top: 27,
//      ),
      child: Text(
        "Choose the heuristic algorithm",
        style: TextStyle(
          color: Color.fromRGBO(252, 163, 17, 1),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    Widget heuristicFeild = Container(
      width: 250,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Color.fromRGBO(41, 41, 41, 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (selectedAlgorithm
                      .contains(HeuristicType.tilesDifferences))
                    selectedAlgorithm.remove(HeuristicType.tilesDifferences);
                  else
                    selectedAlgorithm.add(HeuristicType.tilesDifferences);
                });
              },
              child: Container(
                height: 70,
                alignment:Alignment.center ,
                margin: EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 3,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color:
                      selectedAlgorithm.contains(HeuristicType.tilesDifferences)
                          ? Color.fromRGBO(255, 170, 0, 1)
                          : Color.fromRGBO(41, 41, 41, 1),
                ),
                child: Text(
                  "Tiles\nDifference",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Flexible(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (selectedAlgorithm
                      .contains(HeuristicType.manhattanDistance))
                    selectedAlgorithm.remove(HeuristicType.manhattanDistance);
                  else
                    selectedAlgorithm.add(HeuristicType.manhattanDistance);
                });
              },
              child: Container(
                height: 70,
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 3,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: selectedAlgorithm
                          .contains(HeuristicType.manhattanDistance)
                      ? Color.fromRGBO(255, 170, 0, 1)
                      : Color.fromRGBO(41, 41, 41, 1),
                ),
                child: Text(
                  "Manhattan Distance",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Widget playButton = Padding(
      padding: EdgeInsets.only(right: 10, bottom: 12),
      child: RaisedButton(
        color: Color.fromRGBO(21, 146, 230, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: () {
          Tuple2<int, int> boardSize = Tuple2<int, int>(size, size);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArrangePage(
                boardSize: boardSize,
                selectedAlgorithm: HeuristicType.manhattanDistance,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 20,
          ),
          child: Text(
            "Arrange goal",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(left: 15),
          margin: EdgeInsets.only(
            top: 30,
            bottom: 30,
            right: 40,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(20)),
            gradient: LinearGradient(colors: [
              Color.fromRGBO(53, 120, 177, 1),
              Color.fromRGBO(14, 36, 83, 1)
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  subtitle,
                  SizedBox(
                    height: 40,
                  ),
                  Wrap(
                    runSpacing: 12,
                    children: [
                      sizeText,
                      sizeFeild,
                      heuristicText,
                      heuristicFeild,
                    ],
                  ),
                ],
              ),
              Container(
                alignment: Alignment.bottomRight,
                child: playButton,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
