import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../services/veriff_service.dart';
import 'dart:convert'; // Added for jsonEncode and jsonDecode
import 'package:http/http.dart' as http; // Added for http client

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
  
  // Variabili per la WebView Veriff
  bool _showVeriffWebView = false;
  String? _veriffUrl;
  bool _isVeriffLoading = false;
  String? _veriffErrorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_agreeToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the privacy policy'),
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

    print('SignupScreen: Risultato registrazione: $success');

    if (success && mounted) {
      print(
        'SignupScreen: Registrazione riuscita, avviando verifica Veriff...',
      );
      // Avvia il processo di verifica Veriff
      await _startVeriffVerification();
    } else {
      print('SignupScreen: Registrazione fallita o utente non montato');
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      // Per gli utenti Google, avvia anche la verifica Veriff
      await _startVeriffVerification();
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
          title: const Text('Verifica Identità'),
          content: const Text(
            'Per completare la registrazione, è necessario verificare la tua identità. '
            'Vuoi procedere ora con la verifica?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Più Tardi'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Procedi'),
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
        // Se l'utente sceglie di non verificare ora, vai alla home
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('SignupScreen: Errore nell\'avvio verifica Veriff: $e');
      if (mounted) {
        // In caso di errore, vai alla home
        Navigator.pushReplacementNamed(context, '/home');
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

          // Apri la WebView Veriff direttamente nella schermata
          if (mounted) {
            setState(() {
              _veriffUrl = verificationUrl;
              _showVeriffWebView = true;
              _isVeriffLoading = false;
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
      print('SignupScreen: Chiamando endpoint Veriff...');

      final response = await http.post(
        Uri.parse('http://18.102.14.247:4000/session-request-veriff'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('SignupScreen: Risposta HTTP: ${response.statusCode}');
      print('SignupScreen: Corpo risposta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return responseData;
      } else {
        print('SignupScreen: Errore HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('SignupScreen: Errore nella chiamata HTTP: $e');
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Se la WebView Veriff è attiva, mostra solo quella
    if (_showVeriffWebView && _veriffUrl != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Verifica Identità'),
          backgroundColor: Color(AppConfig.primaryColorValue),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _showVeriffWebView = false;
                _veriffUrl = null;
              });
            },
          ),
        ),
        body: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(_veriffUrl!))
            ..setNavigationDelegate(
              NavigationDelegate(
                onNavigationRequest: (NavigationRequest request) {
                  // Gestisci la navigazione se necessario
                  print('Navigazione WebView: ${request.url}');
                  return NavigationDecision.navigate;
                },
                onPageFinished: (String url) {
                  print('Pagina WebView caricata: $url');
                  // Controlla se l'utente è tornato dalla verifica
                  if (url.contains('callback') || url.contains('home')) {
                    // Verifica completata, vai alla home
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
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
                      child: CustomTextField(
                        controller: _firstNameController,
                        labelText: 'First Name',
                        hintText: 'Enter first name',
                        prefixIconData: Icons.person_outline,
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
                      child: CustomTextField(
                        controller: _lastNameController,
                        labelText: 'Last Name',
                        hintText: 'Enter last name',
                        prefixIconData: Icons.person_outline,
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
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIconData: Icons.email_outlined,
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
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone (Optional)',
                  hintText: 'Enter phone number',
                  keyboardType: TextInputType.phone,
                  prefixIconData: Icons.phone_outlined,
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
                      child: CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Enter password',
                        obscureText: _obscurePassword,
                        prefixIconData: Icons.lock_outlined,
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
                      child: CustomTextField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
                        hintText: 'Confirm password',
                        obscureText: _obscureConfirmPassword,
                        prefixIconData: Icons.lock_outlined,
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
                    return CustomButton(
                      onPressed: (authProvider.isLoading || _isVeriffLoading)
                          ? null
                          : _signUp,
                      text: _isVeriffLoading ? 'Verifica in corso...' : 'Create Account',
                      icon: _isVeriffLoading ? Icons.hourglass_empty : Icons.person_add,
                      isLoading: authProvider.isLoading || _isVeriffLoading,
                      fullWidth: true,
                      variant: ButtonVariant.filled,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),

                const SizedBox(height: 24),

                // Google Sign Up Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : _signInWithGoogle,
                      text: 'Sign Up with Google',
                      icon: Icons.g_mobiledata,
                      isLoading: authProvider.isLoading,
                      fullWidth: true,
                      variant: ButtonVariant.outlined,
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
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Sign In'),
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
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: TextStyle(color: Colors.red[600]),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red[600]),
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
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _veriffErrorMessage!,
                              style: TextStyle(color: Colors.red[600]),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red[600]),
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
}
