import '/flutter_flow/flutter_flow_util.dart';
import 'image_profile_widget.dart' show ImageProfileWidget;
import 'package:flutter/material.dart';

class ImageProfileModel extends FlutterFlowModel<ImageProfileWidget> {
  ///  Local state fields for this component.
  /// imageProfile
  FFUploadedFile? imageProfile;

  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadDataGov = false;
  FFUploadedFile uploadedLocalFile_uploadDataGov =
      FFUploadedFile(bytes: Uint8List.fromList([]));

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
