import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/loading_white/loading_white_widget.dart';
import 'nav_widget.dart' show NavWidget;
import 'package:flutter/material.dart';

class NavModel extends FlutterFlowModel<NavWidget> {
  ///  Local state fields for this component.

  bool isLoading = true;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Action Block - GetUserById] action in Nav widget.
  UserStruct? user;
  // Stores action output result for [Backend Call - API (deleteUserAndAssociatedData)] action in contentView_1 widget.
  ApiCallResponse? apiResultDeleteUserAndAssociatedData;
  // Model for LoadingWhite component.
  late LoadingWhiteModel loadingWhiteModel;

  @override
  void initState(BuildContext context) {
    loadingWhiteModel = createModel(context, () => LoadingWhiteModel());
  }

  @override
  void dispose() {
    loadingWhiteModel.dispose();
  }
}
