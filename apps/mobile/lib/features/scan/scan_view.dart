import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
//import 'package:device_preview/device_preview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  String okunanBarkod = "Kameraya bir barkod gösterin!";
  String sonOkunanBarkod = "";

  String urunJson = "Henüz ürün okutulmadı.";
  bool isFetching = false;

  Future<void> fetchProductData(String barcode) async{
    final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    setState(() {
      isFetching = true;
      urunJson = "Yükleniyor..";
    });

    try{
      final response = await http.get(url);

      if(response.statusCode == 200){
        setState(() {
          urunJson = response.body;
          isFetching = false;
        });
        print("Gelen JSON: ${response.body}");
      }
      else{
        setState(() {
          urunJson = "Ürün bulunamadı veya sunucu hatası: ${response.statusCode}";
          isFetching = false;
        });
      }
    } catch (e) {
      setState(() {
        urunJson = "Internet bağlantısı veya API hatası: $e";
        isFetching = false;
      });
    }
  }

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
              controller: MobileScannerController(
                formats: const [
                  BarcodeFormat.ean13,
                  BarcodeFormat.ean8
                ],
              ),
              onDetect: (capture){
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes){
                  if(barcode.rawValue != null){
                    String okunan = barcode.rawValue!;
                    if(okunan != sonOkunanBarkod && !isFetching){
                      setState(() {
                        sonOkunanBarkod = okunan;
                      });
                      fetchProductData(okunan);
                    }
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
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                urunJson,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),

        ]
      ),
    );
  }

}
