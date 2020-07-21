import 'dart:async';
import 'dart:collection';

import 'package:ai_first_project/Modules/PuzzleBoard.dart';
import 'package:ai_first_project/Modules/PuzzleGame.dart';
import 'package:ai_first_project/Widgets/tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class PuzzleBoardWidget extends StatefulWidget {
  final PuzzleBoard pb;
  final Stream<Tuple2<int, int>> locationStream;

  Function moveBlcok;

  PuzzleBoardWidget({
    Key key,
    this.pb,
    this.moveBlcok,
    this.locationStream,
  }) : super(key: key) {
    if (moveBlcok == null) moveBlcok = pb.moveBlock;
  }

  @override
  _PuzzleBoardWidgetState createState() => _PuzzleBoardWidgetState();
}

class _PuzzleBoardWidgetState extends State<PuzzleBoardWidget> {
  HashMap<Tuple2<int, int>, dynamic> blocks =
      HashMap<Tuple2<int, int>, dynamic>();

  int size;

  void moveTiles(MovingDirection direction) {
    setState(() {
      widget.moveBlcok(direction);
    });
  }

  void moveTilesAuto(Tuple2<int, int> location) {
    setState(blocks[location].moveBlocksFromBoard());
  }

  @override
  Widget build(BuildContext context) {
    bool win = Provider.of<PuzzleGame>(context, listen: false).win;

    size = widget.pb.boardSize.item1;

    for (int i = 0; i < size * size; i++) {
      MovingDirection possibleMove = MovingDirection.NONE;

      Tuple2<int, int> location = Tuple2<int, int>((i ~/ size), (i % size));

      if (widget.pb.board[location] == 0) {
        blocks[location] = EmptyPuzzleTile();
        continue;
      }

      Tuple2<int, int> aboveLocation =
          Tuple2(location.item1 - 1, location.item2);
      Tuple2<int, int> belowLocation =
          Tuple2(location.item1 + 1, location.item2);
      Tuple2<int, int> rightLocation =
          Tuple2(location.item1, location.item2 + 1);
      Tuple2<int, int> leftLocation =
          Tuple2(location.item1, location.item2 - 1);

      if (aboveLocation.item2 >= 0 && widget.pb.board[aboveLocation] == 0)
        possibleMove = MovingDirection.UP;
      else if (belowLocation.item2 < size &&
          widget.pb.board[belowLocation] == 0)
        possibleMove = MovingDirection.DOWN;
      else if (rightLocation.item1 < size &&
          widget.pb.board[rightLocation] == 0)
        possibleMove = MovingDirection.RIGHT;
      else if (leftLocation.item1 >= 0 && widget.pb.board[leftLocation] == 0)
        possibleMove = MovingDirection.LEFT;
      else
        possibleMove = MovingDirection.NONE;

      blocks[location] = PuzzleTile(
        boardSize: widget.pb.boardSize.item1,
        location: location,
        locationStream: widget.locationStream,
        digit: widget.pb.board[location],
        possibleMove: possibleMove,
        moveBlocks: moveTiles,
      );
    }

    return Container(
      width: 373,
      height: 370,
      padding: EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Color.fromRGBO(214, 214, 214, 1),
      ),
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: win ? 0.5 : 1,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 0, bottom: 0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: size,
                crossAxisSpacing: 16.5 / size,
                mainAxisSpacing: 7 / size,
              ),
              itemBuilder: (context, index) {
                Tuple2<int, int> location =
                    Tuple2<int, int>((index ~/ size), (index % size));
                return blocks[location];
              },
              itemCount: widget.pb.board.keys.length,
            ),
          ),
          Center(
            child: win
                ? Text(
                    "Solved",
                    style: TextStyle(
                        fontSize: 80,
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold),
                  )
                : Center(),
          )
        ],
      ),
    );
  }
}
