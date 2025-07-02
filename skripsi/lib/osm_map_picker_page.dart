import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OSMMapPickerPage extends StatefulWidget {
  final LatLng? initialPos;
  const OSMMapPickerPage({super.key, this.initialPos});

  @override
  State<OSMMapPickerPage> createState() => _OSMMapPickerPageState();
}

class _OSMMapPickerPageState extends State<OSMMapPickerPage> {
  late LatLng selected;
  final TextEditingController searchCtrl = TextEditingController();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    selected = widget.initialPos ?? LatLng(-6.2, 106.8); // default Jakarta
  }

  Future<void> _searchAndGo() async {
    final query = searchCtrl.text.trim();
    if (query.isEmpty) return;

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1',
    );

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'FlutterApp/1.0' // Wajib sesuai aturan Nominatim
      });

      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final lat = double.tryParse(data[0]['lat']);
        final lon = double.tryParse(data[0]['lon']);
        if (lat != null && lon != null) {
          final newLoc = LatLng(lat, lon);
          setState(() {
            selected = newLoc;
          });
          _mapController.move(newLoc, 17.0); // 👉 Auto-pindah dan zoom
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alamat tidak ditemukan')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghubungi server')),
      );
    }
  }

  void _saveLocation() {
    Navigator.pop(context, selected); // Kirim kembali ke CartPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Cari alamat...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _searchAndGo(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _searchAndGo,
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: selected,
                zoom: 15.0,
                onTap: (_, latlng) => setState(() => selected = latlng),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: selected,
                      child: const Icon(Icons.location_pin,
                          color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Simpan Lokasi"),
              onPressed: _saveLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
