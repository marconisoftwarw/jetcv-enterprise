import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/loading_black/loading_black_widget.dart';
import '/index.dart';
import 'kyc_request_session_widget.dart' show KycRequestSessionWidget;
import 'package:flutter/material.dart';

class KycRequestSessionModel extends FlutterFlowModel<KycRequestSessionWidget> {
  ///  Local state fields for this page.

  bool isLoading = true;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Action Block - GetUserById] action in KycRequestSession widget.
  UserStruct? user;
  // Stores action output result for [Backend Call - API (sessionRequestVeriffNew)] action in KycRequestSession widget.
  ApiCallResponse? apiResultSessionRequestVeriff;
  // Stores action output result for [Backend Call - API (createKycAttempt)] action in Button widget.
  ApiCallResponse? apiResultCreateKycAttempt;
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
