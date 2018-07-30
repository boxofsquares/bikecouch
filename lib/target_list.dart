import 'package:flutter/material.dart';
import 'package:bikecouch/components/list_card.dart';

class TargetList extends StatefulWidget {
  final List<String> challenge;

  TargetList({Key key, this.challenge}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TargetListState();
  }
}

class TargetListState extends State<TargetList> {
  String _selectedTarget;

  @override
  void initState() {
    //TODO: Fetch all friends from somewhere...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Pick Your Target!'),
      ),
      body: new ListView(
        children: buildFriendList(),
      ),
      floatingActionButton: _selectedTarget != null
          ? RaisedButton(
              child: Text("Choose your target!",
                  style: TextStyle(fontSize: 18.00)),
              onPressed: () => null,
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.00, horizontal: 32.00),
              shape: new RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    999.99), // choosing a ridiculous number makes the bordes circular
                side: BorderSide(color: Colors.transparent),
              ))
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  List<Widget> buildFriendList() {
    return <Widget>[
      new ListCard(
        isSelected: _selectedTarget == 'Random Friend 1',
        text: 'Random Friend 1',
        onTap: selectTarget,
      ),
      new ListCard(
        isSelected: _selectedTarget == 'Random Friend 2',
        text: 'Random Friend 2',
        onTap: selectTarget,
      ),
    ];
  }

  void selectTarget(String targetName) {
    setState(() {
      _selectedTarget = targetName;
    });
  }
}
