import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  String okunanBarkod = "Kameraya bir barkod gösterin!";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barkod Tarama'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MobileScanner(
              onDetect: (capture){
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes){
                  if(barcode.rawValue != null){
                    setState(() {
                      okunanBarkod = barcode.rawValue!;
                    });
                  }
                }
              },
            ),
          ),

          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Okunan Barkod Değeri: ',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    okunanBarkod,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
            ),
          )

        ]
      ),
    );
  }

}
