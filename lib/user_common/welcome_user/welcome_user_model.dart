import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/loading_white/loading_white_widget.dart';
import '/index.dart';
import 'welcome_user_widget.dart' show WelcomeUserWidget;
import 'package:flutter/material.dart';

class WelcomeUserModel extends FlutterFlowModel<WelcomeUserWidget> {
  ///  Local state fields for this page.

  bool isLoading = true;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Action Block - GetUserById] action in WelcomeUser widget.
  UserStruct? user;
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
