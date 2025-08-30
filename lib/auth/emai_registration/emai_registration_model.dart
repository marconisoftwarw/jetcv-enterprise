import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'emai_registration_widget.dart' show EmaiRegistrationWidget;
import 'package:flutter/material.dart';

class EmaiRegistrationModel extends FlutterFlowModel<EmaiRegistrationWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for Email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // State field(s) for Password1 widget.
  FocusNode? password1FocusNode;
  TextEditingController? password1TextController;
  late bool password1Visibility;
  String? Function(BuildContext, String?)? password1TextControllerValidator;
  // State field(s) for Password2 widget.
  FocusNode? password2FocusNode;
  TextEditingController? password2TextController;
  late bool password2Visibility;
  String? Function(BuildContext, String?)? password2TextControllerValidator;
  // State field(s) for Checkbox widget.
  bool? checkboxValue;

  @override
  void initState(BuildContext context) {
    password1Visibility = false;
    password2Visibility = false;
  }

  @override
  void dispose() {
    emailFocusNode?.dispose();
    emailTextController?.dispose();

    password1FocusNode?.dispose();
    password1TextController?.dispose();

    password2FocusNode?.dispose();
    password2TextController?.dispose();
  }
}
