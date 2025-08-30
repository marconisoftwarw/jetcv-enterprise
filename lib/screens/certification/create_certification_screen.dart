import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/certification.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../services/certification_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_config.dart';

class CreateCertificationScreen extends StatefulWidget {
  const CreateCertificationScreen({super.key});

  @override
  State<CreateCertificationScreen> createState() =>
      _CreateCertificationScreenState();
}

// Route guard to ensure authentication
class CreateCertificationScreenRoute extends StatelessWidget {
  final Widget child;

  const CreateCertificationScreenRoute({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authProvider.isAuthenticated || authProvider.currentUser == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Authentication Required'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Please login to access this feature',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'This screen requires authentication',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return this.child;
      },
    );
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
  bool _isCheckingAuth = false;

  final CertificationService _certificationService = CertificationService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _refreshAuthentication();
  }

  Future<void> _refreshAuthentication() async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.checkAuthenticationStatus();

      // Also refresh user data to ensure we have the latest legal entity info
      if (authProvider.currentUser != null) {
        await authProvider.refreshUserData();
      }
    } catch (e) {
      print('Error refreshing authentication: $e');
    }
  }

  void _handleAuthenticationError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Login',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        ),
      ),
    );
  }

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

      // Check and refresh authentication status
      final isAuthenticated = await authProvider.checkAuthenticationStatus();
      if (!isAuthenticated) {
        String errorMessage = 'User not authenticated. Please login again.';

        // Check for specific error types
        if (authProvider.errorMessage != null) {
          if (authProvider.errorMessage!.contains('session') ||
              authProvider.errorMessage!.contains('expired')) {
            errorMessage = 'Your session has expired. Please login again.';
          } else if (authProvider.errorMessage!.contains('network') ||
              authProvider.errorMessage!.contains('connection')) {
            errorMessage =
                'Network connection issue. Please check your internet connection and try again.';
          }
        }

        _handleAuthenticationError(errorMessage);
        return;
      }

      final currentUser = authProvider.currentUser;
      if (currentUser == null) {
        _handleAuthenticationError(
          'User data not available. Please refresh the app.',
        );
        return;
      }

      // Check if user has permission to create certifications
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
                _redirectBasedOnRole(currentUser);
              },
            ),
          ),
        );
        return;
      }

      // Check if user has a legal entity associated
      if (currentUser.idUser == null || currentUser.idUser.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You need to be associated with a legal entity to create certifications. Please contact your administrator.',
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Go to Dashboard',
              textColor: Colors.white,
              onPressed: () {
                _redirectBasedOnRole(currentUser);
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
        idCertifier: 'temp_certifier',
        idLocation: 'temp_location',
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
    // Admin can do everything
    if (user.type == UserType.admin) return true;

    // Check company role permissions
    // Check if user has permission to create certifications
    return user.type == 'admin' || user.type == 'manager';

    // Check individual permissions
    return user.type == 'admin' || user.type == 'manager';
  }

  void _redirectBasedOnRole(AppUser user) {
    String message = 'Redirecting to your dashboard...';

    if (user.type == 'admin') {
      message = 'Redirecting to admin dashboard...';
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      message = 'Redirecting to home...';
      Navigator.pushReplacementNamed(context, '/home');
    }

    // Show a brief message before redirecting
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();

    // Check if user is authenticated
    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.getString('certification_type')),
          backgroundColor: Color(AppConfig.primaryColorValue),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Authentication Required',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Please login to create certifications',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    text: 'Login',
                    icon: Icons.login,
                    variant: ButtonVariant.filled,
                  ),
                  const SizedBox(width: 16),
                  CustomButton(
                    onPressed: () async {
                      final authProvider = context.read<AuthProvider>();
                      await authProvider.checkAuthenticationStatus();
                    },
                    text: 'Refresh',
                    icon: Icons.refresh,
                    variant: ButtonVariant.outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getString('certification_type')),
        backgroundColor: Color(AppConfig.primaryColorValue),
        foregroundColor: Colors.white,
        actions: [
          if (_isCheckingAuth)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () async {
                    setState(() {
                      _isCheckingAuth = true;
                    });
                    try {
                      final authProvider = context.read<AuthProvider>();
                      await authProvider.refreshUserData();
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isCheckingAuth = false;
                        });
                      }
                    }
                  },
                  tooltip: 'Refresh User Data',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () async {
                    setState(() {
                      _isCheckingAuth = true;
                    });
                    try {
                      final authProvider = context.read<AuthProvider>();
                      await authProvider.checkAuthenticationStatus();
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isCheckingAuth = false;
                        });
                      }
                    }
                  },
                  tooltip: 'Refresh Authentication',
                ),
              ],
            ),
        ],
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

              CustomTextField(
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

              CustomTextField(
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

              CustomTextField(
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
                    child: CustomButton(
                      onPressed: () => _captureMedia('camera'),
                      text: l10n.getString('camera'),
                      icon: Icons.camera_alt,
                      variant: ButtonVariant.filled,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      onPressed: () => _captureMedia('gallery'),
                      text: l10n.getString('gallery'),
                      icon: Icons.photo_library,
                      variant: ButtonVariant.filled,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: () => _captureMedia('liveVideo'),
                      text: l10n.getString('live_video'),
                      icon: Icons.videocam,
                      variant: ButtonVariant.filled,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      onPressed: () => _captureMedia('fileAttachment'),
                      text: l10n.getString('file_attachment'),
                      icon: Icons.attach_file,
                      variant: ButtonVariant.filled,
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
                Text('Posizione: ${_location!}'),
              ] else ...[
                Text('Posizione non disponibile'),
              ],

              CustomButton(
                onPressed: _getCurrentLocation,
                text: 'Aggiorna Posizione',
                icon: Icons.my_location,
                variant: ButtonVariant.filled,
              ),

              const SizedBox(height: 32),

              // Descrizione
              _buildSectionHeader(
                l10n.getString('certification_description'),
                Icons.description,
              ),
              const SizedBox(height: 16),

              CustomTextField(
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

              CustomButton(
                onPressed: _addAttachment,
                text: 'Aggiungi Allegato',
                icon: Icons.add,
                variant: ButtonVariant.filled,
              ),

              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Allegati: ${_attachments.length}'),
                // Qui puoi mostrare la lista degli allegati
              ],

              const SizedBox(height: 32),

              // Utenti
              _buildSectionHeader(
                l10n.getString('certification_users'),
                Icons.people,
              ),
              const SizedBox(height: 16),

              CustomButton(
                onPressed: _addUser,
                text: l10n.getString('add_user'),
                icon: Icons.person_add,
                variant: ButtonVariant.filled,
              ),

              if (_users.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Utenti: ${_users.length}'),
                // Qui puoi mostrare la lista degli utenti
              ],

              const SizedBox(height: 32),

              // Esito
              _buildSectionHeader(
                l10n.getString('certification_result'),
                Icons.assessment,
              ),
              const SizedBox(height: 16),

              CustomTextField(
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
                title: Text('Salva offline'),
                subtitle: Text(
                  'I dati verranno sincronizzati quando torni online',
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
                    child: CustomButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      text: l10n.getString('cancel'),
                      variant: ButtonVariant.outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      onPressed: _isLoading ? null : _createCertification,
                      text: _isLoading
                          ? 'Creazione...'
                          : l10n.getString('save'),
                      isLoading: _isLoading,
                      variant: ButtonVariant.filled,
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
        Icon(icon, color: Color(AppConfig.primaryColorValue)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
