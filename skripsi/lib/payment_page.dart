import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:skripsi/MyOrders_page.dart';
import 'package:skripsi/cart_page.dart';
import 'package:skripsi/home_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PaymentPage extends StatefulWidget {
  final int total;
  final String mapLink;

  const PaymentPage({super.key, required this.total, required this.mapLink});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedMethod;
  String? selectedBankOrWallet;
  String? name, phone, address;
  File? proofImage; // Menyimpan gambar bukti transfer yang dipilih

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadCartData();
  }

  Future<void> loadCartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('cart_name');
      phone = prefs.getString('cart_phone');
      address = prefs.getString('cart_address');
    });
  }

  // Fungsi untuk memilih gambar bukti transfer
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(
        source:
            ImageSource.gallery); // Bisa juga menggunakan ImageSource.camera
    if (pickedFile != null) {
      setState(() {
        proofImage = File(pickedFile.path);
      });
    }
  }

  final List<String> paymentMethods = [
    'Transfer Bank',
    'E-Wallet',
  ];

  final List<Map<String, String>> bankOptions = [
    {
      'name': 'BCA', // Nama Bank
      'logo': 'assets/BCA.png', // Gambar logo bank
      'accountNumber': '1234567890', // Nomor Rekening
      'accountName': 'Satria' // Nama Pemilik Rekening
    },
    {
      'name': 'BNI', // Nama Bank
      'logo': 'assets/BNI.png', // Gambar logo bank
      'accountNumber': '0987654321', // Nomor Rekening
      'accountName': 'Budi' // Nama Pemilik Rekening
    },
    {
      'name': 'Mandiri', // Nama Bank
      'logo': 'assets/Mandiri.png', // Gambar logo bank
      'accountNumber': '1122334455', // Nomor Rekening
      'accountName': 'Andi' // Nama Pemilik Rekening
    },
  ];

  final List<Map<String, String>> walletOptions = [
    {
      'name': 'DANA', // Nama Wallet
      'logo': 'assets/DANA.png', // Gambar logo wallet
      'accountNumber': '0876543210', // Nomor Rekening
      'accountName': 'Diana' // Nama Pemilik Rekening
    },
    {
      'name': 'OVO', // Nama Wallet
      'logo': 'assets/OVO.png', // Gambar logo wallet
      'accountNumber': '0987654321', // Nomor Rekening
      'accountName': 'Oka' // Nama Pemilik Rekening
    },
    {
      'name': 'Gopay', // Nama Wallet
      'logo': 'assets/GOPAY.png', // Gambar logo wallet
      'accountNumber': '1122334455', // Nomor Rekening
      'accountName': 'Gopi' // Nama Pemilik Rekening
    },
  ];

  void simulatePayment() async {
    if (name == null ||
        phone == null ||
        address == null ||
        name!.isEmpty ||
        phone!.isEmpty ||
        address!.isEmpty ||
        widget.mapLink.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran Gagal, Data Masih Kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Menghentikan eksekusi jika ada data yang kosong
    }

    if (selectedMethod == null || selectedBankOrWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pilih metode pembayaran terlebih dahulu')),
      );
      return;
    }

    if (proofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Harap unggah bukti transfer terlebih dahulu')),
      );
      return; // Menghentikan eksekusi jika bukti transfer belum diunggah
    }

    if (proofImage != null &&
        !proofImage!.path.endsWith('.jpg') &&
        !proofImage!.path.endsWith('.png')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Hanya file gambar yang diperbolehkan (JPEG/PNG)')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.pop(context);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    String bankOrWalletName = selectedBankOrWallet!;

    // Jika metode pembayaran adalah transfer bank, kita perlu menyaring nama bank
    if (selectedMethod == 'Transfer Bank') {
      final selectedBank = bankOptions.firstWhere(
        (bank) => bank['name'] == bankOrWalletName,
        orElse: () => {'name': 'Unknown Bank'},
      );
      bankOrWalletName = selectedBank['name']!;
    } else if (selectedMethod == 'E-Wallet') {
      final selectedWallet = walletOptions.firstWhere(
        (wallet) => wallet['name'] == bankOrWalletName,
        orElse: () => {'name': 'Unknown Wallet'},
      );
      bankOrWalletName = selectedWallet['name']!;
    }

    // Membuat request body
    var requestBody = {
      "nama": name,
      "no_telp": phone,
      "alamat": address,
      "maps_link": widget.mapLink,
      "qty": widget.total ~/ 12000,
      "total": widget.total,
      "status": "sedang diproses",
      "product": "Galon-Ku",
      "user_id": userId.toString(), // Pastikan user_id dalam bentuk string
    };

    // Membuat request untuk mengirim data ke server
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://192.168.228.82:8000/api/orders')); // Sesuaikan dengan URL API Anda

    // Menambahkan data ke dalam request.fields satu per satu
    request.fields['nama'] = requestBody['nama'] as String;
    request.fields['no_telp'] = requestBody['no_telp'] as String;
    request.fields['alamat'] = requestBody['alamat'] as String;
    request.fields['maps_link'] = requestBody['maps_link'] as String;
    request.fields['qty'] = requestBody['qty'].toString();
    request.fields['total'] = requestBody['total'].toString();
    request.fields['status'] = requestBody['status'] as String;
    request.fields['product'] = requestBody['product'] as String;
    request.fields['user_id'] = requestBody['user_id'] as String;

    if (proofImage != null) {
      // Menambahkan file bukti transfer ke dalam request
      request.files.add(await http.MultipartFile.fromPath(
        'bukti_transfer', // Nama field untuk gambar bukti transfer
        proofImage!.path, // Path file yang diambil dari gallery atau kamera
        contentType: MediaType('image', 'jpeg'), // Format file
      ));
    }

    // Mengirimkan request
    final response = await request.send();
    print('Status Code: ${response.statusCode}');
    response.stream.transform(utf8.decoder).listen((value) {
      print('Response Body: $value');
    });

    if (response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pembayaran Berhasil'),
          content: Text(
              'Metode: $selectedMethod - $bankOrWalletName\nTotal: Rp.${widget.total}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Gagal konek API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan pesanan ke server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Metode Pembayaran'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Metode Pembayaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioListTile<String>(
                      title: const Text('Transfer Bank'),
                      value: 'Transfer Bank',
                      groupValue: selectedMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedMethod = value;
                          selectedBankOrWallet = null;
                        });
                      },
                    ),
                    if (selectedMethod == 'Transfer Bank') ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Column(
                          children: bankOptions.map((bank) {
                            return RadioListTile<String>(
                              value: bank['name']!, // Nama bank
                              groupValue: selectedBankOrWallet,
                              onChanged: (value) {
                                setState(() {
                                  selectedBankOrWallet =
                                      value; // Menyimpan nama bank
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              title: Row(
                                children: [
                                  Image.asset(
                                    bank['logo']!,
                                    width: 60, // Membatasi ukuran gambar
                                    height: 60, // Membatasi ukuran gambar
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(bank[
                                          'accountNumber']!), // Nomor Rekening
                                      Text(bank[
                                          'accountName']!), // Nama Pemilik Rekening
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    RadioListTile<String>(
                      title: const Text('E-Wallet'),
                      value: 'E-Wallet',
                      groupValue: selectedMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedMethod = value;
                          selectedBankOrWallet = null;
                        });
                      },
                    ),
                    if (selectedMethod == 'E-Wallet') ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Column(
                          children: walletOptions.map((wallet) {
                            return RadioListTile<String>(
                              value: wallet['name']!, // Nama wallet
                              groupValue: selectedBankOrWallet,
                              onChanged: (value) {
                                setState(() {
                                  selectedBankOrWallet =
                                      value; // Menyimpan nama wallet
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              title: Row(
                                children: [
                                  Image.asset(
                                    wallet['logo']!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(wallet[
                                          'accountNumber']!), // Nomor Rekening
                                      Text(wallet[
                                          'accountName']!), // Nama Pemilik Rekening
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Total: Rp.${widget.total}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: simulatePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  'Bayar Sekarang',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickImage, // Memanggil fungsi untuk memilih gambar
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  'Unggah Bukti Transfer',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              if (proofImage != null)
                Image.file(
                  proofImage!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        showUnselectedLabels: true,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyOrdersPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), label: 'Payment'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Orders'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
