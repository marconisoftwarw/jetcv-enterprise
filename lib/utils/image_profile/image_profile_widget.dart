import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'image_profile_model.dart';
export 'image_profile_model.dart';

class ImageProfileWidget extends StatefulWidget {
  const ImageProfileWidget({
    super.key,
    this.imagepathnew,
  });

  /// imagepathnew
  final String? imagepathnew;

  @override
  State<ImageProfileWidget> createState() => _ImageProfileWidgetState();
}

class _ImageProfileWidgetState extends State<ImageProfileWidget> {
  late ImageProfileModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImageProfileModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        final selectedMedia = await selectMediaWithSourceBottomSheet(
          context: context,
          allowPhoto: true,
        );
        if (selectedMedia != null &&
            selectedMedia
                .every((m) => validateFileFormat(m.storagePath, context))) {
          safeSetState(() => _model.isDataUploading_uploadDataGov = true);
          var selectedUploadedFiles = <FFUploadedFile>[];

          try {
            selectedUploadedFiles = selectedMedia
                .map((m) => FFUploadedFile(
                      name: m.storagePath.split('/').last,
                      bytes: m.bytes,
                      height: m.dimensions?.height,
                      width: m.dimensions?.width,
                      blurHash: m.blurHash,
                    ))
                .toList();
          } finally {
            _model.isDataUploading_uploadDataGov = false;
          }
          if (selectedUploadedFiles.length == selectedMedia.length) {
            safeSetState(() {
              _model.uploadedLocalFile_uploadDataGov =
                  selectedUploadedFiles.first;
            });
          } else {
            safeSetState(() {});
            return;
          }
        }

        _model.imageProfile = _model.uploadedLocalFile_uploadDataGov;
        safeSetState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 120.0,
              height: 120.0,
              child: Stack(
                children: [
                  Material(
                    color: Colors.transparent,
                    elevation: 3.0,
                    shape: const CircleBorder(),
                    child: Container(
                      width: 120.0,
                      height: 120.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          width: 0.0,
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (_model.imageProfile != null &&
                              (_model.imageProfile?.bytes?.isNotEmpty ?? false))
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60.0),
                              child: Image.memory(
                                _model.imageProfile?.bytes ??
                                    Uint8List.fromList([]),
                                width: 120.0,
                                height: 120.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (responsiveVisibility(
                            context: context,
                            phone: false,
                            tablet: false,
                            tabletLandscape: false,
                            desktop: false,
                          ))
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60.0),
                              child: Image.network(
                                'https://ammryjdbnqedwlguhqpv.supabase.co/storage/v1/object/public/main/130937.jpg',
                                width: 120.0,
                                height: 120.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (widget.imagepathnew != null &&
                              widget.imagepathnew != '')
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(60.0),
                                child: CachedNetworkImage(
                                  fadeInDuration: Duration(milliseconds: 0),
                                  fadeOutDuration: Duration(milliseconds: 0),
                                  imageUrl: widget.imagepathnew!,
                                  width: 120.0,
                                  height: 120.0,
                                  fit: BoxFit.cover,
                                  alignment: Alignment(0.0, 0.0),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(1.0, 1.0),
                    child: Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          width: 2.0,
                        ),
                      ),
                      child: FlutterFlowIconButton(
                        borderColor: Colors.transparent,
                        borderRadius: 18.0,
                        buttonSize: 36.0,
                        icon: Icon(
                          Icons.camera_alt,
                          color: FlutterFlowTheme.of(context).info,
                          size: 18.0,
                        ),
                        onPressed: () {
                          print('IconButton pressed ...');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ].divide(SizedBox(height: 12.0)),
        ),
      ),
    );
  }
}
