import '/flutter_flow/flutter_flow_util.dart';
import '/utils/loading_black/loading_black_widget.dart';
import '/index.dart';
import 'logout_widget.dart' show LogoutWidget;
import 'package:flutter/material.dart';

class LogoutModel extends FlutterFlowModel<LogoutWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for LoadingBlack component.
  late LoadingBlackModel loadingBlackModel;

  @override
  void initState(BuildContext context) {
    loadingBlackModel = createModel(context, () => LoadingBlackModel());
  }

  @override
  void dispose() {
    loadingBlackModel.dispose();
  }
}
