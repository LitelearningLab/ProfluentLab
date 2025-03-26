import 'package:flutter/material.dart';
import 'package:litelearninglab/constants/all_assets.dart';

class UnderConstruction extends StatefulWidget {
  UnderConstruction({
    Key? key,
  }) : super(key: key);

  @override
  _UnderConstructionState createState() {
    return _UnderConstructionState();
  }
}

class _UnderConstructionState extends State<UnderConstruction> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 15),
      //height: 265,
      decoration: new BoxDecoration(
        color: Colors.transparent,
        borderRadius: new BorderRadius.all(
          const Radius.circular(20.0),
        ),
      ),
      child: Image.asset(AllAssets.workInProgress),
    );
  }
}
