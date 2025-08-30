import '/admin/legal_entity_card/legal_entity_card_widget.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/loading_black/loading_black_widget.dart';
import 'dart:async';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'legal_entities_list_model.dart';
export 'legal_entities_list_model.dart';

/// create a list of the legal entities registered to the app, displaying
/// their: legalName, identifierCode,
/// operationalAddress,headquartersAddress,legalRepresentative,email,phone,pec,website,createdAt,approved,requestingIdUser.
///
/// in addition, the user can approve or deny the request of the legal entity
/// to be accreditated.
class LegalEntitiesListWidget extends StatefulWidget {
  const LegalEntitiesListWidget({super.key});

  @override
  State<LegalEntitiesListWidget> createState() =>
      _LegalEntitiesListWidgetState();
}

class _LegalEntitiesListWidgetState extends State<LegalEntitiesListWidget> {
  late LegalEntitiesListModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LegalEntitiesListModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.legalEntitiesResult =
          await action_blocks.getLegalEntities(context);
      _model.legalEntities =
          _model.legalEntitiesResult!.toList().cast<LegalEntityStruct>();
      if (_model.legalEntities.isNotEmpty) {
        _model.apiResultGetUsersByIds =
            await SupabaseGroup.getUsersByIdsCall.call(
          idUsersList:
              _model.legalEntities.map((e) => e.requestingIdUser).toList(),
        );

        if ((_model.apiResultGetUsersByIds?.succeeded ?? true)) {
          _model.usersRequestor = functions
              .castJsonToDataTypeUserList(SupabaseGroup.getUsersByIdsCall
                  .users(
                    (_model.apiResultGetUsersByIds?.jsonBody ?? ''),
                  )
                  ?.toList())
              .toList()
              .cast<UserStruct>();
        } else {
          unawaited(
            () async {
              await action_blocks.snackbar(
                context,
                type: ActionResult.error,
                message:
                    'Errore durante il recupero degli utenti richiedenti delle legal entity',
              );
            }(),
          );
          await action_blocks.apiFailure(
            context,
            tag: 'apiResultGetUsersByIds',
            jsonBody: (_model.apiResultGetUsersByIds?.jsonBody ?? ''),
          );
          return;
        }
      }
      _model.isLoading = false;
      safeSetState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                FFLocalizations.of(context).getText(
                  'f2zn4qz8' /* Legal Entities */,
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
          Flexible(
            child: Stack(
              children: [
                if (!_model.isLoading)
                  Container(
                    height: MediaQuery.sizeOf(context).height * 1.0,
                    decoration: BoxDecoration(),
                    child: Builder(
                      builder: (context) {
                        final legalEntity = _model.legalEntities.toList();

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          primary: false,
                          scrollDirection: Axis.vertical,
                          itemCount: legalEntity.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.0),
                          itemBuilder: (context, legalEntityIndex) {
                            final legalEntityItem =
                                legalEntity[legalEntityIndex];
                            return LegalEntityCardWidget(
                              key: Key(
                                  'Keywth_${legalEntityIndex}_of_${legalEntity.length}'),
                              legalEntity: legalEntityItem,
                              userRequestor: _model.usersRequestor
                                  .where((e) =>
                                      e.idUser ==
                                      legalEntityItem.requestingIdUser)
                                  .toList()
                                  .firstOrNull!,
                              callback: () async {
                                _model.legalEntitiesResultUpdate =
                                    await action_blocks
                                        .getLegalEntities(context);
                                _model.legalEntities = _model
                                    .legalEntitiesResultUpdate!
                                    .toList()
                                    .cast<LegalEntityStruct>();
                                safeSetState(() {});

                                safeSetState(() {});
                              },
                            );
                          },
                        );
                      },
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
        ].divide(SizedBox(height: 16.0)),
      ),
    );
  }
}
