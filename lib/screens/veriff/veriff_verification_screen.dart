import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
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
  // Removed webview controller - using url_launcher instead
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
              style: TextStyle(fontSize: 16, color: AppTheme.primaryBlack),
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
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Contenuto principale per la verifica
        Expanded(
          child: Center(
            child: LinkedInCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 64,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Pronto per la verifica?',
                      style: AppTheme.title1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Clicca il pulsante qui sotto per aprire la verifica Veriff in una nuova scheda del browser.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.primaryBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    LinkedInButton(
                      onPressed: _openVeriffInNewTab,
                      text: 'Apri Verifica',
                      icon: Icons.open_in_new,
                      variant: LinkedInButtonVariant.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Dopo aver completato la verifica, torna all\'app e clicca "Controlla Stato"',
                      style:
                          TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryBlack,
                          ).copyWith(
                            color: AppTheme.primaryBlack,
                            fontStyle: FontStyle.italic,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

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
              style: TextStyle(fontSize: 16, color: AppTheme.primaryBlack),
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

    // Se è un callback dalla verifica esterna (contiene 'home' o 'callback')
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
        setState(() {
          _isVerificationComplete = true;
          _isLoading = true;
        });
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

  Future<void> _openVeriffInNewTab() async {
    if (_veriffUrl != null) {
      try {
        final uri = Uri.parse(_veriffUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Impossibile aprire l\'URL di verifica');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore nell\'apertura della verifica: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
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
      setState(() {
        _isVerificationComplete = true;
        _isLoading = true;
      });
      if (statusResponse['status'] == 'completed' ||
          statusResponse['status'] == 'approved') {
        final results = await veriffService.getVeriffSessionResults(
          sessionId: _sessionId!,
        );

        await _updateUserVerificationStatus(results);

        setState(() {
          _isVerificationComplete = true;
          _isLoading = true;
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
