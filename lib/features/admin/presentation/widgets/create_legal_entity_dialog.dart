import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/providers/legal_entity_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/constants/app_constants.dart';

class CreateLegalEntityDialog extends ConsumerStatefulWidget {
  const CreateLegalEntityDialog({super.key});

  @override
  ConsumerState<CreateLegalEntityDialog> createState() => _CreateLegalEntityDialogState();
}

class _CreateLegalEntityDialogState extends ConsumerState<CreateLegalEntityDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_business,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Nuovo Ente Legale',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Legal Name
                      FormBuilderTextField(
                        name: 'legalName',
                        decoration: const InputDecoration(
                          labelText: 'Ragione Sociale *',
                          hintText: 'Inserisci la ragione sociale',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Ragione sociale richiesta'),
                        ]),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Identifier Code
                      FormBuilderTextField(
                        name: 'identifierCode',
                        decoration: const InputDecoration(
                          labelText: 'Codice Identificativo *',
                          hintText: 'Es. P.IVA, Codice Fiscale',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Codice identificativo richiesto'),
                        ]),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Legal Representative
                      FormBuilderTextField(
                        name: 'legalRepresentative',
                        decoration: const InputDecoration(
                          labelText: 'Rappresentante Legale *',
                          hintText: 'Nome e cognome del rappresentante',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Rappresentante legale richiesto'),
                        ]),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      FormBuilderTextField(
                        name: 'email',
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          hintText: 'email@azienda.com',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Email richiesta'),
                          FormBuilderValidators.email(errorText: 'Email non valida'),
                        ]),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      FormBuilderTextField(
                        name: 'phone',
                        decoration: const InputDecoration(
                          labelText: 'Telefono *',
                          hintText: '+39 123 456 7890',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Telefono richiesto'),
                        ]),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // PEC
                      FormBuilderTextField(
                        name: 'pec',
                        decoration: const InputDecoration(
                          labelText: 'PEC',
                          hintText: 'pec@azienda.pec.it',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.email(errorText: 'PEC non valida'),
                        ]),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Website
                      FormBuilderTextField(
                        name: 'website',
                        decoration: const InputDecoration(
                          labelText: 'Website',
                          hintText: 'https://www.azienda.com',
                        ),
                        validator: FormBuilderValidators.compose([
                          (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!value.startsWith('http://') && !value.startsWith('https://')) {
                                return 'URL deve iniziare con http:// o https://';
                              }
                            }
                            return null;
                          },
                        ]),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Operational Address
                      FormBuilderTextField(
                        name: 'operationalAddress',
                        decoration: const InputDecoration(
                          labelText: 'Indirizzo Operativo *',
                          hintText: 'Indirizzo completo dell\'attività',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Indirizzo operativo richiesto'),
                        ]),
                        maxLines: 2,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Headquarters Address
                      FormBuilderTextField(
                        name: 'headquartersAddress',
                        decoration: const InputDecoration(
                          labelText: 'Sede Legale *',
                          hintText: 'Indirizzo della sede legale',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Sede legale richiesta'),
                        ]),
                        maxLines: 2,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Additional Address Fields
                      Row(
                        children: [
                          Expanded(
                            child: FormBuilderTextField(
                              name: 'city',
                              decoration: const InputDecoration(
                                labelText: 'Città',
                                hintText: 'Nome della città',
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FormBuilderTextField(
                              name: 'state',
                              decoration: const InputDecoration(
                                labelText: 'Provincia',
                                hintText: 'Sigla provincia',
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: FormBuilderTextField(
                              name: 'postalcode',
                              decoration: const InputDecoration(
                                labelText: 'CAP',
                                hintText: 'Codice postale',
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FormBuilderTextField(
                              name: 'countrycode',
                              decoration: const InputDecoration(
                                labelText: 'Paese',
                                hintText: 'Codice paese (IT)',
                              ),
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Annulla'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleCreate,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Crea Ente'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreate() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final currentUser = ref.read(currentUserProvider);

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore: utente non autenticato'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final legalEntityData = {
          'idLegalEntity': const Uuid().v4(),
          'idLegalEntityHash': const Uuid().v4(), // TODO: Implement proper hashing
          'legalName': formData['legalName'],
          'identifierCode': formData['identifierCode'],
          'operationalAddress': formData['operationalAddress'],
          'headquartersAddress': formData['headquartersAddress'],
          'legalRepresentative': formData['legalRepresentative'],
          'email': formData['email'],
          'phone': formData['phone'],
          'pec': formData['pec']?.isNotEmpty == true ? formData['pec'] : null,
          'website': formData['website']?.isNotEmpty == true ? formData['website'] : null,
          'address': formData['address']?.isNotEmpty == true ? formData['address'] : null,
          'city': formData['city']?.isNotEmpty == true ? formData['city'] : null,
          'state': formData['state']?.isNotEmpty == true ? formData['state'] : null,
          'postalcode': formData['postalcode']?.isNotEmpty == true ? formData['postalcode'] : null,
          'countrycode': formData['countrycode']?.isNotEmpty == true ? formData['countrycode'] : null,
          'requestingIdUser': currentUser.idUser,
          'status': 'pending',
        };

        await ref.read(legalEntityProvider.notifier).createLegalEntity(legalEntityData);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ente legale creato con successo!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore durante la creazione: ${e.toString()}'),
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
}
