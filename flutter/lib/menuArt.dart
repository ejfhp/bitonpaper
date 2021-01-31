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
    BOPState state = ArtMenuInh.of(context).state;
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
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );

    List<Widget> artsList = new List<Widget>.empty(growable: true);
    artsList.add(headerContainer);
    Map<String, List<Art>> arts = state.getArts();
    arts.forEach((artName, artFlavs) {
      artsList.add(ArtButton(arts: artFlavs, wide: wide, state: state));
    });
    ListView list = ListView(
      children: artsList,
    );
    return Drawer(
      elevation: 0,
      child: list,
    );
  }
}

class ArtButton extends StatefulWidget {
  final List<Art> arts;
  final bool wide;
  final BOPState state;

  ArtButton({this.arts, this.wide, this.state});

  State createState() => _ArtButtonState();
}

class _ArtButtonState extends State<ArtButton> {
  Art shown;
  int fIndex = 0;

  initState() {
    super.initState();
    this.shown = widget.arts.first;
  }

  _setShown(int val) {
    setState(() {
      print("Flavours: " + widget.arts.length.toString() + " selected: " + val.toString());
      if (val < widget.arts.length) {
        fIndex = val;
        shown = widget.arts[fIndex];
      }
    });
  }

  int getLastFlavourIndex() {
    if (widget.arts.isEmpty) {
      return 0;
    }
    print("getLastFlavourIndex: " + (widget.arts.length - 1).toString());
    return widget.arts.length - 1;
  }

  Widget build(BuildContext context) {
    bool sel = (widget.state.getSelectedArt().name == shown.name) && (widget.state.getSelectedArt().flavour == shown.flavour);
    TextStyle nameTextStyle = Theme.of(context).textTheme.headline5;
    TextStyle flavTextStyle = Theme.of(context).textTheme.headline6;
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Container(
        decoration: ShapeDecoration(
          color: Colors.blueGrey,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: sel ? Colors.amber : Colors.blueGrey, width: sel ? 3 : 3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Positioned(
                      child: Container(
                        height: 70,
                        padding: EdgeInsets.all(5),
                        child: Image(image: MemoryImage(shown.bytes)),
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(onTap: () {
                          widget.state.selectArt(shown);
                          //Close the drawer when user selects.
                          if (!widget.wide) {
                            Navigator.pop(context);
                          }
                        }),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        shown.name,
                        style: TextStyle(
                          fontFamily: nameTextStyle.fontFamily,
                          fontSize: nameTextStyle.fontSize,
                          color: sel ? Colors.amber : Colors.blueGrey[50],
                        ),
                      ),
                      Text(
                        shown.flavour,
                        style: TextStyle(
                          fontFamily: flavTextStyle.fontFamily,
                          fontSize: flavTextStyle.fontSize,
                          color: sel ? Colors.amber : Colors.blueGrey[50],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              height: 20,
              child: (widget.arts.length > 1)
                  ? Slider(
                      value: fIndex.toDouble(),
                      min: 0,
                      max: getLastFlavourIndex().toDouble(),
                      divisions: getLastFlavourIndex(),
                      // label: _getShown().flavour.toString(),
                      onChanged: (value) {
                        _setShown(value.toInt());
                      },
                      activeColor: Colors.amber,
                      inactiveColor: Colors.blueGrey[50],
                    )
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
