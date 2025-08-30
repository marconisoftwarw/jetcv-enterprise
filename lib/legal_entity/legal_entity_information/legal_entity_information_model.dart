import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/utils/image_profile/image_profile_widget.dart';
import '/utils/loading_black/loading_black_widget.dart';
import '/utils/nav/nav_widget.dart';
import '/index.dart';
import 'legal_entity_information_widget.dart' show LegalEntityInformationWidget;
import 'package:flutter/material.dart';

class LegalEntityInformationModel
    extends FlutterFlowModel<LegalEntityInformationWidget> {
  ///  Local state fields for this page.

  DateTime? incorporationDate;

  bool isLoading = true;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Stores action output result for [Action Block - GetLegalEntity] action in LegalEntityInformation widget.
  LegalEntityStruct? legalEntity;
  // Stores action output result for [Action Block - GetCountries] action in LegalEntityInformation widget.
  List<CountryStruct>? countries;
  // Model for Nav component.
  late NavModel navModel;
  // State field(s) for legalName widget.
  FocusNode? legalNameFocusNode;
  TextEditingController? legalNameTextController;
  String? Function(BuildContext, String?)? legalNameTextControllerValidator;
  String? _legalNameTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        '93ktf5qs' /* Inserisci la Ragione Sociale */,
      );
    }

    return null;
  }

  // State field(s) for identifierCode widget.
  FocusNode? identifierCodeFocusNode;
  TextEditingController? identifierCodeTextController;
  String? Function(BuildContext, String?)?
      identifierCodeTextControllerValidator;
  String? _identifierCodeTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'ubmae0sw' /* Inserisci il Codice Identifica... */,
      );
    }

    return null;
  }

  // State field(s) for legalRepresentative widget.
  FocusNode? legalRepresentativeFocusNode;
  TextEditingController? legalRepresentativeTextController;
  String? Function(BuildContext, String?)?
      legalRepresentativeTextControllerValidator;
  String? _legalRepresentativeTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        '77gb6saq' /* Inserisci il Legale Rappresent... */,
      );
    }

    return null;
  }

  // Model for ImageProfile component.
  late ImageProfileModel imageProfileModel1;
  // Model for ImageProfile component.
  late ImageProfileModel imageProfileModel2;
  // State field(s) for headquartersAddress widget.
  FocusNode? headquartersAddressFocusNode;
  TextEditingController? headquartersAddressTextController;
  String? Function(BuildContext, String?)?
      headquartersAddressTextControllerValidator;
  String? _headquartersAddressTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'd5610222' /* Inserisci l'Indirizzo Sede Leg... */,
      );
    }

    return null;
  }

  // State field(s) for headquartersCity widget.
  FocusNode? headquartersCityFocusNode;
  TextEditingController? headquartersCityTextController;
  String? Function(BuildContext, String?)?
      headquartersCityTextControllerValidator;
  // State field(s) for headquartersPostalCode widget.
  FocusNode? headquartersPostalCodeFocusNode;
  TextEditingController? headquartersPostalCodeTextController;
  String? Function(BuildContext, String?)?
      headquartersPostalCodeTextControllerValidator;
  // State field(s) for headquartersState widget.
  FocusNode? headquartersStateFocusNode;
  TextEditingController? headquartersStateTextController;
  String? Function(BuildContext, String?)?
      headquartersStateTextControllerValidator;
  // State field(s) for headquartersCountryCode widget.
  String? headquartersCountryCodeValue;
  FormFieldController<String>? headquartersCountryCodeValueController;
  // State field(s) for operationalAddress widget.
  FocusNode? operationalAddressFocusNode;
  TextEditingController? operationalAddressTextController;
  String? Function(BuildContext, String?)?
      operationalAddressTextControllerValidator;
  // State field(s) for operationalCity widget.
  FocusNode? operationalCityFocusNode;
  TextEditingController? operationalCityTextController;
  String? Function(BuildContext, String?)?
      operationalCityTextControllerValidator;
  // State field(s) for operationalPostalCode widget.
  FocusNode? operationalPostalCodeFocusNode;
  TextEditingController? operationalPostalCodeTextController;
  String? Function(BuildContext, String?)?
      operationalPostalCodeTextControllerValidator;
  // State field(s) for operationalState widget.
  FocusNode? operationalStateFocusNode;
  TextEditingController? operationalStateTextController;
  String? Function(BuildContext, String?)?
      operationalStateTextControllerValidator;
  // State field(s) for operationalCountryCode widget.
  String? operationalCountryCodeValue;
  FormFieldController<String>? operationalCountryCodeValueController;
  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  String? _emailTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'gz9x9t69' /* Inserisci l'email */,
      );
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return FFLocalizations.of(context).getText(
        'cz2ta5re' /* Inserisci un'email valida */,
      );
    }
    return null;
  }

  // State field(s) for pec widget.
  FocusNode? pecFocusNode;
  TextEditingController? pecTextController;
  String? Function(BuildContext, String?)? pecTextControllerValidator;
  // State field(s) for phone widget.
  FocusNode? phoneFocusNode;
  TextEditingController? phoneTextController;
  String? Function(BuildContext, String?)? phoneTextControllerValidator;
  String? _phoneTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'kz7zp6u7' /* Inserisci il Cellulare */,
      );
    }

    return null;
  }

  // State field(s) for website widget.
  FocusNode? websiteFocusNode;
  TextEditingController? websiteTextController;
  String? Function(BuildContext, String?)? websiteTextControllerValidator;
  // State field(s) for linkedinUrl widget.
  FocusNode? linkedinUrlFocusNode;
  TextEditingController? linkedinUrlTextController;
  String? Function(BuildContext, String?)? linkedinUrlTextControllerValidator;
  // Stores action output result for [Backend Call - API (createupdatelegalentity)] action in Button widget.
  ApiCallResponse? updateLegalEntityResult;
  // Model for LoadingBlack component.
  late LoadingBlackModel loadingBlackModel;

  @override
  void initState(BuildContext context) {
    navModel = createModel(context, () => NavModel());
    legalNameTextControllerValidator = _legalNameTextControllerValidator;
    identifierCodeTextControllerValidator =
        _identifierCodeTextControllerValidator;
    legalRepresentativeTextControllerValidator =
        _legalRepresentativeTextControllerValidator;
    imageProfileModel1 = createModel(context, () => ImageProfileModel());
    imageProfileModel2 = createModel(context, () => ImageProfileModel());
    headquartersAddressTextControllerValidator =
        _headquartersAddressTextControllerValidator;
    emailTextControllerValidator = _emailTextControllerValidator;
    phoneTextControllerValidator = _phoneTextControllerValidator;
    loadingBlackModel = createModel(context, () => LoadingBlackModel());
  }

  @override
  void dispose() {
    navModel.dispose();
    legalNameFocusNode?.dispose();
    legalNameTextController?.dispose();

    identifierCodeFocusNode?.dispose();
    identifierCodeTextController?.dispose();

    legalRepresentativeFocusNode?.dispose();
    legalRepresentativeTextController?.dispose();

    imageProfileModel1.dispose();
    imageProfileModel2.dispose();
    headquartersAddressFocusNode?.dispose();
    headquartersAddressTextController?.dispose();

    headquartersCityFocusNode?.dispose();
    headquartersCityTextController?.dispose();

    headquartersPostalCodeFocusNode?.dispose();
    headquartersPostalCodeTextController?.dispose();

    headquartersStateFocusNode?.dispose();
    headquartersStateTextController?.dispose();

    operationalAddressFocusNode?.dispose();
    operationalAddressTextController?.dispose();

    operationalCityFocusNode?.dispose();
    operationalCityTextController?.dispose();

    operationalPostalCodeFocusNode?.dispose();
    operationalPostalCodeTextController?.dispose();

    operationalStateFocusNode?.dispose();
    operationalStateTextController?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();

    pecFocusNode?.dispose();
    pecTextController?.dispose();

    phoneFocusNode?.dispose();
    phoneTextController?.dispose();

    websiteFocusNode?.dispose();
    websiteTextController?.dispose();

    linkedinUrlFocusNode?.dispose();
    linkedinUrlTextController?.dispose();

    loadingBlackModel.dispose();
  }
}
