import 'package:flutter/material.dart';
import 'BOPState.dart';
import 'art.dart';

class MenuInh extends InheritedWidget {
  final BOPState state;
  MenuInh({Widget child, this.state}) : super(child: child);

  @override
  bool updateShouldNotify(covariant MenuInh oldWidget) {
    return oldWidget.state.getSelectedArt() != state.getSelectedArt();
  }

  static MenuInh of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MenuInh>();
  }
}

class Menu extends StatelessWidget {
  Widget build(BuildContext context) {
    BOPState appState = MenuInh.of(context).state;
    List<Widget> artsList = new List<Widget>.empty(growable: true);
    DrawerHeader header = DrawerHeader(
        child: Container(
      color: Colors.blueGrey,
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      alignment: Alignment.bottomLeft,
      child: Text(
        "Arts",
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.amber,
          fontFamily: "Roboto",
          fontSize: 50,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    ));

    artsList.add(header);
    Map<String, Art> arts = appState.getArts();
    Art selected = appState.getSelectedArt();
    arts.forEach((k, v) {
      Widget t;
      if (k == selected.name) {
        t = Text(k, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Roboto", color: Colors.black54));
      } else {
        t = Text(k, style: TextStyle(fontFamily: "Roboto", color: Colors.black54));
      }
      var i = Image.network(v.url);
      ListTile tI = ListTile(
        leading: i,
        title: t,
        onTap: () {
          appState.setSelected(k);
          //Close the drawer when user selects.
          Navigator.pop(context);
        },
      );
      artsList.add(tI);
    });
    ListView list = ListView(children: artsList);
    return Drawer(
      child: list,
    );
  }
}
