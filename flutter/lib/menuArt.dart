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
    List<Art> arts = state.getArts();
    Map<String, List<Art>> flArts = Map<String, List<Art>>();
    for (int i = 0; i < arts.length; i++) {
      if (flArts[arts[i].name] != null) {
        flArts[arts[i].name].add(arts[i]);
      } else {
        flArts[arts[i].name] = List<Art>.empty(growable: true);
      }
    }
    flArts.forEach((artName, artList) {
      print("artName: " + artName);
      artsList.add(ArtButton(artList, wide, state));
    });

    ListView list = ListView(
      children: artsList,
    );
    return Drawer(
      elevation: 0,
      child: list,
    );
  }

//   Widget _buildArtItem(
//     BuildContext context,
//     BOPState state,
//     Art art,
//     Art selected,
//   ) {
//     bool sel = false;
//     if (selected != null && art == selected) {
//       sel = true;
//     }
//     return Container(
//       margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
//       child: Stack(
//         children: [
//           Positioned(
//             child: Container(
//               decoration: ShapeDecoration(
//                 color: Colors.blueGrey,
//                 shape: RoundedRectangleBorder(
//                   side: BorderSide(color: sel ? Colors.amber : Colors.black54, width: sel ? 3 : 1),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     height: 70,
//                     padding: EdgeInsets.all(5),
//                     child: Image(image: MemoryImage(art.bytes)),
//                   ),
//                   Container(
//                     padding: EdgeInsets.all(5),
//                     alignment: Alignment.center,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(
//                           art.name,
//                           style: sel ? Theme.of(context).textTheme.headline5 : Theme.of(context).textTheme.headline6,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned.fill(
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(onTap: () {
//                 state.selectArt(art);
//                 //Close the drawer when user selects.
//                 if (!wide) {
//                   Navigator.pop(context);
//                 }
//               }),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
}

class ArtButton extends StatefulWidget {
  final List<Art> arts;
  final bool wide;
  final BOPState state;

  ArtButton(this.arts, this.wide, this.state);

  State createState() => _ArtButtonState();
}

class _ArtButtonState extends State<ArtButton> {
  Art shown;

  _ArtButtonState() {
    if (widget.arts != null) {
      this.shown = widget.arts.first;
    }
  }

  Widget build(BuildContext context) {
    if (shown == null) {
      return Text("null");
    }
    bool sel = widget.state.getSelectedArt().name == shown.name;
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Stack(
        children: [
          Positioned(
            child: Container(
              decoration: ShapeDecoration(
                color: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: sel ? Colors.amber : Colors.black54, width: sel ? 3 : 1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 70,
                    padding: EdgeInsets.all(5),
                    child: Image(image: MemoryImage(shown.bytes)),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          shown.name,
                          style: sel ? Theme.of(context).textTheme.headline5 : Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
    );
  }

  _setShown(Art art) {
    setState(() {
      shown = art;
    });
  }
}
