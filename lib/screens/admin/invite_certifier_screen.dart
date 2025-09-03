import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/certifier_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/linkedin_card.dart';
import '../../widgets/linkedin_text_field.dart';
import '../../widgets/linkedin_button.dart';

class InviteCertifierScreen extends StatefulWidget {
  const InviteCertifierScreen({super.key});

  @override
  State<InviteCertifierScreen> createState() => _InviteCertifierScreenState();
}

class _InviteCertifierScreenState extends State<InviteCertifierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController();
  final _messageController = TextEditingController();

  String? _selectedRole;
  bool _isLoading = false;

  final List<String> _predefinedRoles = [
    'Certificatore',
    'Senior Certificatore',
    'Lead Certificatore',
    'Auditor',
    'Ispettore',
    'Consulente',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _roleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_add, color: AppTheme.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Invita Nuovo Certificatore',
                      style: AppTheme.title2.copyWith(color: AppTheme.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: AppTheme.white),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Descrizione
                      LinkedInCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppTheme.infoBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Informazioni', style: AppTheme.title3),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Invita un nuovo certificatore a unirsi al team. '
                                'Riceverà un\'email con un link per accettare l\'invito '
                                'e completare la registrazione.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.primaryBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Form
                      LinkedInCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dettagli Invito', style: AppTheme.title3),
                              const SizedBox(height: 20),

                              // Email
                              LinkedInTextField(
                                controller: _emailController,
                                label: 'Email *',
                                hint: 'email@esempio.com',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icon(Icons.email),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'L\'email è obbligatoria';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Inserisci un\'email valida';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Ruolo
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Ruolo *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.work),
                                ),
                                value: _selectedRole,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Seleziona un ruolo'),
                                  ),
                                  ..._predefinedRoles.map(
                                    (role) => DropdownMenuItem(
                                      value: role,
                                      child: Text(role),
                                    ),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'custom',
                                    child: Text('Altro (specificare)'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRole = value;
                                    if (value != 'custom') {
                                      _roleController.clear();
                                    }
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Il ruolo è obbligatorio';
                                  }
                                  return null;
                                },
                              ),

                              if (_selectedRole == 'custom') ...[
                                const SizedBox(height: 16),
                                LinkedInTextField(
                                  controller: _roleController,
                                  label: 'Ruolo Personalizzato *',
                                  hint: 'Es: Certificatore Specializzato',
                                  prefixIcon: Icon(Icons.edit),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Specifica il ruolo personalizzato';
                                    }
                                    return null;
                                  },
                                ),
                              ],

                              const SizedBox(height: 16),

                              // Messaggio opzionale
                              LinkedInTextField(
                                controller: _messageController,
                                label: 'Messaggio (opzionale)',
                                hint:
                                    'Aggiungi un messaggio personalizzato per l\'invito...',
                                maxLines: 3,
                                prefixIcon: Icon(Icons.message),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Azioni
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Annulla'),
                          ),
                          const SizedBox(width: 12),
                          LinkedInButton(
                            onPressed: _isLoading ? null : _sendInvitation,
                            text: _isLoading
                                ? 'Invio in corso...'
                                : 'Invia Invito',
                            icon: _isLoading ? null : Icons.send,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Salva il ScaffoldMessenger prima dell'operazione asincrona
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final certifierProvider = context.read<CertifierProvider>();

      // TODO: Ottenere legal entity ID dall'utente corrente
      final legalEntityId = 'temp_legal_entity_id';

      final role = _selectedRole == 'custom'
          ? _roleController.text
          : _selectedRole;

      final success = await certifierProvider.inviteCertifier(
        email: _emailController.text.trim(),
        legalEntityId: legalEntityId,
        role: role,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                'Invito inviato con successo a ${_emailController.text.trim()}',
              ),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } else {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                'Errore nell\'invio dell\'invito: ${certifierProvider.errorMessage}',
              ),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Errore nell\'invio dell\'invito: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
