import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/loading_black/loading_black_widget.dart';
import '/index.dart';
import 'routing_widget.dart' show RoutingWidget;
import 'package:flutter/material.dart';

class RoutingModel extends FlutterFlowModel<RoutingWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Action Block - GetUserById] action in Routing widget.
  UserStruct? user;
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
