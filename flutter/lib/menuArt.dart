import 'package:flutter/material.dart';
import 'BOPState.dart';
import 'art.dart';
import 'conf.dart';

class ArtMenuInh extends InheritedWidget {
  final BOPState state;
  ArtMenuInh({Widget child, this.state}) : super(child: child);

  @override
  bool updateShouldNotify(covariant ArtMenuInh oldWidget) {
    return (oldWidget.state.getSelectedArt() != state.getSelectedArt() || oldWidget.state.numArts() != state.numArts());
  }

  static ArtMenuInh of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ArtMenuInh>();
  }
}

class ArtMenu extends StatelessWidget {
  final bool wide;
  ArtMenu({@required this.wide});

  Widget build(BuildContext context) {
    BOPState appState = ArtMenuInh.of(context).state;
    List<Widget> artsList = new List<Widget>.empty(growable: true);
    Container headerContainer = Container(
        height: HEADER_HEIGHT,
        child: DrawerHeader(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
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
            )));

    artsList.add(headerContainer);
    Map<String, Art> arts = appState.getArts();
    Art selected = appState.getSelectedArt();
    if (selected != null) {
      arts.forEach((k, v) {
        ImageProvider aip = MemoryImage(v.bytes);
        Widget t;
        if (k == selected.name) {
          t = Text(k, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Roboto", color: Colors.black54));
        } else {
          t = Text(k, style: TextStyle(fontFamily: "Roboto", color: Colors.black54));
        }
        var img = Image(image: aip);
        ListTile tI = ListTile(
          leading: img,
          title: t,
          onTap: () {
            appState.selectArt(k);
            //Close the drawer when user selects.
            if (!wide) {
              Navigator.pop(context);
            }
          },
        );
        artsList.add(tI);
      });
    }
    ListView list = ListView(
      children: artsList,
      padding: EdgeInsets.zero,
    );
    return Drawer(
      elevation: 0,
      child: list,
    );
  }
}