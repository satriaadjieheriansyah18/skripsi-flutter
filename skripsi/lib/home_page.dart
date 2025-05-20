import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skripsi/MyOrders_page.dart';
import 'package:skripsi/awal_page.dart';
import 'package:skripsi/cart_page.dart';
import 'package:skripsi/payment_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    if (index == 1) {
      // Buka CartPage saat item ke-1 (cart) ditekan
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartPage()),
      );
    } else if (index == 2) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const PaymentPage(total: 12000)));
    } else if (index == 3) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const MyOrdersPage()));
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

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Konfirmasi"),
            content:
                const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop(); // Menutup aplikasi di Android
                  } else if (Platform.isIOS) {
                    exit(0); // Menutup aplikasi di iOS
                  }
                },
                child:
                    const Text("Keluar", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(240, 245, 250, 1.0),
        body: Column(
          children: [
            Header(onLogout: _logout), // ✅ Kirim fungsi logout ke Header
            const SizedBox(height: 20),
            const HomeContent(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBarWidget(
          currentIndex: _selectedIndex,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }
}

// HEADER
class Header extends StatelessWidget {
  final VoidCallback onLogout;
  const Header({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Tambahkan tinggi agar lingkaran terlihat
      child: Stack(
        clipBehavior: Clip.none, // Biarkan elemen bisa keluar dari batas Stack
        children: [
          // Lingkaran Dekorasi
          Positioned(
            top: -170, // Posisi atas untuk ellipse pertama
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
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Untirta',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      TextSpan(
                        text: '-Ku',
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
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

// KONTEN UTAMA
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Galon',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                TextSpan(
                  text: '-Ku',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const GalonCard(),
      ],
    );
  }
}

// KARTU GALON
class GalonCard extends StatelessWidget {
  const GalonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 380,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: Image.asset(
              'assets/galon.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Rp.12.000',
            style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CartPage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Pesan Sekarang',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

// NAVIGASI BAWAH
class BottomNavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const BottomNavigationBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabSelected,
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
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black54,
      showSelectedLabels: true,
    );
  }
}
