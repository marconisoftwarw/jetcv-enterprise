import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/neon_text_field.dart';
import '../../widgets/neon_button.dart';
import '../../services/veriff_service.dart';
import '../../services/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import 'dart:async';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;

  // Variabili per la verifica Veriff
  bool _showVeriffWebView = false;
  String? _veriffUrl;
  String? _veriffSessionId;
  bool _isVeriffLoading = false;
  bool _isVeriffWaiting = false;
  bool _isVeriffComplete = false;
  String? _veriffErrorMessage;
  Timer? _windowCheckTimer; // Timer per controllare se la finestra è chiusa
  bool _veriffWindowClosed =
      false; // Flag per tracciare se la finestra è stata chiusa

  // Invitation tracking
  bool _isFromInvitation = false;
  Map<String, String> _invitationParams = {};

  @override
  void initState() {
    super.initState();
    _loadUrlParameters();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _windowCheckTimer?.cancel(); // Cancella il timer del monitoraggio finestra
    super.dispose();
  }

  void _loadUrlParameters() {
    // Controlla se ci sono parametri di invito nell'URL
    final uri = Uri.base;
    final queryParams = uri.queryParameters;

    // Se ci sono parametri di invito (token e email), pre-compila il form
    if (queryParams.containsKey('token') && queryParams.containsKey('email')) {
      _isFromInvitation = true;
      _invitationParams = Map<String, String>.from(queryParams);

      // Pre-compila l'email se presente
      if (queryParams['email'] != null) {
        _emailController.text = queryParams['email']!;
      }

      // Pre-compila il nome se presente nei parametri
      if (queryParams['legal_rapresentative'] != null) {
        final representativeName = queryParams['legal_rapresentative']!;
        final nameParts = representativeName.split(' ');
        if (nameParts.isNotEmpty) {
          _firstNameController.text = nameParts.first;
          if (nameParts.length > 1) {
            _lastNameController.text = nameParts.skip(1).join(' ');
          }
        }
      }
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).getString('must_agree_terms'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_agreeToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).getString('must_agree_privacy'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('SignupScreen: Iniziando processo di registrazione...');

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    // Se l'utente arriva da un invito, salta la verifica Veriff
    if (_isFromInvitation) {
      print('SignupScreen: Utente da invito, saltando verifica Veriff...');
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/legal-entity/invitation-details',
          arguments: _invitationParams,
        );
      }
    } else {
      // Altrimenti, procedi con la verifica Veriff normale
      await _startVeriffVerification();
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      // Se l'utente arriva da un invito, salta la verifica Veriff
      if (_isFromInvitation) {
        print(
          'SignupScreen: Utente Google da invito, saltando verifica Veriff...',
        );
        Navigator.pushReplacementNamed(
          context,
          '/legal-entity/invitation-details',
          arguments: _invitationParams,
        );
      } else {
        // Per gli utenti Google normali, avvia la verifica Veriff
        await _startVeriffVerification();
      }
    }
  }

  Future<void> _startVeriffVerification() async {
    try {
      print('SignupScreen: Avviando processo di verifica Veriff...');

      // Mostra un dialog di conferma per la verifica
      final shouldVerify = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            AppLocalizations.of(
              context,
            ).getString('identity_verification_short'),
          ),
          content: const Text(
            'Per completare la registrazione, è necessario verificare la tua identità. '
            'Vuoi procedere ora con la verifica?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                AppLocalizations.of(context).getString('later_short'),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                AppLocalizations.of(context).getString('proceed_short'),
              ),
            ),
          ],
        ),
      );

      print('SignupScreen: Scelta utente per verifica: $shouldVerify');

      if (shouldVerify == true && mounted) {
        print('SignupScreen: Chiamando API Veriff...');
        // Imposta il loading state
        setState(() {
          _isVeriffLoading = true;
          _veriffErrorMessage = null;
        });
        // Chiama l'API Veriff
        await _callVeriffAPI();
      } else if (mounted) {
        print(
          'SignupScreen: Utente ha scelto di non verificare ora, navigando alla home...',
        );
        // Se l'utente sceglie di non verificare ora, naviga in base all'invito
        if (_isFromInvitation) {
          Navigator.pushReplacementNamed(
            context,
            '/legal-entity/invitation-details',
            arguments: _invitationParams,
          );
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      print('SignupScreen: Errore nell\'avvio verifica Veriff: $e');
      if (mounted) {
        // In caso di errore, naviga in base all'invito
        if (_isFromInvitation) {
          Navigator.pushReplacementNamed(
            context,
            '/legal-entity/invitation-details',
            arguments: _invitationParams,
          );
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    }
  }

  Future<void> _callVeriffAPI() async {
    try {
      print('SignupScreen: Preparando dati per API Veriff...');

      // Prepara i dati per l'API Veriff
      final veriffData = {
        'callback': 'https://skqsuxmdfqxbkhmselaz.supabase.co/home',
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'additionalFields': {
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'gender': 'M', // TODO: Aggiungere campo gender nel form
          'dateOfBirth':
              '1990-01-01', // TODO: Aggiungere campo dateOfBirth nel form
        },
      };

      print('SignupScreen: Dati Veriff: $veriffData');

      // Chiama l'API Veriff
      final response = await _callVeriffSessionAPI(veriffData);

      if (response != null && response['success'] == true) {
        print('SignupScreen: API Veriff chiamata con successo');

        // Estrai l'URL di verifica
        final verificationUrl = response['response']?['verification']?['url'];
        final sessionId = response['sessionId'];

        if (verificationUrl != null) {
          print('SignupScreen: URL verifica: $verificationUrl');

          // Salva i dati della sessione Veriff
          await _saveVeriffSession(sessionId, verificationUrl);

          // Mostra la schermata di verifica Veriff e apri automaticamente il link
          if (mounted) {
            setState(() {
              _veriffUrl = verificationUrl;
              _veriffSessionId = sessionId;
              _showVeriffWebView = true;
              _isVeriffLoading = false;
            });

            // Apri automaticamente il link Veriff dopo un breve delay
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _openVeriffInNewTab();
              }
            });
          }
        } else {
          print('SignupScreen: URL di verifica non trovato nella risposta');
          if (mounted) {
            setState(() {
              _veriffErrorMessage = 'URL di verifica non ricevuto da Veriff';
              _isVeriffLoading = false;
            });
          }
        }
      } else {
        print('SignupScreen: API Veriff fallita');
        if (mounted) {
          setState(() {
            _veriffErrorMessage = 'Errore nella chiamata API Veriff';
            _isVeriffLoading = false;
          });
        }
      }
    } catch (e) {
      print('SignupScreen: Errore nella chiamata API Veriff: $e');
      if (mounted) {
        setState(() {
          _veriffErrorMessage = 'Errore: $e';
          _isVeriffLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _callVeriffSessionAPI(
    Map<String, dynamic> data,
  ) async {
    try {
      print(
        'SignupScreen: Chiamando Supabase Edge Function kyc-create-new-session...',
      );

      final supabaseService = SupabaseService();

      // Chiama la Supabase Edge Function
      final response = await supabaseService.client.functions.invoke(
        'kyc-create-new-session',
        body: data,
      );

      print('SignupScreen: Risposta Edge Function: ${response.status}');
      print('SignupScreen: Corpo risposta: ${response.data}');

      if (response.status == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return responseData;
      } else {
        print('SignupScreen: Errore Edge Function: ${response.status}');
        return null;
      }
    } catch (e) {
      print('SignupScreen: Errore nella chiamata Edge Function: $e');
      return null;
    }
  }

  Future<void> _saveVeriffSession(
    String sessionId,
    String verificationUrl,
  ) async {
    try {
      // TODO: Salvare i dati della sessione Veriff nel database
      print('SignupScreen: Sessione Veriff salvata: $sessionId');
    } catch (e) {
      print('SignupScreen: Errore nel salvataggio sessione Veriff: $e');
    }
  }

  /// Monitora se la finestra del browser Veriff è stata chiusa
  void _startWindowMonitoring() {
    // Cancella eventuali timer precedenti
    _windowCheckTimer?.cancel();

    // Controlla ogni 1 secondo se la finestra è ancora aperta per un massimo di 3 secondi
    _windowCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Dopo 3 secondi, considera il timeout scaduto e vai al login
      if (timer.tick >= 3) {
        timer.cancel();
        if (mounted && !_veriffWindowClosed && !_isVeriffComplete) {
          setState(() {
            _isVeriffWaiting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Timeout verifica - reindirizzamento alla pagina di login...',
              ),
              duration: Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
        }
        return;
      }

      // In Flutter Web, possiamo controllare se ci sono altre finestre aperte
      // usando JavaScript interop
      try {
        // Questa è una semplice implementazione che controlla se siamo ancora nella pagina
        // In un'implementazione più avanzata, potremmo usare window.opener o altre tecniche
        // Rimuoviamo il controllo JavaScript per ora
        final isWindowClosed = false;

        if (isWindowClosed == true && !_veriffWindowClosed) {
          print('SignupScreen: Finestra Veriff chiusa dall\'utente');
          _veriffWindowClosed = true;

          if (mounted) {
            setState(() {
              _isVeriffWaiting = false;
              _veriffWindowClosed = true;
            });

            // Mostra un messaggio e reindirizza alla pagina di login dopo un breve delay
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Verifica annullata - reindirizzamento alla pagina di login...',
                ),
                duration: Duration(seconds: 2),
              ),
            );

            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            });
          }

          timer.cancel();
        }
      } catch (e) {
        print('SignupScreen: Errore nel monitoraggio finestra: $e');
      }
    });
  }

  /// Avvia il monitoraggio automatico dello stato della verifica Veriff
  void _startVeriffStatusMonitoring() {
    if (_veriffSessionId == null) return;

    // Controlla lo stato ogni 3 secondi per un massimo di 1 controllo (3 secondi totali)
    const checkInterval = Duration(seconds: 3);
    const maxChecks = 1; // Solo 1 controllo dopo 3 secondi
    int checkCount = 0;

    Timer.periodic(checkInterval, (timer) async {
      if (!mounted || checkCount >= maxChecks || _veriffWindowClosed) {
        timer.cancel();

        // Dopo il timeout di 3 secondi, reindirizza alla pagina di login
        if (mounted && !_veriffWindowClosed && !_isVeriffComplete) {
          setState(() {
            _isVeriffWaiting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Timeout verifica - reindirizzamento alla pagina di login...',
              ),
              duration: Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
        }
        return;
      }

      checkCount++;
      print('SignupScreen: Controllo stato verifica #$checkCount');

      try {
        final veriffService = VeriffService();
        final statusResponse = await veriffService.checkVeriffSessionStatus(
          sessionId: _veriffSessionId!,
        );

        print('SignupScreen: Stato verifica: ${statusResponse['status']}');

        if (statusResponse['status'] == 'completed' ||
            statusResponse['status'] == 'approved') {
          timer.cancel();

          if (mounted) {
            setState(() {
              _isVeriffWaiting = false;
              _isVeriffComplete = true;
            });

            // Attendi 2 secondi per mostrare il messaggio di successo
            await Future.delayed(const Duration(seconds: 2));

            if (mounted) {
              if (_isFromInvitation) {
                Navigator.pushReplacementNamed(
                  context,
                  '/legal-entity/invitation-details',
                  arguments: _invitationParams,
                );
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            }
          }
        }
      } catch (e) {
        print('SignupScreen: Errore nel controllo stato: $e');
        // In caso di errore, considera completato il timeout e vai al login
        timer.cancel();
        if (mounted && !_veriffWindowClosed) {
          setState(() {
            _isVeriffWaiting = false;
          });

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
        }
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Se la verifica Veriff è attiva, mostra la bellissima schermata di verifica
    if (_showVeriffWebView && _veriffUrl != null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
                Color(0xFFF093FB),
                Color(0xFFF5576C),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Pulsante di chiusura
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      // Cancella il timer del monitoraggio finestra
                      _windowCheckTimer?.cancel();
                      setState(() {
                        _showVeriffWebView = false;
                        _veriffUrl = null;
                        _veriffSessionId = null;
                        _isVeriffWaiting = false;
                        _isVeriffComplete = false;
                        _veriffWindowClosed = false;
                      });
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: const CircleBorder(),
                    ),
                  ),
                ),

                // Contenuto principale
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icona animata
                        AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          curve: Curves.elasticOut,
                          width: (_isVeriffComplete || _veriffWindowClosed)
                              ? 120
                              : 100,
                          height: (_isVeriffComplete || _veriffWindowClosed)
                              ? 120
                              : 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            _veriffWindowClosed
                                ? Icons.cancel
                                : _isVeriffComplete
                                ? Icons.check_circle
                                : _isVeriffWaiting
                                ? Icons.verified_user
                                : Icons.open_in_new,
                            size: (_isVeriffComplete || _veriffWindowClosed)
                                ? 60
                                : 50,
                            color: _veriffWindowClosed
                                ? Colors.red
                                : _isVeriffComplete
                                ? Colors.green
                                : Color(AppConfig.primaryColorValue),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Titolo
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            _veriffWindowClosed
                                ? 'Verifica Annullata'
                                : _isVeriffComplete
                                ? 'Verifica Completata! 🎉'
                                : _isVeriffWaiting
                                ? 'Verifica in Corso...'
                                : 'Pronto per la Verifica',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Descrizione
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 500),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _veriffWindowClosed
                                  ? 'Hai chiuso la finestra di verifica.\nSarai reindirizzato alla pagina di login tra poco.'
                                  : _isVeriffComplete
                                  ? 'La tua identità è stata verificata con successo!\nSarai reindirizzato alla home tra poco.'
                                  : _isVeriffWaiting
                                  ? 'Stiamo monitorando automaticamente lo stato della tua verifica.\nDopo 3 secondi verrai reindirizzato alla pagina di login se non completata.'
                                  : 'La verifica si aprirà automaticamente in una nuova scheda.\nCompleta tutti i passaggi richiesti entro 3 secondi.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Loader elegante o pulsante
                        if (_isVeriffWaiting &&
                            !_isVeriffComplete &&
                            !_veriffWindowClosed)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Monitoraggio verifica...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Controllo dopo 3 secondi',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (!_isVeriffComplete)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.open_in_new,
                                  color: Color(AppConfig.primaryColorValue),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Apertura automatica...',
                                  style: TextStyle(
                                    color: Color(AppConfig.primaryColorValue),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 40),

                        // Pulsanti aggiuntivi
                        if (!_isVeriffWaiting &&
                            !_isVeriffComplete &&
                            !_veriffWindowClosed)
                          Column(
                            children: [
                              TextButton.icon(
                                onPressed: _openVeriffInNewTab,
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Riapri Verifica',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(
                                    0.1,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () => Navigator.pushReplacementNamed(
                                  context,
                                  '/home',
                                ),
                                icon: const Icon(
                                  Icons.home,
                                  color: Colors.white70,
                                ),
                                label: const Text(
                                  'Salta per ora',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          )
                        // Messaggio di reindirizzamento quando la finestra è chiusa
                        else if (_veriffWindowClosed)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Reindirizzamento automatico alla pagina di login...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Messaggio di successo
                        if (_isVeriffComplete)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Verifica completata con successo!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Overlay di sfondo con particelle animate (opzionale)
                if (_isVeriffWaiting)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.5, 0.5),
                            radius: 1.5,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.02),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // Altrimenti mostra il form di signup normale
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color(AppConfig.primaryColorValue),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.person_add,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join our professional certification platform',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Name Fields
                Row(
                  children: [
                    Expanded(
                      child: NeonTextField(
                        controller: _firstNameController,
                        labelText: 'First Name',
                        hintText: 'Enter first name',
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'First name is required';
                          }
                          if (value.length > AppConfig.maxNameLength) {
                            return 'First name too long';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: NeonTextField(
                        controller: _lastNameController,
                        labelText: 'Last Name',
                        hintText: 'Enter last name',
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Last name is required';
                          }
                          if (value.length > AppConfig.maxNameLength) {
                            return 'Last name too long';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Email Field
                NeonTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    if (value.length > AppConfig.maxEmailLength) {
                      return 'Email too long';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Phone Field
                NeonTextField(
                  controller: _phoneController,
                  labelText: 'Phone (Optional)',
                  hintText: 'Enter phone number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        value.length > AppConfig.maxPhoneLength) {
                      return 'Phone number too long';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password Fields
                Row(
                  children: [
                    Expanded(
                      child: NeonTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Enter password',
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < AppConfig.minPasswordLength) {
                            return 'Password must be at least ${AppConfig.minPasswordLength} characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: NeonTextField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
                        hintText: 'Confirm password',
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Terms and Privacy
                Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreeToTerms = !_agreeToTerms;
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                text: 'I accept the ',
                                style: TextStyle(color: Colors.grey[700]),
                                children: [
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                      color: Color(AppConfig.primaryColorValue),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToPrivacy,
                          onChanged: (value) {
                            setState(() {
                              _agreeToPrivacy = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreeToPrivacy = !_agreeToPrivacy;
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                text: 'I accept the ',
                                style: TextStyle(color: Colors.grey[700]),
                                children: [
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: Color(AppConfig.primaryColorValue),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Sign Up Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return NeonButton(
                      onPressed: _signUp,
                      text: _isVeriffLoading
                          ? 'Verifica in corso...'
                          : 'Create Account',
                      icon: _isVeriffLoading
                          ? Icons.hourglass_empty
                          : Icons.person_add,
                      isLoading: authProvider.isLoading || _isVeriffLoading,
                      neonColor: AppTheme.accentGreen,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.primaryBlack)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: AppTheme.primaryBlack,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppTheme.primaryBlack)),
                  ],
                ),

                const SizedBox(height: 24),

                // Google Sign Up Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return NeonButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : _signInWithGoogle,
                      text: 'Sign Up with Google',
                      icon: Icons.g_mobiledata,
                      isLoading: authProvider.isLoading,
                      isOutlined: true,
                      neonColor: AppTheme.accentBlue,
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppTheme.primaryBlack),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: Text(
                        'Sign In',
                        style: TextStyle(color: AppTheme.accentGreen),
                      ),
                    ),
                  ],
                ),

                // Error Message
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.errorMessage != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.accentOrange),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppTheme.accentOrange,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: TextStyle(
                                    color: AppTheme.accentOrange,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: AppTheme.accentOrange,
                                ),
                                onPressed: authProvider.clearError,
                                iconSize: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Veriff Error Message
                if (_veriffErrorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.accentOrange),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppTheme.accentOrange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _veriffErrorMessage!,
                              style: TextStyle(color: AppTheme.primaryBlack),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: AppTheme.accentOrange,
                            ),
                            onPressed: () {
                              setState(() {
                                _veriffErrorMessage = null;
                              });
                            },
                            iconSize: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openVeriffInNewTab() async {
    if (_veriffUrl != null) {
      try {
        final uri = Uri.parse(_veriffUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);

          // Avvia il monitoraggio automatico dello stato e della finestra
          if (mounted) {
            setState(() {
              _isVeriffWaiting = true;
              _veriffWindowClosed = false;
            });
            _startVeriffStatusMonitoring();
            _startWindowMonitoring();
          }
        } else {
          throw Exception('Impossibile aprire l\'URL di verifica');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore nell\'apertura della verifica: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
