import 'package:flutter/material.dart';
import 'package:skripsi/payment_page.dart';
import 'dart:convert';
import 'home_page.dart';
import 'cart_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      print("User ID tidak ditemukan di SharedPreferences.");
      return;
    }

    final response = await http.get(
        Uri.parse('http://192.168.228.82:8000/api/orders?user_id=$userId'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      data.sort((a, b) {
        try {
          DateTime timeA = DateTime.parse(a['order_time']); // Parsing ISO 8601
          DateTime timeB = DateTime.parse(b['order_time']); // Parsing ISO 8601
          return timeB.compareTo(timeA); // Mengurutkan dari yang paling awal
        } catch (e) {
          print("Error parsing date: $e");
          return 0; // Jika error parsing, tidak mengubah urutan
        }
      });

      setState(() {
        orders = data.cast<Map<String, dynamic>>();
      });
    } else {
      print("Gagal mengambil data pesanan");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.blue),
            ),
          ),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? const Center(child: Text('Belum ada pesanan.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                int orderNumber = orders.length - index;

                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black45),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            order['status'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: order['status'] == 'sedang diproses'
                                  ? Colors.red
                                  : order['status'] == 'sedang diantar'
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "#$orderNumber",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
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
                            width: 80,
                            height: 80,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['product'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Rp.${order['total']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${order['order_time']} • ${order['qty']} Items",
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
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
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PaymentPage(
                        total: 12000,
                        mapLink: '',
                      )),
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
