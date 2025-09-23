import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InternationalPhoneField extends StatefulWidget {
  final String? initialCountryCode;
  final String? initialPhoneNumber;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onCountryCodeChanged;
  final ValueChanged<String>? onPhoneNumberChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextEditingController? controller;

  const InternationalPhoneField({
    super.key,
    this.initialCountryCode,
    this.initialPhoneNumber,
    this.label,
    this.hint,
    this.onCountryCodeChanged,
    this.onPhoneNumberChanged,
    this.validator,
    this.enabled = true,
    this.controller,
  });

  @override
  State<InternationalPhoneField> createState() =>
      _InternationalPhoneFieldState();
}

class _InternationalPhoneFieldState extends State<InternationalPhoneField> {
  late TextEditingController _phoneController;
  String _selectedCountryCode = '+39'; // Default to Italy

  // Lista dei prefissi internazionali più comuni
  final List<Map<String, String>> _countryCodes = [
    {'code': '+39', 'country': '🇮🇹 Italia', 'flag': '🇮🇹'},
    {'code': '+1', 'country': '🇺🇸 USA/Canada', 'flag': '🇺🇸'},
    {'code': '+44', 'country': '🇬🇧 Regno Unito', 'flag': '🇬🇧'},
    {'code': '+33', 'country': '🇫🇷 Francia', 'flag': '🇫🇷'},
    {'code': '+49', 'country': '🇩🇪 Germania', 'flag': '🇩🇪'},
    {'code': '+34', 'country': '🇪🇸 Spagna', 'flag': '🇪🇸'},
    {'code': '+41', 'country': '🇨🇭 Svizzera', 'flag': '🇨🇭'},
    {'code': '+43', 'country': '🇦🇹 Austria', 'flag': '🇦🇹'},
    {'code': '+31', 'country': '🇳🇱 Paesi Bassi', 'flag': '🇳🇱'},
    {'code': '+32', 'country': '🇧🇪 Belgio', 'flag': '🇧🇪'},
    {'code': '+351', 'country': '🇵🇹 Portogallo', 'flag': '🇵🇹'},
    {'code': '+30', 'country': '🇬🇷 Grecia', 'flag': '🇬🇷'},
    {'code': '+45', 'country': '🇩🇰 Danimarca', 'flag': '🇩🇰'},
    {'code': '+46', 'country': '🇸🇪 Svezia', 'flag': '🇸🇪'},
    {'code': '+47', 'country': '🇳🇴 Norvegia', 'flag': '🇳🇴'},
    {'code': '+358', 'country': '🇫🇮 Finlandia', 'flag': '🇫🇮'},
    {'code': '+48', 'country': '🇵🇱 Polonia', 'flag': '🇵🇱'},
    {'code': '+420', 'country': '🇨🇿 Repubblica Ceca', 'flag': '🇨🇿'},
    {'code': '+421', 'country': '🇸🇰 Slovacchia', 'flag': '🇸🇰'},
    {'code': '+36', 'country': '🇭🇺 Ungheria', 'flag': '🇭🇺'},
    {'code': '+40', 'country': '🇷🇴 Romania', 'flag': '🇷🇴'},
    {'code': '+359', 'country': '🇧🇬 Bulgaria', 'flag': '🇧🇬'},
    {'code': '+385', 'country': '🇭🇷 Croazia', 'flag': '🇭🇷'},
    {'code': '+386', 'country': '🇸🇮 Slovenia', 'flag': '🇸🇮'},
    {'code': '+372', 'country': '🇪🇪 Estonia', 'flag': '🇪🇪'},
    {'code': '+371', 'country': '🇱🇻 Lettonia', 'flag': '🇱🇻'},
    {'code': '+370', 'country': '🇱🇹 Lituania', 'flag': '🇱🇹'},
    {'code': '+7', 'country': '🇷🇺 Russia', 'flag': '🇷🇺'},
    {'code': '+380', 'country': '🇺🇦 Ucraina', 'flag': '🇺🇦'},
    {'code': '+375', 'country': '🇧🇾 Bielorussia', 'flag': '🇧🇾'},
    {'code': '+90', 'country': '🇹🇷 Turchia', 'flag': '🇹🇷'},
    {'code': '+86', 'country': '🇨🇳 Cina', 'flag': '🇨🇳'},
    {'code': '+81', 'country': '🇯🇵 Giappone', 'flag': '🇯🇵'},
    {'code': '+82', 'country': '🇰🇷 Corea del Sud', 'flag': '🇰🇷'},
    {'code': '+91', 'country': '🇮🇳 India', 'flag': '🇮🇳'},
    {'code': '+61', 'country': '🇦🇺 Australia', 'flag': '🇦🇺'},
    {'code': '+64', 'country': '🇳🇿 Nuova Zelanda', 'flag': '🇳🇿'},
    {'code': '+55', 'country': '🇧🇷 Brasile', 'flag': '🇧🇷'},
    {'code': '+52', 'country': '🇲🇽 Messico', 'flag': '🇲🇽'},
    {'code': '+54', 'country': '🇦🇷 Argentina', 'flag': '🇦🇷'},
    {'code': '+56', 'country': '🇨🇱 Cile', 'flag': '🇨🇱'},
    {'code': '+57', 'country': '🇨🇴 Colombia', 'flag': '🇨🇴'},
    {'code': '+51', 'country': '🇵🇪 Perù', 'flag': '🇵🇪'},
    {'code': '+58', 'country': '🇻🇪 Venezuela', 'flag': '🇻🇪'},
    {'code': '+27', 'country': '🇿🇦 Sudafrica', 'flag': '🇿🇦'},
    {'code': '+20', 'country': '🇪🇬 Egitto', 'flag': '🇪🇬'},
    {'code': '+212', 'country': '🇲🇦 Marocco', 'flag': '🇲🇦'},
    {'code': '+213', 'country': '🇩🇿 Algeria', 'flag': '🇩🇿'},
    {'code': '+216', 'country': '🇹🇳 Tunisia', 'flag': '🇹🇳'},
    {'code': '+218', 'country': '🇱🇾 Libia', 'flag': '🇱🇾'},
    {'code': '+249', 'country': '🇸🇩 Sudan', 'flag': '🇸🇩'},
    {'code': '+251', 'country': '🇪🇹 Etiopia', 'flag': '🇪🇹'},
    {'code': '+254', 'country': '🇰🇪 Kenya', 'flag': '🇰🇪'},
    {'code': '+234', 'country': '🇳🇬 Nigeria', 'flag': '🇳🇬'},
    {'code': '+233', 'country': '🇬🇭 Ghana', 'flag': '🇬🇭'},
    {'code': '+225', 'country': '🇨🇮 Costa d\'Avorio', 'flag': '🇨🇮'},
    {'code': '+221', 'country': '🇸🇳 Senegal', 'flag': '🇸🇳'},
    {'code': '+223', 'country': '🇲🇱 Mali', 'flag': '🇲🇱'},
    {'code': '+226', 'country': '🇧🇫 Burkina Faso', 'flag': '🇧🇫'},
    {'code': '+227', 'country': '🇳🇪 Niger', 'flag': '🇳🇪'},
    {'code': '+228', 'country': '🇹🇬 Togo', 'flag': '🇹🇬'},
    {'code': '+229', 'country': '🇧🇯 Benin', 'flag': '🇧🇯'},
    {'code': '+230', 'country': '🇲🇺 Mauritius', 'flag': '🇲🇺'},
    {'code': '+231', 'country': '🇱🇷 Liberia', 'flag': '🇱🇷'},
    {'code': '+232', 'country': '🇸🇱 Sierra Leone', 'flag': '🇸🇱'},
    {'code': '+235', 'country': '🇹🇩 Ciad', 'flag': '🇹🇩'},
    {
      'code': '+236',
      'country': '🇨🇫 Repubblica Centrafricana',
      'flag': '🇨🇫',
    },
    {'code': '+237', 'country': '🇨🇲 Camerun', 'flag': '🇨🇲'},
    {'code': '+238', 'country': '🇨🇻 Capo Verde', 'flag': '🇨🇻'},
    {'code': '+239', 'country': '🇸🇹 São Tomé e Príncipe', 'flag': '🇸🇹'},
    {'code': '+240', 'country': '🇬🇶 Guinea Equatoriale', 'flag': '🇬🇶'},
    {'code': '+241', 'country': '🇬🇦 Gabon', 'flag': '🇬🇦'},
    {'code': '+242', 'country': '🇨🇬 Repubblica del Congo', 'flag': '🇨🇬'},
    {
      'code': '+243',
      'country': '🇨🇩 Repubblica Democratica del Congo',
      'flag': '🇨🇩',
    },
    {'code': '+244', 'country': '🇦🇴 Angola', 'flag': '🇦🇴'},
    {'code': '+245', 'country': '🇬🇼 Guinea-Bissau', 'flag': '🇬🇼'},
    {
      'code': '+246',
      'country': '🇮🇴 Territorio Britannico dell\'Oceano Indiano',
      'flag': '🇮🇴',
    },
    {'code': '+248', 'country': '🇸🇨 Seychelles', 'flag': '🇸🇨'},
    {'code': '+250', 'country': '🇷🇼 Ruanda', 'flag': '🇷🇼'},
    {'code': '+252', 'country': '🇸🇴 Somalia', 'flag': '🇸🇴'},
    {'code': '+253', 'country': '🇩🇯 Gibuti', 'flag': '🇩🇯'},
    {'code': '+255', 'country': '🇹🇿 Tanzania', 'flag': '🇹🇿'},
    {'code': '+256', 'country': '🇺🇬 Uganda', 'flag': '🇺🇬'},
    {'code': '+257', 'country': '🇧🇮 Burundi', 'flag': '🇧🇮'},
    {'code': '+258', 'country': '🇲🇿 Mozambico', 'flag': '🇲🇿'},
    {'code': '+260', 'country': '🇿🇲 Zambia', 'flag': '🇿🇲'},
    {'code': '+261', 'country': '🇲🇬 Madagascar', 'flag': '🇲🇬'},
    {'code': '+262', 'country': '🇷🇪 Riunione', 'flag': '🇷🇪'},
    {'code': '+263', 'country': '🇿🇼 Zimbabwe', 'flag': '🇿🇼'},
    {'code': '+264', 'country': '🇳🇦 Namibia', 'flag': '🇳🇦'},
    {'code': '+265', 'country': '🇲🇼 Malawi', 'flag': '🇲🇼'},
    {'code': '+266', 'country': '🇱🇸 Lesotho', 'flag': '🇱🇸'},
    {'code': '+267', 'country': '🇧🇼 Botswana', 'flag': '🇧🇼'},
    {'code': '+268', 'country': '🇸🇿 Eswatini', 'flag': '🇸🇿'},
    {'code': '+269', 'country': '🇰🇲 Comore', 'flag': '🇰🇲'},
    {'code': '+290', 'country': '🇸🇭 Sant\'Elena', 'flag': '🇸🇭'},
    {'code': '+291', 'country': '🇪🇷 Eritrea', 'flag': '🇪🇷'},
    {'code': '+297', 'country': '🇦🇼 Aruba', 'flag': '🇦🇼'},
    {'code': '+298', 'country': '🇫🇴 Isole Fær Øer', 'flag': '🇫🇴'},
    {'code': '+299', 'country': '🇬🇱 Groenlandia', 'flag': '🇬🇱'},
  ];

  @override
  void initState() {
    super.initState();
    _phoneController = widget.controller ?? TextEditingController();
    _selectedCountryCode = widget.initialCountryCode ?? '+39';
    _phoneController.text = widget.initialPhoneNumber ?? '';
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _phoneController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            // Dropdown per il prefisso internazionale
            Container(
              width: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCountryCode,
                  isExpanded: true,
                  items: _countryCodes.map((country) {
                    return DropdownMenuItem<String>(
                      value: country['code'],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              country['flag']!,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                country['code']!,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: widget.enabled
                      ? (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCountryCode = newValue;
                            });
                            widget.onCountryCodeChanged?.call(newValue);
                          }
                        }
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Campo per il numero di telefono
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                enabled: widget.enabled,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                decoration: InputDecoration(
                  hintText: widget.hint ?? 'Numero di telefono',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  widget.onPhoneNumberChanged?.call(value);
                },
                validator: widget.validator,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Metodi per ottenere i valori
  String get countryCode => _selectedCountryCode;
  String get phoneNumber => _phoneController.text;
  String get fullPhoneNumber => '$_selectedCountryCode${_phoneController.text}';
}
