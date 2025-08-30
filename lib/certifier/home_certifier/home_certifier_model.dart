import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/alert_waiting/alert_waiting_widget.dart';
import '/utils/loading_black/loading_black_widget.dart';
import '/utils/nav/nav_widget.dart';
import 'home_certifier_widget.dart' show HomeCertifierWidget;
import 'package:flutter/material.dart';

class HomeCertifierModel extends FlutterFlowModel<HomeCertifierWidget> {
  ///  Local state fields for this page.

  bool isLoading = true;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Action Block - GetUserById] action in HomeCertifier widget.
  UserStruct? user;
  // Stores action output result for [Backend Call - API (checkUserHasActiveCertifier)] action in HomeCertifier widget.
  ApiCallResponse? apiResultCheckUserHasActiveCertifier;
  // Model for Nav component.
  late NavModel navModel;
  // Model for AlertWaiting component.
  late AlertWaitingModel alertWaitingModel;
  // Model for LoadingBlack component.
  late LoadingBlackModel loadingBlackModel;

  @override
  void initState(BuildContext context) {
    navModel = createModel(context, () => NavModel());
    alertWaitingModel = createModel(context, () => AlertWaitingModel());
    loadingBlackModel = createModel(context, () => LoadingBlackModel());
  }

  @override
  void dispose() {
    navModel.dispose();
    alertWaitingModel.dispose();
    loadingBlackModel.dispose();
  }
}
