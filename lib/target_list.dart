import 'package:flutter/material.dart';

import 'components/list_card.dart';
import 'components/pill_button.dart';

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
    super.initState();
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
          ? PillButton(
            text: 'Send the challenge!',
            onTap: () => null,
          )
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