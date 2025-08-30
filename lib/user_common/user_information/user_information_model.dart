import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/utils/image_profile/image_profile_widget.dart';
import '/utils/loading_black/loading_black_widget.dart';
import '/utils/nav/nav_widget.dart';
import '/index.dart';
import 'user_information_widget.dart' show UserInformationWidget;
import 'package:flutter/material.dart';

class UserInformationModel extends FlutterFlowModel<UserInformationWidget> {
  ///  Local state fields for this page.

  DateTime? birthDate;

  bool isLoading = true;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Stores action output result for [Action Block - GetCountries] action in UserInformation widget.
  List<CountryStruct>? country;
  // Stores action output result for [Action Block - GetUserById] action in UserInformation widget.
  UserStruct? user;
  // Model for Nav component.
  late NavModel navModel;
  // Model for ImageProfile component.
  late ImageProfileModel imageProfileModel;
  // State field(s) for FirstName widget.
  FocusNode? firstNameFocusNode;
  TextEditingController? firstNameTextController;
  String? Function(BuildContext, String?)? firstNameTextControllerValidator;
  String? _firstNameTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'ahcj87ji' /* Inserisci il Nome */,
      );
    }

    return null;
  }

  // State field(s) for LastName widget.
  FocusNode? lastNameFocusNode;
  TextEditingController? lastNameTextController;
  String? Function(BuildContext, String?)? lastNameTextControllerValidator;
  String? _lastNameTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'cscgb7s5' /* Inserisci il Cognome */,
      );
    }

    return null;
  }

  // State field(s) for Email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  String? _emailTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'bx1rtakj' /* Inserisci l'email */,
      );
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return FFLocalizations.of(context).getText(
        '63jn76gu' /* Inserisci un'email valida */,
      );
    }
    return null;
  }

  // State field(s) for Phone widget.
  FocusNode? phoneFocusNode;
  TextEditingController? phoneTextController;
  String? Function(BuildContext, String?)? phoneTextControllerValidator;
  String? _phoneTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        '3rgxlcph' /* Inserisci il Cellulare */,
      );
    }

    return null;
  }

  DateTime? datePicked;
  // State field(s) for Gender widget.
  UserGender? genderValue;
  FormFieldController<UserGender>? genderValueController;
  // State field(s) for Address widget.
  FocusNode? addressFocusNode;
  TextEditingController? addressTextController;
  String? Function(BuildContext, String?)? addressTextControllerValidator;
  String? _addressTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'whf3vewn' /* Inserisci l'Indirizzo */,
      );
    }

    return null;
  }

  // State field(s) for City widget.
  FocusNode? cityFocusNode;
  TextEditingController? cityTextController;
  String? Function(BuildContext, String?)? cityTextControllerValidator;
  String? _cityTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        's4u6kbwp' /* Inserisci la Città */,
      );
    }

    return null;
  }

  // State field(s) for PostalCode widget.
  FocusNode? postalCodeFocusNode;
  TextEditingController? postalCodeTextController;
  String? Function(BuildContext, String?)? postalCodeTextControllerValidator;
  String? _postalCodeTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        '5jjuocij' /* Inserisci il CAP */,
      );
    }

    return null;
  }

  // State field(s) for State widget.
  FocusNode? stateFocusNode;
  TextEditingController? stateTextController;
  String? Function(BuildContext, String?)? stateTextControllerValidator;
  String? _stateTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        '546pm9jh' /* Inserisci la Provincia */,
      );
    }

    return null;
  }

  // State field(s) for CountryCode widget.
  String? countryCodeValue;
  FormFieldController<String>? countryCodeValueController;
  // Stores action output result for [Backend Call - API (updateUserProfile)] action in Button widget.
  ApiCallResponse? apiResultUpdateUserProfile;
  // Stores action output result for [Backend Call - API (syncimagefromjectcventerprise)] action in Button widget.
  ApiCallResponse? apiResulty9i;
  // Model for LoadingBlack component.
  late LoadingBlackModel loadingBlackModel;

  @override
  void initState(BuildContext context) {
    navModel = createModel(context, () => NavModel());
    imageProfileModel = createModel(context, () => ImageProfileModel());
    firstNameTextControllerValidator = _firstNameTextControllerValidator;
    lastNameTextControllerValidator = _lastNameTextControllerValidator;
    emailTextControllerValidator = _emailTextControllerValidator;
    phoneTextControllerValidator = _phoneTextControllerValidator;
    addressTextControllerValidator = _addressTextControllerValidator;
    cityTextControllerValidator = _cityTextControllerValidator;
    postalCodeTextControllerValidator = _postalCodeTextControllerValidator;
    stateTextControllerValidator = _stateTextControllerValidator;
    loadingBlackModel = createModel(context, () => LoadingBlackModel());
  }

  @override
  void dispose() {
    navModel.dispose();
    imageProfileModel.dispose();
    firstNameFocusNode?.dispose();
    firstNameTextController?.dispose();

    lastNameFocusNode?.dispose();
    lastNameTextController?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();

    phoneFocusNode?.dispose();
    phoneTextController?.dispose();

    addressFocusNode?.dispose();
    addressTextController?.dispose();

    cityFocusNode?.dispose();
    cityTextController?.dispose();

    postalCodeFocusNode?.dispose();
    postalCodeTextController?.dispose();

    stateFocusNode?.dispose();
    stateTextController?.dispose();

    loadingBlackModel.dispose();
  }
}
