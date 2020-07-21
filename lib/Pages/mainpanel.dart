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
        top: 14,
        bottom: 25,
      ),
      child: Text(
        "8 Puzzle",
        style: TextStyle(
          color: Colors.white,
          fontSize: 35,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    Widget subtitle = Text(
      "Try solving the very famous \n8 Puzzle and compete\nwith puzzle solvers from \nall around the world!",
      softWrap: true,
      style: TextStyle(
          fontSize: 20,
          height: 1.5,
          color: Colors.white,
          fontWeight: FontWeight.bold),
    );

    Widget sizeText = Container(
      padding: EdgeInsets.only(
        top: 34,
      ),
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
        margin: EdgeInsets.only(right: 150, top: 15),
        child: TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
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
            WhitelistingTextInputFormatter.digitsOnly
          ],
        ),
      ),
    );

    Widget heuristicText = Container(
      padding: EdgeInsets.only(
        top: 27,
      ),
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
      margin: EdgeInsets.only(top: 27, right: 112),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Color.fromRGBO(41, 41, 41, 1),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (selectedAlgorithm.contains(HeuristicType.tilesDifferences))
                  selectedAlgorithm.remove(HeuristicType.tilesDifferences);
                else
                  selectedAlgorithm.add(HeuristicType.tilesDifferences);
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: 2,
                horizontal: 4,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
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
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                if (selectedAlgorithm.contains(HeuristicType.manhattanDistance))
                  selectedAlgorithm.remove(HeuristicType.manhattanDistance);
                else
                  selectedAlgorithm.add(HeuristicType.manhattanDistance);
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: 2,
                horizontal: 4,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color:
                    selectedAlgorithm.contains(HeuristicType.manhattanDistance)
                        ? Color.fromRGBO(255, 170, 0, 1)
                        : Color.fromRGBO(41, 41, 41, 1),
              ),
              child: Text(
                "Manhattan\nDistance",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Widget playButton = Padding(
      padding: EdgeInsets.only(top: 65, left: 103),
      child: RaisedButton(
        color: Color.fromRGBO(21, 146, 230, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
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
            vertical: 18,
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
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
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
          child: ListView(
            children: [
              title,
              subtitle,
              sizeText,
              sizeFeild,
              heuristicText,
              heuristicFeild,
              playButton,
            ],
          ),
        ),
      ),
    );
  }
}
