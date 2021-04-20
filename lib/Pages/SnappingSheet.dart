import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/Firebase/FirebaseHelper.dart';
import 'package:hello_me/Firebase/auth_repository.dart';
import 'package:hello_me/SheetContent.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import 'RandomWords.dart';

class MySnappingSheet extends StatelessWidget {
  final snappingSheetController = SnappingSheetController();
  var _suggestions = <WordPair>[];

  MySnappingSheet(this._suggestions);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SnappingSheet(
        controller: snappingSheetController,
        child: RandomWords(snappingSheetController,_suggestions),
        grabbingHeight: 60,
        // TODO: Add your grabbing widget here,
        grabbing: GrabbingWidget(),
        sheetBelow: SnappingSheetContent(
          draggable: true,
          sizeBehavior: SheetSizeFill(),
          // TODO: Add your sheet content here
          child: SheetContent(),
        ),
        snappingPositions: [
          SnappingPosition.pixels(positionPixels: 30),
          SnappingPosition.pixels(positionPixels: 190),
        ],
        onSheetMoved: (position) {

        },
      ),
    );
  }
}


class GrabbingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color:Colors.grey.shade300,
        child :Row(
          children: [
            SizedBox(width: 15),
            Text("Welcome Back, " + AuthRepository.instance().user!.email!),
            SizedBox(width: 100),
            Icon(Icons.keyboard_arrow_up_outlined)
          ],
        )
    );
  }
}
