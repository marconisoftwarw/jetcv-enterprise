import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/alert_denied/alert_denied_widget.dart';
import '/utils/alert_success/alert_success_widget.dart';
import '/utils/alert_waiting/alert_waiting_widget.dart';
import '/utils/loading_black/loading_black_widget.dart';
import '/utils/nav/nav_widget.dart';
import '/index.dart';
import 'home_legal_entity_widget.dart' show HomeLegalEntityWidget;
import 'package:flutter/material.dart';

class HomeLegalEntityModel extends FlutterFlowModel<HomeLegalEntityWidget> {
  ///  Local state fields for this page.

  bool isLoading = true;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Action Block - GetUserById] action in HomeLegalEntity widget.
  UserStruct? user;
  // Stores action output result for [Action Block - GetLegalEntity] action in HomeLegalEntity widget.
  LegalEntityStruct? legalEntity;
  // Model for Nav component.
  late NavModel navModel;
  // Model for AlertWaiting component.
  late AlertWaitingModel alertWaitingModel;
  // Model for AlertSuccess component.
  late AlertSuccessModel alertSuccessModel;
  // Model for AlertDenied component.
  late AlertDeniedModel alertDeniedModel;
  // Model for LoadingBlack component.
  late LoadingBlackModel loadingBlackModel;

  @override
  void initState(BuildContext context) {
    navModel = createModel(context, () => NavModel());
    alertWaitingModel = createModel(context, () => AlertWaitingModel());
    alertSuccessModel = createModel(context, () => AlertSuccessModel());
    alertDeniedModel = createModel(context, () => AlertDeniedModel());
    loadingBlackModel = createModel(context, () => LoadingBlackModel());
  }

  @override
  void dispose() {
    navModel.dispose();
    alertWaitingModel.dispose();
    alertSuccessModel.dispose();
    alertDeniedModel.dispose();
    loadingBlackModel.dispose();
  }
}
