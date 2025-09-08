import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/certification_db.dart';
import '../../services/certification_db_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/linkedin_button.dart';
import '../../widgets/linkedin_card.dart';
import '../../widgets/linkedin_text_field.dart';
import '../../l10n/app_localizations.dart';

class CertificationMediaManagementScreen extends StatefulWidget {
  final String idCertification;

  const CertificationMediaManagementScreen({
    super.key,
    required this.idCertification,
  });

  @override
  State<CertificationMediaManagementScreen> createState() => _CertificationMediaManagementScreenState();
}

class _CertificationMediaManagementScreenState extends State<CertificationMediaManagementScreen> {
  final CertificationDBService _service = CertificationDBService();
  List<CertificationMediaDB> _medias = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadMedias();
  }

  Future<void> _loadMedias() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final medias = await _service.getCertificationMediasByCertification(widget.idCertification);
      
      setState(() {
        _medias = medias;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addMedia() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCertificationMediaScreen(
          idCertification: widget.idCertification,
        ),
      ),
    );

    if (result == true) {
      _loadMedias();
    }
  }

  Future<void> _editMedia(CertificationMediaDB media) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCertificationMediaScreen(
          idCertification: widget.idCertification,
          media: media,
        ),
      ),
    );

    if (result == true) {
      _loadMedias();
    }
  }

  Future<void> _deleteMedia(CertificationMediaDB media) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).getString('delete')),
        content: Text('Sei sicuro di voler eliminare questo media?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).getString('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).getString('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteCertificationMedia(media.idCertificationMedia);
        _loadMedias();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Media eliminato con successo'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore nell\'eliminazione: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlack,
        elevation: 0,
        title: Text(
          'Gestione Media Certificazione',
          style: TextStyle(
            color: AppTheme.primaryBlack,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.errorRed,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Errore nel caricamento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error,
                        style: TextStyle(color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      LinkedInButton(
                        onPressed: _loadMedias,
                        text: 'Riprova',
                        variant: LinkedInButtonVariant.primary,
                      ),
                    ],
                  ),
                )
              : _medias.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nessun media disponibile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlack,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aggiungi foto e video alla certificazione',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 24),
                          LinkedInButton(
                            onPressed: _addMedia,
                            text: 'Aggiungi Media',
                            icon: Icons.add,
                            variant: LinkedInButtonVariant.primary,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(isTablet ? 24 : 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Media (${_medias.length})',
                                style: TextStyle(
                                  fontSize: isTablet ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlack,
                                ),
                              ),
                              LinkedInButton(
                                onPressed: _addMedia,
                                text: 'Aggiungi Media',
                                icon: Icons.add,
                                variant: LinkedInButtonVariant.primary,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isTablet ? 3 : 2,
                              childAspectRatio: 1.0,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _medias.length,
                            itemBuilder: (context, index) {
                              final media = _medias[index];
                              return _buildMediaCard(media, l10n, isTablet);
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildMediaCard(CertificationMediaDB media, AppLocalizations l10n, bool isTablet) {
    return LinkedInCard(
      child: InkWell(
        onTap: () => _editMedia(media),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _getMediaWidget(media),
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              media.name ?? 'Media senza nome',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlack,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (media.description != null) ...[
              SizedBox(height: isTablet ? 4 : 2),
              Text(
                media.description!,
                style: TextStyle(
                  fontSize: isTablet ? 12 : 10,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: isTablet ? 8 : 4),
            Row(
              children: [
                Icon(
                  _getFileTypeIcon(media.fileType),
                  size: isTablet ? 16 : 14,
                  color: _getFileTypeColor(media.fileType),
                ),
                SizedBox(width: isTablet ? 4 : 2),
                Text(
                  _getFileTypeLabel(media.fileType),
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: _getFileTypeColor(media.fileType),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editMedia(media);
                        break;
                      case 'delete':
                        _deleteMedia(media);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: AppTheme.primaryBlue, size: 16),
                          const SizedBox(width: 8),
                          Text('Modifica'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppTheme.errorRed, size: 16),
                          const SizedBox(width: 8),
                          Text('Elimina'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getMediaWidget(CertificationMediaDB media) {
    switch (media.fileType) {
      case FileType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            'https://via.placeholder.com/200',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.image,
                size: 48,
                color: AppTheme.textSecondary,
              );
            },
          ),
        );
      case FileType.video:
        return Icon(
          Icons.videocam,
          size: 48,
          color: AppTheme.primaryBlue,
        );
      case FileType.document:
        return Icon(
          Icons.description,
          size: 48,
          color: AppTheme.warningOrange,
        );
      case FileType.audio:
        return Icon(
          Icons.audiotrack,
          size: 48,
          color: AppTheme.successGreen,
        );
    }
  }

  IconData _getFileTypeIcon(FileType type) {
    switch (type) {
      case FileType.image:
        return Icons.image;
      case FileType.video:
        return Icons.videocam;
      case FileType.document:
        return Icons.description;
      case FileType.audio:
        return Icons.audiotrack;
    }
  }

  Color _getFileTypeColor(FileType type) {
    switch (type) {
      case FileType.image:
        return AppTheme.primaryBlue;
      case FileType.video:
        return AppTheme.errorRed;
      case FileType.document:
        return AppTheme.warningOrange;
      case FileType.audio:
        return AppTheme.successGreen;
    }
  }

  String _getFileTypeLabel(FileType type) {
    switch (type) {
      case FileType.image:
        return 'Immagine';
      case FileType.video:
        return 'Video';
      case FileType.document:
        return 'Documento';
      case FileType.audio:
        return 'Audio';
    }
  }
}

class AddCertificationMediaScreen extends StatefulWidget {
  final String idCertification;
  final CertificationMediaDB? media;

  const AddCertificationMediaScreen({
    super.key,
    required this.idCertification,
    this.media,
  });

  @override
  State<AddCertificationMediaScreen> createState() => _AddCertificationMediaScreenState();
}

class _AddCertificationMediaScreenState extends State<AddCertificationMediaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedFile;
  FileType _selectedFileType = FileType.image;
  AcquisitionType _selectedAcquisitionType = AcquisitionType.manual;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.media != null) {
      _nameController.text = widget.media!.name ?? '';
      _descriptionController.text = widget.media!.description ?? '';
      _selectedFileType = widget.media!.fileType;
      _selectedAcquisitionType = widget.media!.acquisitionType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveMedia() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null && widget.media == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seleziona un file'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Upload file to storage and get URL
      final mediaUrl = 'https://via.placeholder.com/200';
      
      final media = CertificationMediaDB(
        idCertificationMedia: widget.media?.idCertificationMedia ?? '',
        idMediaHash: 'hash_${DateTime.now().millisecondsSinceEpoch}',
        idCertification: widget.idCertification,
        createdAt: widget.media?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        acquisitionType: _selectedAcquisitionType,
        capturedAt: widget.media?.capturedAt ?? DateTime.now(),
        idLocation: null, // TODO: Get from current location
        fileType: _selectedFileType,
      );

      if (widget.media != null) {
        await CertificationDBService().updateCertificationMedia(media);
      } else {
        await CertificationDBService().createCertificationMedia(media);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.media != null ? 'Media aggiornato' : 'Media aggiunto'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: $e'),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlack,
        elevation: 0,
        title: Text(
          widget.media != null ? 'Modifica Media' : 'Aggiungi Media',
          style: TextStyle(
            color: AppTheme.primaryBlack,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dettagli Media',
                style: TextStyle(
                  fontSize: isTablet ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                'Aggiungi foto, video o documenti alla certificazione',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: isTablet ? 32 : 24),

              // File Selection
              Container(
                width: double.infinity,
                height: isTablet ? 200 : 150,
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.borderGrey,
                    style: BorderStyle.solid,
                  ),
                ),
                child: InkWell(
                  onTap: _pickFile,
                  borderRadius: BorderRadius.circular(12),
                  child: _selectedFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              size: isTablet ? 48 : 40,
                              color: AppTheme.textSecondary,
                            ),
                            SizedBox(height: isTablet ? 12 : 8),
                            Text(
                              'Tocca per selezionare un file',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: isTablet ? 24 : 20),

              LinkedInTextField(
                controller: _nameController,
                label: 'Nome Media (opzionale)',
                hintText: 'Es. Foto del corso',
              ),
              SizedBox(height: isTablet ? 20 : 16),

              LinkedInTextField(
                controller: _descriptionController,
                label: 'Descrizione (opzionale)',
                hintText: 'Descrizione del media',
                maxLines: 3,
              ),
              SizedBox(height: isTablet ? 20 : 16),

              DropdownButtonFormField<FileType>(
                value: _selectedFileType,
                decoration: InputDecoration(
                  labelText: 'Tipo File',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isTablet ? 16 : 12,
                  ),
                ),
                items: FileType.values.map((type) {
                  return DropdownMenuItem<FileType>(
                    value: type,
                    child: Text(_getFileTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFileType = value;
                    });
                  }
                },
              ),
              SizedBox(height: isTablet ? 20 : 16),

              DropdownButtonFormField<AcquisitionType>(
                value: _selectedAcquisitionType,
                decoration: InputDecoration(
                  labelText: 'Tipo Acquisizione',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isTablet ? 16 : 12,
                  ),
                ),
                items: AcquisitionType.values.map((type) {
                  return DropdownMenuItem<AcquisitionType>(
                    value: type,
                    child: Text(_getAcquisitionTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedAcquisitionType = value;
                    });
                  }
                },
              ),
              SizedBox(height: isTablet ? 40 : 32),

              LinkedInButton(
                onPressed: _isLoading ? null : _saveMedia,
                text: _isLoading ? 'Salvataggio...' : 'Salva Media',
                icon: Icons.save,
                variant: LinkedInButtonVariant.primary,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFileTypeLabel(FileType type) {
    switch (type) {
      case FileType.image:
        return 'Immagine';
      case FileType.video:
        return 'Video';
      case FileType.document:
        return 'Documento';
      case FileType.audio:
        return 'Audio';
    }
  }

  String _getAcquisitionTypeLabel(AcquisitionType type) {
    switch (type) {
      case AcquisitionType.manual:
        return 'Manuale';
      case AcquisitionType.automatic:
        return 'Automatica';
      case AcquisitionType.imported:
        return 'Importato';
    }
  }
}
