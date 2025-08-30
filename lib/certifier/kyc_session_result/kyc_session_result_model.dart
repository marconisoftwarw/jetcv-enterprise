import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/utils/alert_denied/alert_denied_widget.dart';
import '/utils/alert_success/alert_success_widget.dart';
import '/utils/alert_waiting/alert_waiting_widget.dart';
import '/utils/loading_black/loading_black_widget.dart';
import '/index.dart';
import 'kyc_session_result_widget.dart' show KycSessionResultWidget;
import 'package:flutter/material.dart';

class KycSessionResultModel extends FlutterFlowModel<KycSessionResultWidget> {
  ///  Local state fields for this page.

  bool isLoading = true;

  KycStatus? kycStatus = KycStatus.pending;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (getLastKycAttempt)] action in KycSessionResult widget.
  ApiCallResponse? apiResultGetLastKycAttempt;
  InstantTimer? instantTimer;
  // Stores action output result for [Backend Call - API (checkSessionVeriff)] action in KycSessionResult widget.
  ApiCallResponse? apiResultCheckSessionVeriff;
  // Stores action output result for [Backend Call - API (updateKycVerification)] action in KycSessionResult widget.
  ApiCallResponse? apiResultUpdateKycVerification;
  // Stores action output result for [Backend Call - API (updateUserProfile)] action in KycSessionResult widget.
  ApiCallResponse? apiResultUpdateUserProfile;
  // Model for AlertWaiting component.
  late AlertWaitingModel alertWaitingModel;
  // Model for AlertSuccess component.
  late AlertSuccessModel alertSuccessModel;
  // Model for AlertDenied component.
  late AlertDeniedModel alertDeniedModel;
  // Model for LoadingBlack component.
  late LoadingBlackModel loadingBlackModel1;
  // Model for LoadingBlack component.
  late LoadingBlackModel loadingBlackModel2;

  @override
  void initState(BuildContext context) {
    alertWaitingModel = createModel(context, () => AlertWaitingModel());
    alertSuccessModel = createModel(context, () => AlertSuccessModel());
    alertDeniedModel = createModel(context, () => AlertDeniedModel());
    loadingBlackModel1 = createModel(context, () => LoadingBlackModel());
    loadingBlackModel2 = createModel(context, () => LoadingBlackModel());
  }

  @override
  void dispose() {
    instantTimer?.cancel();
    alertWaitingModel.dispose();
    alertSuccessModel.dispose();
    alertDeniedModel.dispose();
    loadingBlackModel1.dispose();
    loadingBlackModel2.dispose();
  }
}
