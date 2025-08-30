import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';

Future snackbar(
  BuildContext context, {
  required ActionResult? type,
  required String? message,
}) async {
  if (type == ActionResult.success) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message!,
          style: TextStyle(
            color: FlutterFlowTheme.of(context).info,
          ),
        ),
        duration: Duration(milliseconds: 4000),
        backgroundColor: FlutterFlowTheme.of(context).secondary,
      ),
    );
    return;
  } else if (type == ActionResult.error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message!,
          style: TextStyle(
            color: FlutterFlowTheme.of(context).info,
          ),
        ),
        duration: Duration(milliseconds: 10000),
        backgroundColor: FlutterFlowTheme.of(context).error,
      ),
    );
    return;
  } else {
    return;
  }
}

Future<UserStruct> getUserById(
  BuildContext context, {
  required String? idUser,
}) async {
  ApiCallResponse? apiResultUser;

  apiResultUser = await SupabaseGroup.getUserByIdCall.call(
    idUser: FFAppState().loggedUserId,
  );

  if ((apiResultUser.succeeded ?? true)) {
    return functions.castJsonToDataTypeUser((apiResultUser.jsonBody ?? ''))!;
  }

  unawaited(
    () async {
      await action_blocks.snackbar(
        context,
        type: ActionResult.error,
        message: 'Errore durante il recupero dell\'utente',
      );
    }(),
  );
  unawaited(
    () async {
      await action_blocks.apiFailure(
        context,
        tag: 'apiResultUser',
        jsonBody: (apiResultUser?.jsonBody ?? ''),
      );
    }(),
  );
  // Return a default user or throw an exception
  throw Exception('Failed to get user data');
}

Future apiFailure(
  BuildContext context, {
  required String? tag,
  required dynamic jsonBody,
}) async {
  await actions.printConsole(
    tag,
  );
  await actions.printConsole(
    jsonBody?.toString(),
  );
}

Future<List<CountryStruct>> getCountries(BuildContext context) async {
  ApiCallResponse? apiResultCountries;

  apiResultCountries = await SupabaseGroup.getCountriesCall.call();

  if ((apiResultCountries.succeeded ?? true)) {
    return ((apiResultCountries.jsonBody ?? '')
            .toList()
            .map<CountryStruct?>(CountryStruct.maybeFromMap)
            .toList() as Iterable<CountryStruct?>)
        .withoutNulls;
  }

  unawaited(
    () async {
      await action_blocks.snackbar(
        context,
        type: ActionResult.error,
        message: 'Errore nell\'ottenimento delle Nazioni',
      );
    }(),
  );
  unawaited(
    () async {
      await action_blocks.apiFailure(
        context,
        tag: 'apiResultCountries',
        jsonBody: (apiResultCountries?.jsonBody ?? ''),
      );
    }(),
  );
  return FFAppState().emptyListCountries;
}

Future<LegalEntityStruct> getLegalEntity(
  BuildContext context, {
  int? idLegalEntity,
  String? requestingIdUser,
}) async {
  ApiCallResponse? getLegaLentityByIdLegalEntityResult;
  ApiCallResponse? getLegaLentityByRequestingIdUserResult;

  if (idLegalEntity != null) {
    getLegaLentityByIdLegalEntityResult =
        await SupabaseGroup.getLegalEntityCall.call(
      idLegalEntity: idLegalEntity.toString(),
    );

    if ((getLegaLentityByIdLegalEntityResult.succeeded ?? true)) {
      if (((getLegaLentityByIdLegalEntityResult.jsonBody ?? '') != null) &&
          (SupabaseGroup.getLegalEntityCall.legalEntity(
                (getLegaLentityByIdLegalEntityResult.jsonBody ?? ''),
              ) !=
              null)) {
        return functions.castJsonToDataTypeLegalEntity(
            SupabaseGroup.getLegalEntityCall.legalEntity(
          (getLegaLentityByIdLegalEntityResult.jsonBody ?? ''),
        ))!;
      }
    } else {
      unawaited(
        () async {
          await action_blocks.snackbar(
            context,
            type: ActionResult.error,
            message: 'Errore durante il recupero della legal entity',
          );
        }(),
      );
      unawaited(
        () async {
          await action_blocks.apiFailure(
            context,
            tag: 'getLegaLentityByIdLegalEntityResult',
            jsonBody: (getLegaLentityByIdLegalEntityResult?.jsonBody ?? ''),
          );
        }(),
      );
    }
  } else if (requestingIdUser != null && requestingIdUser != '') {
    getLegaLentityByRequestingIdUserResult =
        await SupabaseGroup.getLegalEntityCall.call(
      requestingIdUser: requestingIdUser,
    );

    if ((getLegaLentityByRequestingIdUserResult.succeeded ?? true)) {
      if ((getLegaLentityByRequestingIdUserResult != null) &&
          (SupabaseGroup.getLegalEntityCall.legalEntity(
                (getLegaLentityByRequestingIdUserResult.jsonBody ?? ''),
              ) !=
              null)) {
        return functions.castJsonToDataTypeLegalEntity(
            SupabaseGroup.getLegalEntityCall.legalEntity(
          (getLegaLentityByRequestingIdUserResult.jsonBody ?? ''),
        ))!;
      }
    } else {
      unawaited(
        () async {
          await action_blocks.snackbar(
            context,
            type: ActionResult.error,
            message: 'Errore durante il recupero della legal entity',
          );
        }(),
      );
      unawaited(
        () async {
          await action_blocks.apiFailure(
            context,
            tag: 'getLegaLentityByRequestingIdUserResult',
            jsonBody: (getLegaLentityByRequestingIdUserResult?.jsonBody ?? ''),
          );
        }(),
      );
    }
  }

  // Return a default legal entity or throw an exception
  throw Exception('Failed to get legal entity data');
}

Future<List<LegalEntityStruct>> getLegalEntities(BuildContext context) async {
  ApiCallResponse? getLegalEntitiesResult;

  getLegalEntitiesResult = await SupabaseGroup.getLegalEntitiesCall.call();

  if ((getLegalEntitiesResult.succeeded ?? true)) {
    return functions
        .castJsonToDataTypeLegalEntityList(SupabaseGroup.getLegalEntitiesCall
            .entities(
              (getLegalEntitiesResult.jsonBody ?? ''),
            )
            ?.toList());
  }

  unawaited(
    () async {
      await action_blocks.snackbar(
        context,
        type: ActionResult.error,
        message: 'Errore durante il recupero delle legal entity',
      );
    }(),
  );
  unawaited(
    () async {
      await action_blocks.apiFailure(
        context,
        tag: 'getLegalEntitiesResult',
        jsonBody: (getLegalEntitiesResult?.jsonBody ?? ''),
      );
    }(),
  );
  return FFAppState().emptyListLegalEntity;
}
