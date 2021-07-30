import 'package:flutter/material.dart';

import 'bopCentral.dart';

class BOPInherited extends InheritedWidget {
  final BOPCentral bopCentral;

  BOPInherited(this.bopCentral, {Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  static BOPInherited of(BuildContext context) {
    final BOPInherited result = context.dependOnInheritedWidgetOfExactType<BOPInherited>();
    assert(result != null, 'No FrogColor found in context');
    return result;
  }
}
