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
        child: Image.network(
      './icons/bop_twol.png',
      fit: BoxFit.contain,
      height: 40,
    ),
    padding: EdgeInsets.fromLTRB(3, 50, 3, 50),
    );

    artsList.add(header);
    Map<String, Art> arts = appState.getArts();
    Art selected = appState.getSelectedArt();
    arts.forEach((k, v) {
      Widget t;
      if (k == selected.name) {
        t = Text(k, style: TextStyle(fontWeight: FontWeight.bold));
      } else {
        t = Text(k);
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
    ListView list = ListView(
      children: artsList);
    return Drawer(
      child: list,
    );
  }
}

