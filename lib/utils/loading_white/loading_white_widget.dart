import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'loading_white_model.dart';
export 'loading_white_model.dart';

class LoadingWhiteWidget extends StatefulWidget {
  const LoadingWhiteWidget({super.key});

  @override
  State<LoadingWhiteWidget> createState() => _LoadingWhiteWidgetState();
}

class _LoadingWhiteWidgetState extends State<LoadingWhiteWidget> {
  late LoadingWhiteModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadingWhiteModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/jsons/loading_circle_white.json',
      width: 400.0,
      height: 400.0,
      fit: BoxFit.contain,
      animate: true,
    );
  }
}
