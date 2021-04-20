import 'dart:ui';
import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/Firebase/auth_repository.dart';
import 'package:hello_me/SheetContent.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'RandomWords.dart';

class MySnappingSheet extends StatefulWidget {
  var _suggestions = <WordPair>[];
  double sigmaX = 0;
  double sigmaY = 0;
  MySnappingSheet(this._suggestions);

  @override
  _MySnappingSheetState createState() => _MySnappingSheetState();
}

class _MySnappingSheetState extends State<MySnappingSheet> {
  final snappingSheetController = SnappingSheetController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SnappingSheet(
        controller: snappingSheetController,
        child: RandomWords(snappingSheetController,widget._suggestions),
        grabbingHeight: 60,
        grabbing: GrabbingWidget(snappingSheetController,widget.sigmaX,widget.sigmaY),
        sheetBelow: SnappingSheetContent(
          draggable: true,
          sizeBehavior: SheetSizeFill(),
          child: SheetContent(),
        ),
        snappingPositions: [
          SnappingPosition.pixels(positionPixels: 30),
          SnappingPosition.pixels(positionPixels: 190),
        ],
        onSheetMoved: (sheetPosition) {
          widget.sigmaX = (sheetPosition - 30) / 50;
          widget.sigmaY = (sheetPosition - 30) / 50;
          setState(() {});
        },
      ),
    );
  }
}



class GrabbingWidget extends StatelessWidget {
  SnappingSheetController snappingSheetController;
  double sigmaX;
  double sigmaY;

  GrabbingWidget(this.snappingSheetController, this.sigmaX, this.sigmaY);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: sigmaX,
        sigmaY: sigmaY,
      ) ,
      child: ColoredBox(
      color:Colors.grey.shade300,
        child : GestureDetector(
            child: Row(
              children: [
                SizedBox(width: 15),
                Text("Welcome Back, " + AuthRepository.instance().user!.email!),
                SizedBox(width: 100),
                Icon(Icons.keyboard_arrow_up_outlined)
              ],
            ),
          onTap: (){
            if(snappingSheetController.isAttached){
              if(snappingSheetController.currentPosition == 30.0){
                snappingSheetController.snapToPosition(SnappingPosition.pixels(positionPixels: 190.0));
              }else{
                snappingSheetController.snapToPosition(SnappingPosition.pixels(positionPixels: 30.0));
              }
            }
          },
        )
      )
    );
  }
}
