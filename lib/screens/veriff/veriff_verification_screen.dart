import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/app_theme.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../services/veriff_service.dart';
import '../../widgets/linkedin_card.dart';
import '../../widgets/linkedin_button.dart';

class VeriffVerificationScreen extends StatefulWidget {
  const VeriffVerificationScreen({super.key});

  @override
  State<VeriffVerificationScreen> createState() =>
      _VeriffVerificationScreenState();
}

class _VeriffVerificationScreenState extends State<VeriffVerificationScreen> {
  String? _webViewController;
  bool _isLoading = true;
  bool _isVerificationComplete = false;
  String? _veriffUrl;
  String? _sessionId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVeriffSession();
  }

  Future<void> _initializeVeriffSession() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Aspetta un momento per permettere all'AuthProvider di aggiornarsi
      await Future.delayed(const Duration(milliseconds: 1000));

      final user = context.read<AuthProvider>().currentUser;

      // Verifica che l'utente sia valido
      if (user == null) {
        throw Exception(
          'Utente non autenticato. Effettua il login per continuare.',
        );
      }

      // URL di callback per ricevere i risultati - punta alla home del progetto
      final callbackUrl = '${AppConfig.appUrl}/home';

      // Richiedi sessione Veriff
      final veriffService = VeriffService();
      final response = await veriffService.requestVeriffSession(
        user: user,
        callbackUrl: callbackUrl,
      );

      print('Veriff Session Response: $response');

      // Estrai l'URL di verifica e l'ID della sessione dalla nuova struttura
      if (response['success'] == true) {
        // Nuova struttura response
        _veriffUrl = response['verificationUrl'] as String?;
        _sessionId = response['sessionId'] as String?;

        // Se non c'è verificationUrl, prova con la struttura nested
        if (_veriffUrl == null &&
            response['response']?['verification']?['url'] != null) {
          _veriffUrl = response['response']['verification']['url'] as String;
        }

        // Se non c'è sessionId, prova con la struttura nested
        if (_sessionId == null &&
            response['response']?['verification']?['id'] != null) {
          _sessionId = response['response']['verification']['id'] as String;
        }
      }

      if (_veriffUrl != null) {
        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('URL di verifica non ricevuto da Veriff');
      }
    } catch (e) {
      print('Error initializing Veriff session: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Errore durante l\'inizializzazione della verifica: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verifica Identità',
          style: AppTheme.title1.copyWith(color: AppTheme.white),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          if (_sessionId != null)
            IconButton(
              onPressed: _checkVerificationStatus,
              icon: const Icon(Icons.refresh),
              tooltip: 'Controlla stato verifica',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Inizializzazione verifica in corso...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_isVerificationComplete) {
      return _buildCompletionView();
    }

    if (_veriffUrl != null) {
      return _buildVerificationView();
    }

    return const Center(child: Text('Stato sconosciuto'));
  }

  Widget _buildErrorView() {
    return Center(
      child: LinkedInCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
            const SizedBox(height: 16),
            Text(
              'Errore durante la verifica',
              style: AppTheme.title1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTheme.body1.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                LinkedInButton(
                  onPressed: _initializeVeriffSession,
                  text: 'Riprova',
                  icon: Icons.refresh,
                  variant: LinkedInButtonVariant.primary,
                ),
                LinkedInButton(
                  onPressed: () => Navigator.pop(context),
                  text: 'Indietro',
                  icon: Icons.arrow_back,
                  variant: LinkedInButtonVariant.outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationView() {
    return Column(
      children: [
        // Header informativo
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.lightBlue,
          child: Row(
            children: [
              Icon(Icons.verified_user, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verifica la tua identità',
                      style: AppTheme.title2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Completa il processo di verifica per accedere alle funzionalità complete',
                      style: AppTheme.body2.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // WebView per Veriff
        Expanded(child: WebViewWidget(controller: _createWebViewController())),

        // Footer con pulsanti
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border(top: BorderSide(color: AppTheme.borderGrey)),
          ),
          child: Row(
            children: [
              Expanded(
                child: LinkedInButton(
                  onPressed: _checkVerificationStatus,
                  text: 'Controlla Stato',
                  icon: Icons.refresh,
                  variant: LinkedInButtonVariant.outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinkedInButton(
                  onPressed: () => Navigator.pop(context),
                  text: 'Completa Più Tardi',
                  icon: Icons.schedule,
                  variant: LinkedInButtonVariant.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionView() {
    return Center(
      child: LinkedInCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, size: 64, color: AppTheme.successGreen),
            const SizedBox(height: 16),
            Text(
              'Verifica Completata!',
              style: AppTheme.title1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'La tua identità è stata verificata con successo. Ora puoi accedere a tutte le funzionalità dell\'app.',
              style: AppTheme.body1.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LinkedInButton(
              onPressed: () => Navigator.pop(context),
              text: 'Continua',
              icon: Icons.check,
              variant: LinkedInButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleVerificationCallback(String url) async {
    print('Handling verification callback: $url');

    // Se è un callback dalla WebView (contiene 'home' o 'callback')
    if (url.contains('home') || url.contains('callback')) {
      // Mostra un messaggio di successo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Verifica completata! Reindirizzamento...'),
          backgroundColor: AppTheme.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );

      // Reindirizza alla home dopo un breve delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/home');
      });
      return;
    }

    try {
      if (_sessionId != null) {
        // Controlla lo stato della verifica
        final veriffService = VeriffService();
        final statusResponse = await veriffService.checkVeriffSessionStatus(
          sessionId: _sessionId!,
        );

        print('Verification status: $statusResponse');

        // Se la verifica è completata, ottieni i risultati
        if (statusResponse['status'] == 'completed' ||
            statusResponse['status'] == 'approved') {
          final results = await veriffService.getVeriffSessionResults(
            sessionId: _sessionId!,
          );

          print('Verification results: $results');

          // Aggiorna lo stato dell'utente nel database
          await _updateUserVerificationStatus(results);

          setState(() {
            _isVerificationComplete = true;
          });
        }
      }
    } catch (e) {
      print('Error handling verification callback: $e');
      setState(() {
        _errorMessage = 'Errore durante la verifica: $e';
      });
    }
  }

  WebViewController _createWebViewController() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('WebView loading: $progress%');
          },
          onPageStarted: (String url) {
            print('WebView started loading: $url');
          },
          onPageFinished: (String url) {
            print('WebView finished loading: $url');
            // Controlla se siamo tornati alla home del progetto
            if (url.contains('callback') || url.contains('home')) {
              _handleVerificationCallback(url);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            print('WebView navigation request: ${request.url}');
            // Permetti tutte le navigazioni
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
          },
        ),
      );

    // Carica l'URL di Veriff
    if (_veriffUrl != null) {
      controller.loadRequest(Uri.parse(_veriffUrl!));
    }

    return controller;
  }

  Future<void> _checkVerificationStatus() async {
    if (_sessionId == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final veriffService = VeriffService();
      final statusResponse = await veriffService.checkVeriffSessionStatus(
        sessionId: _sessionId!,
      );

      print('Manual status check: $statusResponse');

      if (statusResponse['status'] == 'completed' ||
          statusResponse['status'] == 'approved') {
        final results = await veriffService.getVeriffSessionResults(
          sessionId: _sessionId!,
        );

        await _updateUserVerificationStatus(results);

        setState(() {
          _isVerificationComplete = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stato verifica: ${statusResponse['status']}'),
            backgroundColor: AppTheme.primaryBlue,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Errore durante il controllo dello stato: $e';
      });
    }
  }

  Future<void> _updateUserVerificationStatus(
    Map<String, dynamic> results,
  ) async {
    try {
      // TODO: Aggiorna lo stato di verifica dell'utente nel database
      // Questo dovrebbe essere implementato nel SupabaseService
      print('Updating user verification status with results: $results');

      // Per ora, aggiorniamo solo lo stato locale
      // In futuro, questo dovrebbe aggiornare il database
    } catch (e) {
      print('Error updating user verification status: $e');
      rethrow;
    }
  }
}
