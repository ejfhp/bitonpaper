import 'dart:typed_data';
import 'package:bop/ui/bopCentral.dart';
import 'package:bop/ui/bopInherited.dart';
import 'package:flutter/material.dart';
import 'package:bop/graphic/art.dart';

class ArtList extends StatefulWidget {
  ArtList(Key key) : super(key: key);

  @override
  ArtListState createState() => ArtListState();
}

class ArtListState extends State<ArtList> {
  ArtListState();

  setSelected(BOPCentral bopCentral, Art art) async {
    await bopCentral.setSelectedArt(art);
    setState(() {
      print("artList.SetSelected " + art.name + " " + art.subname);
    });
  }

  @override
  Widget build(BuildContext context) {
    BOPCentral bopCentral = BOPInherited.of(context).bopCentral;
    // TextStyle kindTextStyle = Theme.of(context).textTheme.headline5;
    Widget list = Container(
      child: ListView.builder(
          itemCount: bopCentral.getArtsCount(),
          scrollDirection: Axis.vertical,
          cacheExtent: 50,
          addAutomaticKeepAlives: true,
          itemBuilder: (context, indexK) {
            String name = bopCentral.getArtName(indexK);
            return ArtBox(
              artsListState: this,
              name: name,
              // subname: subname,
            );
            // return Container(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Container(
            //         padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
            //         alignment: Alignment.bottomLeft,
            //         child: Text(
            //           name.toUpperCase(),
            //           style: kindTextStyle,
            //         ),
            //         height: 50,
            //         width: 500,
            //       ),
            //       Container(
            //         height: 220,
            //         child: ListView.builder(
            //           scrollDirection: Axis.horizontal,
            //           itemCount: bopCentral.getArtsSubnameCount(name),
            //           cacheExtent: 30,
            //           addAutomaticKeepAlives: true,
            //           itemBuilder: (context, indexF) {
            //             String subname = bopCentral.getArtSubname(name, indexF);
            //             return ArtBox(
            //               artsListState: this,
            //               name: name,
            //               subname: subname,
            //             );
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // );
          }),
    );
    return list;
  }
}

class ArtBox extends StatefulWidget {
  final ArtListState artsListState;
  final String name;
  // final String subname;

  ArtBox({@required this.artsListState, @required this.name});

  @override
  _ArtBoxState createState() => _ArtBoxState();
}

class _ArtBoxState extends State<ArtBox> with AutomaticKeepAliveClientMixin<ArtBox> {
  _ArtBoxState();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    BOPCentral bopCentral = BOPInherited.of(context).bopCentral;
    TextStyle flavTextStyle = Theme.of(context).textTheme.headline6;
    Art art = bopCentral.getArt(widget.name);
    int w = art.width;
    int h = art.height;
    double mh = 158;
    double mw = (mh / h) * w;
    Uint8List overlayBytes = art.demoOverlay;
    return Container(
      margin: EdgeInsets.fromLTRB(2, 2, 0, 0),
      child: Column(
        //The column here is just to make the card shrink to its content
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              widget.artsListState.setSelected(bopCentral, art);
            },
            child: Card(
              elevation: 10,
              borderOnForeground: true,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: bopCentral.isSelectedArt(art) ? Colors.amber : Colors.blueGrey[300], width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: BoxConstraints(maxHeight: mh, maxWidth: mw),
                    margin: EdgeInsets.all(4),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Center(child: Image(image: MemoryImage(art.template), fit: BoxFit.scaleDown)),
                        ),
                        Positioned.fill(
                          child: Center(child: Image(image: MemoryImage(overlayBytes), fit: BoxFit.scaleDown)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(4, 0, 4, 4),
                    constraints: BoxConstraints(minWidth: 200, minHeight: 30),
                    width: mw,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: bopCentral.isSelectedArt(art) ? Colors.amber : Colors.blueGrey[300], width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Container(padding: EdgeInsets.all(4), child: Text(art.name.toUpperCase() + " " + art.subname.toUpperCase(), style: flavTextStyle)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
