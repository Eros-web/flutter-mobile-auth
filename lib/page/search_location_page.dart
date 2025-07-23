import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:myapp/component/outlet_model.dart';
import 'package:myapp/page/add_address.dart';
import 'package:myapp/page/edit_address.dart';

class SearchLocationPage extends StatefulWidget {
  final String? initialSearchQuery;

  const SearchLocationPage({super.key, this.initialSearchQuery});

  @override
  State<SearchLocationPage> createState() => _SearchLocationPageState();
}

class _SearchLocationPageState extends State<SearchLocationPage> {
  String _selectedMethod = 'Delivery';
  final TextEditingController _locationController = TextEditingController();
  final List<String> _methods = ['Delivery', 'Pickup', 'Dine In'];

  final List<Outlet> _outlets = [
    Outlet(
      name: "JENSUD IV-PALEMBANG",
      address: "Jl. Jendral Sudirman Rt. 16 Rw Kec Ilir Timur I",
      distance: 1.2,
      methods: ['Pickup', 'Delivery', 'Dine In'],
      brand: "Cerita Roti",
      latitude: -2.9667,
      longitude: 104.7500,
    ),
    Outlet(
      name: "RE MARTADINATA",
      address: "Jl. Re. Martadinata, Rt 35 Rw 14",
      distance: 0.23,
      methods: ['Pickup', 'Delivery'],
      brand: "Cerita Roti",
      latitude: -2.9700,
      longitude: 104.7400,
    ),
  ];

  List<Map<String, dynamic>> _savedAddresses = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null) {
      _locationController.text = widget.initialSearchQuery!;
    }
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedJson = prefs.getString('saved_addresses');
    if (savedJson != null) {
      final List decoded = jsonDecode(savedJson);
      setState(() {
        _savedAddresses = List<Map<String, dynamic>>.from(decoded);
      });
    }
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_addresses', jsonEncode(_savedAddresses));
  }

  Widget _buildMethodToggle() {
    return ToggleButtons(
      isSelected: _methods.map((m) => m == _selectedMethod).toList(),
      onPressed: (index) {
        setState(() {
          _selectedMethod = _methods[index];
        });
      },
      borderRadius: BorderRadius.circular(20),
      selectedColor: Colors.white,
      fillColor: Colors.deepPurple,
      color: Colors.black87,
      children: _methods
          .map((m) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(m),
              ))
          .toList(),
    );
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Layanan lokasi tidak aktif.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Widget _buildDeliveryUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: "Ketik alamat tujuan atau gunakan lokasi saat ini",
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () async {
                try {
                  final pos = await _getCurrentLocation();
                  _locationController.text =
                      "Terdekat dari lokasimu (Lat: ${pos.latitude}, Long: ${pos.longitude})";
                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal ambil lokasi: $e")),
                  );
                }
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.add_location_alt),
          label: const Text("Tambah Alamat Baru"),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddAddressPage()),
            );
            if (result != null && result is Map<String, dynamic>) {
              _locationController.text = result['detail'];
              setState(() {
                _savedAddresses.add(result);
              });
              _saveAddresses();
            }
          },
        ),
        const Divider(),
        const Text("Alamat Terdaftar:", style: TextStyle(fontWeight: FontWeight.bold)),
        ..._savedAddresses.map((addr) => _buildAddressCard(
              addr['label'], addr['detail'], addr['primary'] ?? false,
            )),
      ],
    );
  }

  Widget _buildAddressCard(String label, String detail, bool isPrimary) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            Text(label),
            if (isPrimary)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text("Utama", style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
          ],
        ),
        subtitle: Text(detail),
        trailing: Wrap(
          spacing: 6,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditAddressPage(
                      initialLabel: label,
                      initialDetail: detail,
                    ),
                  ),
                );
                if (updated != null && updated is Map<String, dynamic>) {
                  setState(() {
                    final index = _savedAddresses.indexWhere(
                        (a) => a['label'] == label && a['detail'] == detail);
                    if (index != -1) {
                      _savedAddresses[index]['label'] = updated['label'];
                      _savedAddresses[index]['detail'] = updated['detail'];
                    }
                  });
                  _saveAddresses();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _savedAddresses.removeWhere(
                      (a) => a['label'] == label && a['detail'] == detail);
                });
                _saveAddresses();
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'method': _selectedMethod,
                  'location': detail,
                  'outlet': null,
                });
              },
              child: const Text("Pilih"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutletList() {
    final filtered = _outlets.where((o) => o.methods.contains(_selectedMethod)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filtered.map((outlet) {
        return Card(
          child: ListTile(
            title: Text(outlet.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(outlet.address),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    Text(" ${outlet.distance.toStringAsFixed(2)} km"),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const Text(" 07:00 - 22:00"),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.check_circle_outline),
            onTap: () {
              Navigator.pop(context, {
                'method': _selectedMethod,
                'location': outlet.address,
                'outlet': outlet.name,
              });
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Cara Pemesanan"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pilih Metode:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildMethodToggle(),
            const SizedBox(height: 16),
            if (_selectedMethod == 'Delivery') _buildDeliveryUI() else _buildOutletList(),
          ],
        ),
      ),
    );
  }
}
