import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'alert_waiting_model.dart';
export 'alert_waiting_model.dart';

class AlertWaitingWidget extends StatefulWidget {
  const AlertWaitingWidget({
    super.key,
    required this.message,
    bool? loop,
  }) : this.loop = loop ?? false;

  final String? message;
  final bool loop;

  @override
  State<AlertWaitingWidget> createState() => _AlertWaitingWidgetState();
}

class _AlertWaitingWidgetState extends State<AlertWaitingWidget> {
  late AlertWaitingModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AlertWaitingModel());

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
      width: 380.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (context) {
                if (widget.loop) {
                  return Lottie.asset(
                    'assets/jsons/waiting_clessidra_gray.json',
                    width: 150.0,
                    height: 150.0,
                    fit: BoxFit.contain,
                    animate: true,
                  );
                } else {
                  return Lottie.asset(
                    'assets/jsons/waiting_clessidra_gray.json',
                    width: 150.0,
                    height: 150.0,
                    fit: BoxFit.contain,
                    repeat: false,
                    animate: true,
                  );
                }
              },
            ),
            Text(
              valueOrDefault<String>(
                widget.message,
                '-',
              ),
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
