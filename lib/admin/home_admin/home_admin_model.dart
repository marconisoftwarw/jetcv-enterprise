import '/admin/legal_entities_list/legal_entities_list_widget.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/loading_black/loading_black_widget.dart';
import '/utils/nav/nav_widget.dart';
import 'home_admin_widget.dart' show HomeAdminWidget;
import 'package:flutter/material.dart';

class HomeAdminModel extends FlutterFlowModel<HomeAdminWidget> {
  ///  Local state fields for this page.

  bool isLoading = true;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Action Block - GetUserById] action in HomeAdmin widget.
  UserStruct? user;
  // Model for Nav component.
  late NavModel navModel;
  // Model for LegalEntitiesList component.
  late LegalEntitiesListModel legalEntitiesListModel;
  // Model for LoadingBlack component.
  late LoadingBlackModel loadingBlackModel;

  @override
  void initState(BuildContext context) {
    navModel = createModel(context, () => NavModel());
    legalEntitiesListModel =
        createModel(context, () => LegalEntitiesListModel());
    loadingBlackModel = createModel(context, () => LoadingBlackModel());
  }

  @override
  void dispose() {
    navModel.dispose();
    legalEntitiesListModel.dispose();
    loadingBlackModel.dispose();
  }
}
