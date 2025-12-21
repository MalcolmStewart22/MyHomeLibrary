import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/google_books_service.dart';
import '../widgets/scan/scan_result_modal.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  MobileScannerController? _controller;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  String? _scannedISBN;
  bool _isSearching = false;
  bool _isModalOpen = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      _checkPermissions();
    } else {
      setState(() {
        _isCheckingPermission = false;
      });
    }
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.camera.request();
      setState(() {
        _hasPermission = status.isGranted;
        _isCheckingPermission = false;
      });

      if (_hasPermission) {
        _controller = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture barcodeCapture) async {
    if (_isSearching || _scannedISBN != null || _isModalOpen) return;

    final barcodes = barcodeCapture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final isbn = barcode.rawValue;

    if (isbn == null || isbn.isEmpty) return;

    _controller?.stop();

    setState(() {
      _isSearching = true;
      _scannedISBN = isbn;
    });

    try {
      final googleBooksService = GoogleBooksService();
      final book = await googleBooksService.getBookByISBN(isbn);

      if (!mounted) return;

      if (book != null) {
        setState(() {
          _isModalOpen = true;
        });

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => ScanResultModal(book: book),
        );

        if (mounted) {
          setState(() {
            _isModalOpen = false;
          });
          _controller?.start();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book not found. Please try scanning again.'),
            duration: Duration(seconds: 3),
          ),
        );
        if (mounted) {
          _controller?.start();
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching for book: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
      _controller?.start();
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _scannedISBN = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Barcode scanning is only available on mobile devices',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please use the Search screen to find books by title or author',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_isCheckingPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Camera permission is required for barcode scanning',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _checkPermissions();
                },
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller!,
            onDetect: _handleBarcode,
          ),
          CustomPaint(
            painter: _ScanOverlayPainter(),
            child: Container(),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_isSearching)
                    const Card(
                      color: Colors.black54,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              'Searching for book...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const Card(
                      color: Colors.black54,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Position the barcode within the frame',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final scannerAreaSize = size.width * 0.7;
    final scannerAreaLeft = (size.width - scannerAreaSize) / 2;
    final scannerAreaTop = (size.height - scannerAreaSize) / 2;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            scannerAreaLeft,
            scannerAreaTop,
            scannerAreaSize,
            scannerAreaSize,
          ),
          const Radius.circular(12),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    final framePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          scannerAreaLeft,
          scannerAreaTop,
          scannerAreaSize,
          scannerAreaSize,
        ),
        const Radius.circular(12),
      ),
      framePaint,
    );

    final cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawLine(
      Offset(scannerAreaLeft, scannerAreaTop),
      Offset(scannerAreaLeft + cornerLength, scannerAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scannerAreaLeft, scannerAreaTop),
      Offset(scannerAreaLeft, scannerAreaTop + cornerLength),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(scannerAreaLeft + scannerAreaSize - cornerLength, scannerAreaTop),
      Offset(scannerAreaLeft + scannerAreaSize, scannerAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scannerAreaLeft + scannerAreaSize, scannerAreaTop),
      Offset(scannerAreaLeft + scannerAreaSize, scannerAreaTop + cornerLength),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(scannerAreaLeft, scannerAreaTop + scannerAreaSize - cornerLength),
      Offset(scannerAreaLeft, scannerAreaTop + scannerAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scannerAreaLeft, scannerAreaTop + scannerAreaSize),
      Offset(scannerAreaLeft + cornerLength, scannerAreaTop + scannerAreaSize),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(scannerAreaLeft + scannerAreaSize - cornerLength, scannerAreaTop + scannerAreaSize),
      Offset(scannerAreaLeft + scannerAreaSize, scannerAreaTop + scannerAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scannerAreaLeft + scannerAreaSize, scannerAreaTop + scannerAreaSize - cornerLength),
      Offset(scannerAreaLeft + scannerAreaSize, scannerAreaTop + scannerAreaSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
