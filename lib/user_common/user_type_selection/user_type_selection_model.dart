import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/loading_black/loading_black_widget.dart';
import '/index.dart';
import 'user_type_selection_widget.dart' show UserTypeSelectionWidget;
import 'package:flutter/material.dart';

class UserTypeSelectionModel extends FlutterFlowModel<UserTypeSelectionWidget> {
  ///  Local state fields for this page.

  UserType? userTypeSelection;

  bool isLoading = true;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Action Block - GetUserById] action in UserTypeSelection widget.
  UserStruct? user;
  // Stores action output result for [Backend Call - API (updateUserProfile)] action in Button widget.
  ApiCallResponse? updateUserProfile;
  // Stores action output result for [Backend Call - API (createWallet)] action in Button widget.
  ApiCallResponse? apiResultCreateWallet;
  // Stores action output result for [Backend Call - API (createAssociateUserWallet)] action in Button widget.
  ApiCallResponse? apiResultCreateAssociateUserWallet;
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
