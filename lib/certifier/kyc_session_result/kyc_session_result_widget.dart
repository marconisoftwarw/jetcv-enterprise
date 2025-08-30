import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import '/utils/alert_denied/alert_denied_widget.dart';
import '/utils/alert_success/alert_success_widget.dart';
import '/utils/alert_waiting/alert_waiting_widget.dart';
import '/utils/loading_black/loading_black_widget.dart';
import 'dart:async';
import '/actions/actions.dart' as action_blocks;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'kyc_session_result_model.dart';
export 'kyc_session_result_model.dart';

class KycSessionResultWidget extends StatefulWidget {
  const KycSessionResultWidget({super.key});

  static String routeName = 'KycSessionResult';
  static String routePath = '/kycSessionResult';

  @override
  State<KycSessionResultWidget> createState() => _KycSessionResultWidgetState();
}

class _KycSessionResultWidgetState extends State<KycSessionResultWidget> {
  late KycSessionResultModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => KycSessionResultModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.apiResultGetLastKycAttempt =
          await SupabaseGroup.getLastKycAttemptCall.call(
        idUser: FFAppState().loggedUserId,
      );

      if (!(_model.apiResultGetLastKycAttempt?.succeeded ?? true)) {
        unawaited(
          () async {
            await action_blocks.snackbar(
              context,
              type: ActionResult.error,
              message: 'Errore durante il recupero del tentativo KYC',
            );
          }(),
        );
        unawaited(
          () async {
            await action_blocks.apiFailure(
              context,
              tag: 'apiResultGetLastKycAttempt',
              jsonBody: (_model.apiResultGetLastKycAttempt?.jsonBody ?? ''),
            );
          }(),
        );
        return;
      }
      _model.instantTimer = InstantTimer.periodic(
        duration: Duration(milliseconds: 10000),
        callback: (timer) async {
          _model.apiResultCheckSessionVeriff =
              await SupabaseGroup.checkSessionVeriffCall.call(
            sessionId: SupabaseGroup.getLastKycAttemptCall.sessionId(
              (_model.apiResultGetLastKycAttempt?.jsonBody ?? ''),
            ),
          );

          if (SupabaseGroup.checkSessionVeriffCall.status(
                (_model.apiResultCheckSessionVeriff?.jsonBody ?? ''),
              ) ==
              400) {
            _model.kycStatus = KycStatus.refused;
          } else if ((SupabaseGroup.checkSessionVeriffCall.status(
                    (_model.apiResultCheckSessionVeriff?.jsonBody ?? ''),
                  ) ==
                  200) &&
              (SupabaseGroup.checkSessionVeriffCall.verification(
                    (_model.apiResultCheckSessionVeriff?.jsonBody ?? ''),
                  ) !=
                  null)) {
            _model.kycStatus = KycStatus.confirmed;
          } else if ((SupabaseGroup.checkSessionVeriffCall.status(
                    (_model.apiResultCheckSessionVeriff?.jsonBody ?? ''),
                  ) ==
                  200) &&
              (SupabaseGroup.checkSessionVeriffCall.verification(
                    (_model.apiResultCheckSessionVeriff?.jsonBody ?? ''),
                  ) ==
                  null)) {
            _model.kycStatus = KycStatus.pending;
          } else {
            _model.kycStatus = KycStatus.pending;
          }

          if ((_model.kycStatus == KycStatus.confirmed) ||
              (_model.kycStatus == KycStatus.refused)) {
            _model.instantTimer?.cancel();
            _model.apiResultUpdateKycVerification =
                await SupabaseGroup.updateKycVerificationCall.call(
              idKycAttempt: SupabaseGroup.getLastKycAttemptCall.idKycAttempt(
                (_model.apiResultGetLastKycAttempt?.jsonBody ?? ''),
              ),
              verificated:
                  _model.kycStatus == KycStatus.confirmed ? true : false,
            );

            if ((_model.apiResultUpdateKycVerification?.succeeded ?? true)) {
              _model.apiResultUpdateUserProfile =
                  await SupabaseGroup.updateUserProfileCall.call(
                idUser: FFAppState().loggedUserId,
                kycCompleted: true,
                kycPassed:
                    _model.kycStatus == KycStatus.confirmed ? true : false,
              );

              if (!(_model.apiResultUpdateUserProfile?.succeeded ?? true)) {
                unawaited(
                  () async {
                    await action_blocks.snackbar(
                      context,
                      type: ActionResult.error,
                      message:
                          'Errore durante l\'aggiornamento informazioni utente',
                    );
                  }(),
                );
                unawaited(
                  () async {
                    await action_blocks.apiFailure(
                      context,
                      tag: 'apiResultUpdateUserProfile',
                      jsonBody:
                          (_model.apiResultUpdateUserProfile?.jsonBody ?? ''),
                    );
                  }(),
                );
                return;
              }
            } else {
              unawaited(
                () async {
                  await action_blocks.snackbar(
                    context,
                    type: ActionResult.error,
                    message:
                        'Errore durante il salvataggio del risultato del KYC',
                  );
                }(),
              );
              unawaited(
                () async {
                  await action_blocks.apiFailure(
                    context,
                    tag: 'apiResultUpdateKycVerification',
                    jsonBody:
                        (_model.apiResultUpdateKycVerification?.jsonBody ?? ''),
                  );
                }(),
              );
              return;
            }
          }
          _model.isLoading = false;
          safeSetState(() {});
        },
        startImmediately: true,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                FFLocalizations.of(context).getText(
                  '7z9ch2y3' /* Esito verifica dell'identità */,
                ),
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .fontWeight,
                        fontStyle: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontSize: 22.0,
                      letterSpacing: 0.0,
                      fontWeight: FlutterFlowTheme.of(context)
                          .headlineMedium
                          .fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                    ),
              ),
            ],
          ),
          actions: [],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              if (!_model.isLoading)
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: FFAppConstants.maxWidth,
                    ),
                    decoration: BoxDecoration(),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Builder(
                            builder: (context) {
                              if (_model.kycStatus == KycStatus.pending) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    wrapWithModel(
                                      model: _model.alertWaitingModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: AlertWaitingWidget(
                                        message: 'Verifica in corso...',
                                        loop: true,
                                      ),
                                    ),
                                    Text(
                                      FFLocalizations.of(context).getText(
                                        'iprpme2s' /* La verifica sta impiegando tro... */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () async {
                                        context.goNamed(
                                            KycRequestSessionWidget.routeName);
                                      },
                                      text: FFLocalizations.of(context).getText(
                                        '51niewbn' /* Nuovo tentativo */,
                                      ),
                                      options: FFButtonOptions(
                                        width: 180.0,
                                        height: 40.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.interTight(
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                        elevation: 0.0,
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 24.0)),
                                );
                              } else if (_model.kycStatus ==
                                  KycStatus.confirmed) {
                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    wrapWithModel(
                                      model: _model.alertSuccessModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: AlertSuccessWidget(
                                        message:
                                            FFLocalizations.of(context).getText(
                                          'shfdi0kl' /* Identità verificata correttame... */,
                                        ),
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () async {
                                        context.goNamed(
                                            HomeCertifierWidget.routeName);
                                      },
                                      text: FFLocalizations.of(context).getText(
                                        '94a7r6kz' /* Continua */,
                                      ),
                                      options: FFButtonOptions(
                                        width: 150.0,
                                        height: 40.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.interTight(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                              color: Colors.white,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 48.0)),
                                );
                              } else if (_model.kycStatus ==
                                  KycStatus.refused) {
                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    wrapWithModel(
                                      model: _model.alertDeniedModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: AlertDeniedWidget(
                                        message:
                                            'Ci dispiace... il provider non è riuscito a confermare la tua identità. Puoi provare ad effettuare un nuovo tentativo.',
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FFButtonWidget(
                                          onPressed: () async {
                                            context.goNamed(
                                                KycRequestSessionWidget
                                                    .routeName);
                                          },
                                          text: FFLocalizations.of(context)
                                              .getText(
                                            'yvcjy5ho' /* Nuovo tentativo */,
                                          ),
                                          options: FFButtonOptions(
                                            width: 180.0,
                                            height: 40.0,
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    16.0, 0.0, 16.0, 0.0),
                                            iconPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            textStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmall
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmall
                                                            .fontStyle,
                                                  ),
                                                  color: Colors.white,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .fontStyle,
                                                ),
                                            elevation: 0.0,
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                          ),
                                        ),
                                        FFButtonWidget(
                                          onPressed: () async {
                                            context.goNamed(
                                                HomeCertifierWidget.routeName);
                                          },
                                          text: FFLocalizations.of(context)
                                              .getText(
                                            '1pytwe8f' /* Vai alla Home */,
                                          ),
                                          options: FFButtonOptions(
                                            width: 180.0,
                                            height: 40.0,
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    16.0, 0.0, 16.0, 0.0),
                                            iconPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            color: FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                            textStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .fontStyle,
                                                ),
                                            elevation: 0.0,
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                          ),
                                        ),
                                      ].divide(SizedBox(height: 24.0)),
                                    ),
                                  ].divide(SizedBox(height: 48.0)),
                                );
                              } else {
                                return wrapWithModel(
                                  model: _model.loadingBlackModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: LoadingBlackWidget(),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_model.isLoading)
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: wrapWithModel(
                    model: _model.loadingBlackModel2,
                    updateCallback: () => safeSetState(() {}),
                    child: LoadingBlackWidget(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
