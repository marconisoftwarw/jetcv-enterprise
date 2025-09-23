import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  String? _scannedData;

  @override
  void initState() {
    super.initState();
    // Verifica se la camera è disponibile
    _checkCameraAvailability();
  }

  Future<void> _checkCameraAvailability() async {
    try {
      // Controlla se la camera è disponibile
      // Per mobile_scanner 5.x, non c'è un metodo getCameras()
      // Il controllo viene fatto automaticamente dal controller
      print('🔍 Controllo disponibilità camera...');
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Errore nell\'accesso alla camera: $e');
      }
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _scannedData = barcode.rawValue;
          _isScanning = false;
        });

        // Restituisci i dati scansionati
        Navigator.pop(context, _scannedData);
        break;
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Errore'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Torna alla schermata precedente
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlack,
        foregroundColor: AppTheme.pureWhite,
        title: Text(
          l10n.getString('qr_scan'),
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.pureWhite,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Scanner QR
          MobileScanner(controller: cameraController, onDetect: _onDetect),

          // Overlay con cornice di scansione
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: Center(
              child: Container(
                width: isTablet ? 300 : 250,
                height: isTablet ? 300 : 250,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primaryBlue, width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Angoli della cornice
                    Positioned(
                      top: -3,
                      left: -3,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -3,
                      left: -3,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -3,
                      right: -3,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Istruzioni
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: AppTheme.primaryBlue,
                    size: isTablet ? 40 : 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Posiziona il codice QR\nall\'interno della cornice',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.pureWhite,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pulsante per accendere/spegnere la torcia
          Positioned(
            top: 100,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                onPressed: () {
                  cameraController.toggleTorch();
                },
                icon: Icon(
                  Icons.flash_on,
                  color: AppTheme.pureWhite,
                  size: isTablet ? 28 : 24,
                ),
              ),
            ),
          ),

          // Pulsante per cambiare camera
          Positioned(
            top: 160,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                onPressed: () {
                  cameraController.switchCamera();
                },
                icon: Icon(
                  Icons.cameraswitch,
                  color: AppTheme.pureWhite,
                  size: isTablet ? 28 : 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
