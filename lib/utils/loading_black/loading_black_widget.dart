import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'loading_black_model.dart';
export 'loading_black_model.dart';

class LoadingBlackWidget extends StatefulWidget {
  const LoadingBlackWidget({super.key});

  @override
  State<LoadingBlackWidget> createState() => _LoadingBlackWidgetState();
}

class _LoadingBlackWidgetState extends State<LoadingBlackWidget> {
  late LoadingBlackModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadingBlackModel());

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
      'assets/jsons/loading_circle_black.json',
      width: 400.0,
      height: 400.0,
      fit: BoxFit.contain,
      animate: true,
    );
  }
}
