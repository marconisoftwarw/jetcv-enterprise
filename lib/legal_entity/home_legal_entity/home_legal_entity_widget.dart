import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/alert_denied/alert_denied_widget.dart';
import '/utils/alert_success/alert_success_widget.dart';
import '/utils/alert_waiting/alert_waiting_widget.dart';
import '/utils/loading_black/loading_black_widget.dart';
import '/utils/nav/nav_widget.dart';
import '/actions/actions.dart' as action_blocks;
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_legal_entity_model.dart';
export 'home_legal_entity_model.dart';

class HomeLegalEntityWidget extends StatefulWidget {
  const HomeLegalEntityWidget({super.key});

  static String routeName = 'HomeLegalEntity';
  static String routePath = '/homeLegalEntity';

  @override
  State<HomeLegalEntityWidget> createState() => _HomeLegalEntityWidgetState();
}

class _HomeLegalEntityWidgetState extends State<HomeLegalEntityWidget> {
  late HomeLegalEntityModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeLegalEntityModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.user = await action_blocks.getUserById(
        context,
        idUser: FFAppState().loggedUserId,
      );
      _model.legalEntity = await action_blocks.getLegalEntity(
        context,
        requestingIdUser: _model.user?.idUser,
      );
      if (!(_model.legalEntity?.idLegalEntity != null &&
          _model.legalEntity?.idLegalEntity != '')) {
        if (Navigator.of(context).canPop()) {
          context.pop();
        }
        context.pushNamed(LegalEntityInformationWidget.routeName);

        return;
      }
      _model.isLoading = false;
      safeSetState(() {});
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
        drawer: Drawer(
          elevation: 16.0,
          child: wrapWithModel(
            model: _model.navModel,
            updateCallback: () => safeSetState(() {}),
            child: NavWidget(),
          ),
        ),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 20.0,
                borderWidth: 1.0,
                buttonSize: 40.0,
                icon: Icon(
                  Icons.menu,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 24.0,
                ),
                onPressed: () async {
                  scaffoldKey.currentState!.openDrawer();
                },
              ),
              Text(
                FFLocalizations.of(context).getText(
                  'o1d8dze9' /* Home */,
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
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 24.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      FFLocalizations.of(context).getText(
                                        '4f1mzyhc' /* Ciao, */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .headlineLarge
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .headlineLarge
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .headlineLarge
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .headlineLarge
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .headlineLarge
                                                    .fontStyle,
                                          ),
                                    ),
                                    Text(
                                      valueOrDefault<String>(
                                        _model.user?.firstName,
                                        'Utente',
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .displaySmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .displaySmall
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .displaySmall
                                                    .fontStyle,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  scaffoldKey.currentState!.openDrawer();
                                },
                                child: Container(
                                  width: 64.0,
                                  height: 64.0,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: CachedNetworkImageProvider(
                                        _model.user?.profilePicture != null &&
                                                _model.user?.profilePicture !=
                                                    ''
                                            ? _model.user!.profilePicture
                                            : FFAppConstants
                                                .defaultUserProfileImage,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 4.0,
                                        color: Color(0x33000000),
                                        offset: Offset(
                                          0.0,
                                          2.0,
                                        ),
                                      )
                                    ],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      width: 3.0,
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: FFAppConstants.maxWidth,
                          ),
                          decoration: BoxDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Builder(
                                builder: (context) {
                                  if (_model.legalEntity?.status ==
                                      LegalEntityStatus.pending) {
                                    return wrapWithModel(
                                      model: _model.alertWaitingModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: AlertWaitingWidget(
                                        message:
                                            'Hai completato correttamente la registrazione, ora attendi che l\'accreditamento della tua legal entity venga confermato da parte di ${FFAppConstants.appName}.',
                                      ),
                                    );
                                  } else if (_model.legalEntity?.status ==
                                      LegalEntityStatus.approved) {
                                    return wrapWithModel(
                                      model: _model.alertSuccessModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: AlertSuccessWidget(
                                        message:
                                            'La tua legal entity è stata accreditata con successo.',
                                      ),
                                    );
                                  } else if (_model.legalEntity?.status ==
                                      LegalEntityStatus.rejected) {
                                    return wrapWithModel(
                                      model: _model.alertDeniedModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: AlertDeniedWidget(
                                        message:
                                            'L\'accreditamento della tua legal entity non è stato confermato. Ti preghiamo di contattare ${FFAppConstants.appName} per maggiori informazioni.',
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      decoration: BoxDecoration(),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ]
                          .divide(SizedBox(height: 48.0))
                          .addToStart(SizedBox(height: 16.0))
                          .addToEnd(SizedBox(height: 32.0)),
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
