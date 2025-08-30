import '/flutter_flow/flutter_flow_util.dart';
import '/utils/nav/nav_widget.dart';
import 'my_wallets_widget.dart' show MyWalletsWidget;
import 'package:flutter/material.dart';

class MyWalletsModel extends FlutterFlowModel<MyWalletsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Nav component.
  late NavModel navModel;

  @override
  void initState(BuildContext context) {
    navModel = createModel(context, () => NavModel());
  }

  @override
  void dispose() {
    navModel.dispose();
  }
}
