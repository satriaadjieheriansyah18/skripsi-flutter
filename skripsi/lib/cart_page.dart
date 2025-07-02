import 'package:flutter/material.dart';
import 'package:skripsi/MyOrders_page.dart';
import 'package:skripsi/awal_page.dart';
import 'package:skripsi/home_page.dart';
import 'package:skripsi/osm_map_picker_page.dart';
import 'package:skripsi/payment_page.dart';
import 'package:skripsi/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  LatLng? selectedLocation;
  String? mapLink;

  List<Map<String, String>> savedAddresses = [];
  bool saveAddressChecked = false;
  int quantity = 1;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mapLinkController = TextEditingController();

  void incrementQty() {
    setState(() {
      quantity++;
    });
  }

  void decrementQty() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AwalPage()),
        (route) => false,
      );
    }
  }

  Future<void> saveCartDataToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart_name', nameController.text.trim());
    await prefs.setString('cart_phone', phoneController.text.trim());
    await prefs.setString('cart_address', addressController.text.trim());
    await prefs.setString('cart_maps', mapLink!);
  }

  @override
  void initState() {
    super.initState();
    loadSavedAddresses();
  }

  Future<void> loadSavedAddresses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList('saved_addresses') ?? [];
    setState(() {
      savedAddresses = savedList
          .map((item) => Map<String, String>.from(jsonDecode(item)))
          .toList();
    });
  }

  Future<void> saveCurrentAddress() async {
    if (addressController.text.isEmpty || mapLink == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Isi alamat lengkap dan pilih lokasi terlebih dahulu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newEntry = {
      'address': addressController.text.trim(),
      'phone': phoneController.text.trim(),
      'mapLink': mapLink!,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList('saved_addresses') ?? [];

    // Cek duplikat berdasarkan link lokasi
    final exists = savedList.any((item) {
      final decoded = jsonDecode(item);
      return decoded['mapLink'] == newEntry['mapLink'];
    });

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Alamat ini sudah pernah disimpan sebelumnya."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    savedList.add(jsonEncode(newEntry));
    await prefs.setStringList('saved_addresses', savedList);
    await loadSavedAddresses();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alamat berhasil disimpan.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteAddress(Map<String, String> addressToDelete) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList('saved_addresses') ?? [];

    savedList.removeWhere((item) {
      final decoded = Map<String, dynamic>.from(jsonDecode(item));
      return decoded['address'] == addressToDelete['address'] &&
          decoded['maps'] == addressToDelete['maps'];
    });

    await prefs.setStringList('saved_addresses', savedList);
    loadSavedAddresses(); // refresh
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alamat berhasil dihapus')),
    );
  }

  void _confirmDelete(Map<String, String> addressToDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Alamat"),
        content: const Text("Apakah Anda yakin ingin menghapus alamat ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tidak
            child: const Text("Tidak"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              _deleteAddress(addressToDelete); // Hapus
            },
            child: const Text(
              "Ya",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 245, 250, 1.0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(onLogout: _logout),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: 350,
                  height: 180,
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
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/galon.png',
                        height: 150,
                        width: 150,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Galon',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '-Ku',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  'Rp.${(quantity * 12000).toString()}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: decrementQty,
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      '$quantity',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: incrementQty,
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              inputField("NAMA", nameController),
              inputField("NO TELP", phoneController,
                  keyboardType: TextInputType.phone),
              if (savedAddresses.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ExpansionTile(
                    title: const Text("Pilih dari alamat yang tersimpan"),
                    children: savedAddresses.map((item) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F7FC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading:
                              const Icon(Icons.location_on, color: Colors.blue),
                          title: Text(
                            item['address'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            item['mapLink'] ?? '',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(item),
                          ),
                          onTap: () {
                            setState(() {
                              addressController.text = item['address'] ?? '';
                              mapLink = item['maps'] ?? '';
                              mapLink = item['mapLink'];
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Alamat otomatis dimasukkan")),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              inputField("ALAMAT LENGKAP", addressController),
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text("Pilih Lokasi di Peta"),
                onPressed: () async {
                  final result = await Navigator.push<LatLng>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OSMMapPickerPage(initialPos: selectedLocation),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      selectedLocation = result;
                      mapLink =
                          'https://maps.google.com/?q=${result.latitude},${result.longitude}';
                    });
                  }
                },
              ),
              if (mapLink != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Link Maps:\n$mapLink",
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: saveAddressChecked,
                      onChanged: (value) {
                        setState(() {
                          saveAddressChecked = value ?? false;
                        });
                      },
                    ),
                    const Expanded(
                        child:
                            Text("Simpan alamat ini untuk digunakan kembali")),
                  ],
                ),
              ),
              if (saveAddressChecked)
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("Simpan Alamat Otomatis"),
                    onPressed: saveCurrentAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _showPaymentPopup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF61A8EA),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Bayar Sekarang",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        showUnselectedLabels: true,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentPage(
                  total: quantity * 12000,
                  mapLink: mapLink ?? '',
                ),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyOrdersPage(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 25), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart, size: 25), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money, size: 25), label: 'Payment'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 25), label: 'My Orders'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget inputField(String label, TextEditingController controller,
      {bool enabled = true, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showPaymentPopup() {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ||
        mapLink == null ||
        mapLink!.isEmpty) {
      // Menampilkan pesan peringatan jika ada field yang kosong
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Harap isi semua data sebelum melanjutkan ke pembayaran!'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Jangan lanjutkan ke pembayaran jika ada yang kosong
    }
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            height: 200,
            width: 250,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: const Text(
                              'TOTAL:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Text(
                            'Rp.${(quantity * 12000).toString()}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await saveCartDataToPrefs();
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                total: quantity * 12000,
                                mapLink: mapLink!,
                              ),
                            ),
                          );
                          // Lanjutkan ke logika pembayaran
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9DDCFF),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Bayar Sekarang',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Header extends StatelessWidget {
  final VoidCallback onLogout;
  const Header({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      // Tambahkan tinggi agar lingkaran terlihat
      child: Stack(
        clipBehavior: Clip.none, // Biarkan elemen bisa keluar dari batas Stack
        children: [
          // Lingkaran Dekorasi
          Positioned(
            top: -190, // Posisi atas untuk ellipse pertama
            left: -110,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: Colors.white, // Warna biru muda
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Header Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const Text(
                  'Cart',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                const Spacer(),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'profile') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfilePage()),
                        );
                      } else if (value == 'logout') {
                        _showLogoutDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'profile', child: Text('Lihat Profil')),
                      const PopupMenuItem(
                          value: 'logout', child: Text('Logout')),
                    ],
                    icon: const Icon(Icons.person, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              onLogout(); // ✅ Panggil fungsi logout yang dikirim dari HomePage
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
