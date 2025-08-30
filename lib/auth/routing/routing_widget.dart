import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/loading_black/loading_black_widget.dart';
import 'dart:async';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'routing_model.dart';
export 'routing_model.dart';

class RoutingWidget extends StatefulWidget {
  const RoutingWidget({super.key});

  static String routeName = 'Routing';
  static String routePath = '/routing';

  @override
  State<RoutingWidget> createState() => _RoutingWidgetState();
}

class _RoutingWidgetState extends State<RoutingWidget> {
  late RoutingModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RoutingModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (RootPageContext.isInactiveRootPage(context)) {
        return;
      }
      if (FFDevEnvironmentValues().name == DevEnvName.dev.name) {
        FFAppState().loggedUserId = FFDevEnvironmentValues().testUserId;
      }
      if (((FFDevEnvironmentValues().name == DevEnvName.prod.name) &&
              loggedIn) ||
          ((FFDevEnvironmentValues().name == DevEnvName.dev.name) &&
              (FFAppState().loggedUserId != ''))) {
        if (FFDevEnvironmentValues().name == DevEnvName.prod.name) {
          FFAppState().loggedUserId = currentUserUid;
        }
        await actions.printConsole(
          'User ID: ${valueOrDefault<String>(
            FFAppState().loggedUserId,
            'NULL',
          )}',
        );
        _model.user = await action_blocks.getUserById(
          context,
          idUser: FFAppState().loggedUserId,
        );
        if (_model.user?.idUser != null && _model.user?.idUser != '') {
          if (_model.user?.type != null) {
            if (_model.user?.type == UserType.admin) {
              context.goNamed(HomeAdminWidget.routeName);

              return;
            } else if (_model.user?.type == UserType.certifier) {
              context.goNamed(HomeCertifierWidget.routeName);

              return;
            } else if (_model.user?.type == UserType.legal_entity) {
              context.goNamed(HomeLegalEntityWidget.routeName);

              return;
            } else {
              return;
            }
          } else {
            context.goNamed(WelcomeUserWidget.routeName);

            return;
          }
        } else {
          unawaited(
            () async {
              await action_blocks.snackbar(
                context,
                type: ActionResult.error,
                message: 'Utente non esistente',
              );
            }(),
          );
          unawaited(
            () async {
              await action_blocks.apiFailure(
                context,
                tag: 'user',
                jsonBody: _model.user?.toMap(),
              );
            }(),
          );
          return;
        }
      } else {
        context.goNamed(LogoutWidget.routeName);

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
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: wrapWithModel(
              model: _model.loadingBlackModel,
              updateCallback: () => safeSetState(() {}),
              child: LoadingBlackWidget(),
            ),
          ),
        ),
      ),
    );
  }
}
