import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/certification.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../services/certification_service.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/neon_text_field.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_config.dart';

class CreateCertificationScreen extends StatefulWidget {
  const CreateCertificationScreen({super.key});

  @override
  State<CreateCertificationScreen> createState() =>
      _CreateCertificationScreenState();
}

// Route guard to ensure authentication
class CreateCertificationScreenRoute extends StatefulWidget {
  final Widget child;

  const CreateCertificationScreenRoute({super.key, required this.child});

  @override
  State<CreateCertificationScreenRoute> createState() =>
      _CreateCertificationScreenRouteState();
}

class _CreateCertificationScreenRouteState
    extends State<CreateCertificationScreenRoute> {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Force authentication check on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final authProvider = context.read<AuthProvider>();

    setState(() {
      _isChecking = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Rimuovi il controllo di autenticazione - vai direttamente al child
    return widget.child;
  }
}

class _CreateCertificationScreenState extends State<CreateCertificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  final _detailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _resultController = TextEditingController();

  String _selectedType = 'Standard';
  List<String> _media = [];
  String? _location;
  List<String> _attachments = [];
  List<String> _users = [];
  bool _isLoading = false;
  bool _isOffline = false;

  final CertificationService _certificationService = CertificationService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // Rimuovi refresh autenticazione - non necessaria
  }

  // Rimossi metodi di autenticazione - non più necessari

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _detailController.dispose();
    _descriptionController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = await _certificationService.getCurrentLocation();
      if (location != null) {
        setState(() {
          _location =
              '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _captureMedia(String type) async {
    try {
      final media = await _certificationService.captureMedia(type);
      if (media != null) {
        setState(() {
          _media.add(media.toString());
        });
      }
    } catch (e) {
      print('Error capturing media: $e');
    }
  }

  Future<void> _addAttachment() async {
    try {
      // Per ora, simuliamo l'aggiunta di un allegato
      final attachment =
          'attachment_${DateTime.now().millisecondsSinceEpoch}.txt';

      setState(() {
        _attachments.add(attachment);
      });
    } catch (e) {
      print('Error adding attachment: $e');
    }
  }

  Future<void> _addUser() async {
    // Per ora, aggiungiamo un utente temporaneo
    // In produzione, dovresti implementare un form per inserire i dati utente
    final user = 'Utente Temporaneo (temp@example.com)';

    setState(() {
      _users.add(user);
    });
  }

  Future<void> _createCertification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();

      // Usa dati utente mock per permettere la creazione senza autenticazione
      final currentUser = AppUser(
        idUser:
            '550e8400-e29b-41d4-a716-446655440002', // UUID valido per utente temporaneo
        firstName: 'Utente',
        lastName: 'Temporaneo',
        email: 'temp@example.com',
        type: UserType.user,
        idUserHash: 'temp_hash_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Simula controllo permessi per utente temporaneo
      if (!_canCreateCertification(currentUser)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You do not have permission to create certifications. Please contact your administrator.',
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Go to Dashboard',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
          ),
        );
        return;
      }

      // Show progress message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Creating certification...'),
            backgroundColor: Colors.blue,
          ),
        );
      }

      // Crea la certificazione
      final certification = Certification(
        idLegalEntity: currentUser.idUser!,
        idCertificationHash: 'hash_${DateTime.now().millisecondsSinceEpoch}',
        serialNumber: _codeController.text.trim(),
        idCertifier:
            '550e8400-e29b-41d4-a716-446655440000', // UUID valido per certifier temporaneo
        idLocation:
            '550e8400-e29b-41d4-a716-446655440001', // UUID valido per location temporanea
        status: CertificationStatus.draft,
        nUsers: 1,
      );

      // Salva la certificazione
      final result = await _certificationService.createCertification(
        certification,
      );

      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).getString('success')),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, result);
        }
      } else {
        throw Exception('Failed to create certification');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).getString('error')}: $e',
            ),
            backgroundColor: Colors.red,
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

  bool _canCreateCertification(AppUser user) {
    // Permetti sempre la creazione per utenti temporanei o admin
    if (user.type == UserType.admin) return true;

    // Permetti la creazione per utenti temporanei (con UUID specifico)
    if (user.idUser == '550e8400-e29b-41d4-a716-446655440002') return true;

    // Check company role permissions
    // Check if user has permission to create certifications
    return user.type == UserType.admin || user.type == UserType.manager;
  }

  // Rimosso metodo _redirectBasedOnRole - non più necessario

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();

    // Rimuovi controllo di autenticazione - procedi normalmente

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getString('certification_type')),
        backgroundColor: Color(AppConfig.primaryColorValue),
        foregroundColor: Colors.white,
        // Rimossi pulsanti di autenticazione - non necessari
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo certificazione
              _buildSectionHeader(
                l10n.getString('certification_type'),
                Icons.category,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: l10n.getString('certification_type'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['Standard', 'Premium', 'Enterprise'].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Avviso per tipo attività non incluso
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.getString('activity_type_not_found'),
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Informazioni base
              _buildSectionHeader(
                l10n.getString('certification_title'),
                Icons.title,
              ),
              const SizedBox(height: 16),

              NeonTextField(
                controller: _titleController,
                labelText: l10n.getString('certification_title'),
                hintText: 'Inserisci il titolo della certificazione',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Il titolo è obbligatorio';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              NeonTextField(
                controller: _codeController,
                labelText: l10n.getString('certification_code'),
                hintText: 'Inserisci il codice della certificazione',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Il codice è obbligatorio';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              NeonTextField(
                controller: _detailController,
                labelText: l10n.getString('certification_detail'),
                hintText: 'Inserisci i dettagli della certificazione',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'I dettagli sono obbligatori';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Media
              _buildSectionHeader(
                l10n.getString('certification_media'),
                Icons.photo_camera,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: NeonButton(
                      onPressed: () => _captureMedia('camera'),
                      text: l10n.getString('camera'),
                      icon: Icons.camera_alt,
                      neonColor: AppTheme.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeonButton(
                      onPressed: () => _captureMedia('gallery'),
                      text: l10n.getString('gallery'),
                      icon: Icons.photo_library,
                      neonColor: AppTheme.accentBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: NeonButton(
                      onPressed: () => _captureMedia('liveVideo'),
                      text: l10n.getString('live_video'),
                      icon: Icons.videocam,
                      neonColor: AppTheme.accentPurple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeonButton(
                      onPressed: () => _captureMedia('fileAttachment'),
                      text: l10n.getString('file_attachment'),
                      icon: Icons.attach_file,
                      neonColor: AppTheme.accentOrange,
                    ),
                  ),
                ],
              ),

              if (_media.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Media catturati: ${_media.length}'),
                // Qui puoi mostrare una preview dei media
              ],

              const SizedBox(height: 32),

              // Geolocalizzazione
              _buildSectionHeader(
                l10n.getString('geolocation'),
                Icons.location_on,
              ),
              const SizedBox(height: 16),

              if (_location != null) ...[
                Text(
                  'Posizione: ${_location!}',
                  style: TextStyle(color: AppTheme.primaryBlack),
                ),
              ] else ...[
                Text(
                  'Posizione non disponibile',
                  style: TextStyle(color: AppTheme.primaryBlack),
                ),
              ],

              NeonButton(
                onPressed: _getCurrentLocation,
                text: 'Aggiorna Posizione',
                icon: Icons.my_location,
                neonColor: AppTheme.accentGreen,
              ),

              const SizedBox(height: 32),

              // Descrizione
              _buildSectionHeader(
                l10n.getString('certification_description'),
                Icons.description,
              ),
              const SizedBox(height: 16),

              NeonTextField(
                controller: _descriptionController,
                labelText: l10n.getString('certification_description'),
                hintText: 'Inserisci la descrizione della certificazione',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descrizione è obbligatoria';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Allegati
              _buildSectionHeader(
                l10n.getString('certification_attachments'),
                Icons.attach_file,
              ),
              const SizedBox(height: 16),

              NeonButton(
                onPressed: _addAttachment,
                text: 'Aggiungi Allegato',
                icon: Icons.add,
                neonColor: AppTheme.accentBlue,
              ),

              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Allegati: ${_attachments.length}',
                  style: TextStyle(color: AppTheme.primaryBlack),
                ),
                // Qui puoi mostrare la lista degli allegati
              ],

              const SizedBox(height: 32),

              // Utenti
              _buildSectionHeader(
                l10n.getString('certification_users'),
                Icons.people,
              ),
              const SizedBox(height: 16),

              NeonButton(
                onPressed: _addUser,
                text: l10n.getString('add_user'),
                icon: Icons.person_add,
                neonColor: AppTheme.accentPurple,
              ),

              if (_users.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Utenti: ${_users.length}',
                  style: TextStyle(color: AppTheme.primaryBlack),
                ),
                // Qui puoi mostrare la lista degli utenti
              ],

              const SizedBox(height: 32),

              // Esito
              _buildSectionHeader(
                l10n.getString('certification_result'),
                Icons.assessment,
              ),
              const SizedBox(height: 16),

              NeonTextField(
                controller: _resultController,
                labelText: l10n.getString('certification_result'),
                hintText: 'Inserisci l\'esito della certificazione',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'L\'esito è obbligatorio';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Modalità offline
              _buildSectionHeader('Modalità Offline', Icons.offline_bolt),
              const SizedBox(height: 16),

              SwitchListTile(
                title: Text(
                  'Salva offline',
                  style: TextStyle(color: AppTheme.primaryBlack),
                ),
                subtitle: Text(
                  'I dati verranno sincronizzati quando torni online',
                  style: TextStyle(color: AppTheme.primaryBlack),
                ),
                value: _isOffline,
                onChanged: (value) {
                  setState(() {
                    _isOffline = value;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Pulsanti di azione
              Row(
                children: [
                  Expanded(
                    child: NeonButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      text: l10n.getString('cancel'),
                      isOutlined: true,
                      neonColor: AppTheme.accentOrange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NeonButton(
                      onPressed: _isLoading ? null : _createCertification,
                      text: _isLoading
                          ? 'Creazione...'
                          : l10n.getString('save'),
                      isLoading: _isLoading,
                      neonColor: AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlack,
          ),
        ),
      ],
    );
  }
}
