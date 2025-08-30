import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/loading_black/loading_black_widget.dart';
import 'legal_entities_list_widget.dart' show LegalEntitiesListWidget;
import 'package:flutter/material.dart';

class LegalEntitiesListModel extends FlutterFlowModel<LegalEntitiesListWidget> {
  ///  Local state fields for this component.

  List<LegalEntityStruct> legalEntities = [];
  void addToLegalEntities(LegalEntityStruct item) => legalEntities.add(item);
  void removeFromLegalEntities(LegalEntityStruct item) =>
      legalEntities.remove(item);
  void removeAtIndexFromLegalEntities(int index) =>
      legalEntities.removeAt(index);
  void insertAtIndexInLegalEntities(int index, LegalEntityStruct item) =>
      legalEntities.insert(index, item);
  void updateLegalEntitiesAtIndex(
          int index, Function(LegalEntityStruct) updateFn) =>
      legalEntities[index] = updateFn(legalEntities[index]);

  bool isLoading = true;

  List<UserStruct> usersRequestor = [];
  void addToUsersRequestor(UserStruct item) => usersRequestor.add(item);
  void removeFromUsersRequestor(UserStruct item) => usersRequestor.remove(item);
  void removeAtIndexFromUsersRequestor(int index) =>
      usersRequestor.removeAt(index);
  void insertAtIndexInUsersRequestor(int index, UserStruct item) =>
      usersRequestor.insert(index, item);
  void updateUsersRequestorAtIndex(int index, Function(UserStruct) updateFn) =>
      usersRequestor[index] = updateFn(usersRequestor[index]);

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Action Block - GetLegalEntities] action in LegalEntitiesList widget.
  List<LegalEntityStruct>? legalEntitiesResult;
  // Stores action output result for [Backend Call - API (getUsersByIds)] action in LegalEntitiesList widget.
  ApiCallResponse? apiResultGetUsersByIds;
  // Stores action output result for [Action Block - GetLegalEntities] action in LegalEntityCard widget.
  List<LegalEntityStruct>? legalEntitiesResultUpdate;
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
