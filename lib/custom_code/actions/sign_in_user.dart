// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Automatic imports FlutterFlow might add:
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'dart:html' as html; // only works on web

// You need to add these dependencies in pubspec.yaml in FlutterFlow
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart' show OAuthProvider;

/// Initiates Google OAuth sign-in using Supabase.
///
/// - On web: lets Supabase use the configured Site URL (pass null to
/// redirectTo). - On mobile: uses the enterprise deep link
/// 'jetcv-enterprise://jetcv-enterprise.com'. - Keep this function signature
/// exactly as requested.
Future signInUser() async {
  const webRedirect = 'https://jet-cv-enterprise.flutterflow.app/routing';
  const mobileRedirect = 'jetcv-enterprise://jetcv-enterprise.com';
  const supabaseHost = 'https://ammryjdbnqedwlguhqpv.supabase.co';

  if (kIsWeb) {
    // Manual authorize URL with explicit redirect_to
    final authorizeUrl = '$supabaseHost/auth/v1/authorize'
        '?provider=google'
        '&redirect_to=${Uri.encodeComponent(webRedirect)}';
    html.window.location.href = authorizeUrl;
  } else {
    // Mobile: normal SDK sign-in with deep link
    final supabase = Supabase.instance.client;
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: mobileRedirect,
    );
  }
}
