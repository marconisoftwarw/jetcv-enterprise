import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/constants/app_constants.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and Title
                const Icon(
                  Icons.person_add_outlined,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                Text(
                  'Crea il tuo account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Registrati per accedere a JetCV Enterprise',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Signup Form
                FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      // First Name
                      FormBuilderTextField(
                        name: 'firstName',
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          prefixIcon: Icon(Icons.person_outlined),
                          hintText: 'Inserisci il tuo nome',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Nome richiesto'),
                          FormBuilderValidators.maxLength(
                            AppConstants.maxNameLength,
                            errorText: 'Nome troppo lungo',
                          ),
                        ]),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      
                      // Last Name
                      FormBuilderTextField(
                        name: 'lastName',
                        decoration: const InputDecoration(
                          labelText: 'Cognome',
                          prefixIcon: Icon(Icons.person_outlined),
                          hintText: 'Inserisci il tuo cognome',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Cognome richiesto'),
                          FormBuilderValidators.maxLength(
                            AppConstants.maxNameLength,
                            errorText: 'Cognome troppo lungo',
                          ),
                        ]),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      
                      // Email
                      FormBuilderTextField(
                        name: 'email',
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: 'Inserisci la tua email',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Email richiesta'),
                          FormBuilderValidators.email(errorText: 'Email non valida'),
                          FormBuilderValidators.maxLength(
                            AppConstants.maxEmailLength,
                            errorText: 'Email troppo lunga',
                          ),
                        ]),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      
                      // Password
                      FormBuilderTextField(
                        name: 'password',
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          hintText: 'Inserisci la tua password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Password richiesta'),
                          FormBuilderValidators.minLength(
                            AppConstants.minPasswordLength,
                            errorText: 'Password troppo corta',
                          ),
                        ]),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      
                      // Confirm Password
                      FormBuilderTextField(
                        name: 'confirmPassword',
                        decoration: InputDecoration(
                          labelText: 'Conferma Password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          hintText: 'Conferma la tua password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Conferma password richiesta'),
                          (value) {
                            final password = _formKey.currentState?.fields['password']?.value;
                            if (value != password) {
                              return 'Le password non coincidono';
                            }
                            return null;
                          },
                        ]),
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),
                      
                      // Signup Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignup,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Registrati'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Google Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleGoogleSignUp,
                          icon: const Icon(Icons.g_mobiledata),
                          label: const Text('Registrati con Google'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hai già un account? ',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('Accedi'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final firstName = formData['firstName'] as String;
      final lastName = formData['lastName'] as String;
      final email = formData['email'] as String;
      final password = formData['password'] as String;

      setState(() => _isLoading = true);

      try {
        await ref.read(authProvider.notifier).signUpWithEmail(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrazione completata! Controlla la tua email per confermare l\'account.'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back to login
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore durante la registrazione: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implement Google Sign Up
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Sign Up non ancora implementato'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante la registrazione con Google: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
