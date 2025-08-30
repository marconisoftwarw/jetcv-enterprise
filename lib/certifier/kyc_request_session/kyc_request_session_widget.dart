import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/loading_black/loading_black_widget.dart';
import 'dart:async';
import '/actions/actions.dart' as action_blocks;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'kyc_request_session_model.dart';
export 'kyc_request_session_model.dart';

class KycRequestSessionWidget extends StatefulWidget {
  const KycRequestSessionWidget({super.key});

  static String routeName = 'KycRequestSession';
  static String routePath = '/kycRequestSession';

  @override
  State<KycRequestSessionWidget> createState() =>
      _KycRequestSessionWidgetState();
}

class _KycRequestSessionWidgetState extends State<KycRequestSessionWidget> {
  late KycRequestSessionModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => KycRequestSessionModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.user = await action_blocks.getUserById(
        context,
        idUser: FFAppState().loggedUserId,
      );
      if (_model.user != null) {
        _model.apiResultSessionRequestVeriff =
            await SupabaseGroup.sessionRequestVeriffNewCall.call(
          dateOfBirth: dateTimeFormat(
            "yyyy-MM-dd",
            _model.user?.dateOfBirth,
            locale: FFLocalizations.of(context).languageCode,
          ),
          firstName: _model.user?.firstName,
          lastName: _model.user?.lastName,
          email: _model.user?.email,
          phoneNumber: _model.user?.phone,
        );

        if ((_model.apiResultSessionRequestVeriff?.succeeded ?? true) &&
            SupabaseGroup.sessionRequestVeriffNewCall.success(
              (_model.apiResultSessionRequestVeriff?.jsonBody ?? ''),
            )!) {
          _model.isLoading = false;
          safeSetState(() {});
          return;
        } else {
          unawaited(
            () async {
              await action_blocks.snackbar(
                context,
                type: ActionResult.error,
                message:
                    'Errore durante la creazione della sessione di verifica dell\'identità',
              );
            }(),
          );
          unawaited(
            () async {
              await action_blocks.apiFailure(
                context,
                tag: 'apiResultSessionRequestVeriff',
                jsonBody:
                    (_model.apiResultSessionRequestVeriff?.jsonBody ?? ''),
              );
            }(),
          );
          return;
        }
      } else {
        return;
      }
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 20.0,
                    borderWidth: 1.0,
                    buttonSize: 40.0,
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      context.safePop();
                    },
                  ),
                ],
              ),
              Text(
                FFLocalizations.of(context).getText(
                  'urvzold5' /* Verifica dell'identità */,
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
              Container(
                decoration: BoxDecoration(),
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
                  alignment: AlignmentDirectional(0.0, -1.0),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: FFAppConstants.maxWidth,
                    ),
                    decoration: BoxDecoration(),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  FFLocalizations.of(context).getText(
                                    'ddtlipkj' /* Verifica dell'identità */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .headlineLarge
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineLarge
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineLarge
                                            .fontStyle,
                                      ),
                                ),
                                Text(
                                  'Per poter proseguire su ${FFAppConstants.appName} è necessario verificare l\'identità tramite un documento di riconoscimento e video-selfie.',
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
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ].divide(SizedBox(height: 6.0)),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    FFButtonWidget(
                                      onPressed: () async {
                                        var _shouldSetState = false;
                                        _model.apiResultCreateKycAttempt =
                                            await SupabaseGroup
                                                .createKycAttemptCall
                                                .call(
                                          idUser: _model.user?.idUser,
                                          success: SupabaseGroup
                                              .sessionRequestVeriffNewCall
                                              .success(
                                                (_model.apiResultSessionRequestVeriff
                                                        ?.jsonBody ??
                                                    ''),
                                              )
                                              ?.toString(),
                                          message: SupabaseGroup
                                              .sessionRequestVeriffNewCall
                                              .message(
                                            (_model.apiResultSessionRequestVeriff
                                                    ?.jsonBody ??
                                                ''),
                                          ),
                                          receivedParams: SupabaseGroup
                                              .sessionRequestVeriffNewCall
                                              .receivedParams(
                                                (_model.apiResultSessionRequestVeriff
                                                        ?.jsonBody ??
                                                    ''),
                                              )
                                              .toString(),
                                          responseVerificationUrl: SupabaseGroup
                                              .sessionRequestVeriffNewCall
                                              .responseVerificationUrl(
                                            (_model.apiResultSessionRequestVeriff
                                                    ?.jsonBody ??
                                                ''),
                                          ),
                                          sessionId: SupabaseGroup
                                              .sessionRequestVeriffNewCall
                                              .sessionId(
                                            (_model.apiResultSessionRequestVeriff
                                                    ?.jsonBody ??
                                                ''),
                                          ),
                                          responseStatus: SupabaseGroup
                                              .sessionRequestVeriffNewCall
                                              .responseStatus(
                                            (_model.apiResultSessionRequestVeriff
                                                    ?.jsonBody ??
                                                ''),
                                          ),
                                          responseVerificationSessionToken:
                                              SupabaseGroup
                                                  .sessionRequestVeriffNewCall
                                                  .responseVerificationSessionToken(
                                            (_model.apiResultSessionRequestVeriff
                                                    ?.jsonBody ??
                                                ''),
                                          ),
                                        );

                                        _shouldSetState = true;
                                        if ((_model.apiResultCreateKycAttempt
                                                ?.succeeded ??
                                            true)) {
                                          await launchURL(SupabaseGroup
                                              .sessionRequestVeriffNewCall
                                              .responseVerificationUrl(
                                            (_model.apiResultSessionRequestVeriff
                                                    ?.jsonBody ??
                                                ''),
                                          )!);
                                          await Future.delayed(
                                            Duration(
                                              milliseconds: 5000,
                                            ),
                                          );

                                          context.goNamed(
                                              KycSessionResultWidget.routeName);

                                          if (_shouldSetState)
                                            safeSetState(() {});
                                          return;
                                        } else {
                                          unawaited(
                                            () async {
                                              await action_blocks.snackbar(
                                                context,
                                                type: ActionResult.error,
                                                message:
                                                    'Errore durante il salvataggio del tentativo KYC',
                                              );
                                            }(),
                                          );
                                          unawaited(
                                            () async {
                                              await action_blocks.apiFailure(
                                                context,
                                                tag:
                                                    'apiResultCreateKycAttempt',
                                                jsonBody: (_model
                                                        .apiResultCreateKycAttempt
                                                        ?.jsonBody ??
                                                    ''),
                                              );
                                            }(),
                                          );
                                          if (_shouldSetState)
                                            safeSetState(() {});
                                          return;
                                        }

                                        if (_shouldSetState)
                                          safeSetState(() {});
                                      },
                                      text: FFLocalizations.of(context).getText(
                                        '1jl7wx78' /* Verifica ora */,
                                      ),
                                      options: FFButtonOptions(
                                        width: 180.0,
                                        height: 50.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .secondary,
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
                                    Text(
                                      FFLocalizations.of(context).getText(
                                        'ygbmcpae' /* Premendo il pulsante si aprirà... */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ].divide(SizedBox(height: 12.0)),
                                ),
                              ],
                            ),
                          ]
                              .divide(SizedBox(height: 48.0))
                              .addToStart(SizedBox(height: 36.0))
                              .addToEnd(SizedBox(height: 48.0)),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_model.isLoading)
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: wrapWithModel(
                    model: _model.loadingBlackModel,
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
