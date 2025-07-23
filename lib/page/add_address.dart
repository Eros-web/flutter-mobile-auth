import 'package:flutter/material.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitAddress() {
    final label = _labelController.text.trim();
    final detail = _addressController.text.trim();

    if (label.isEmpty || detail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Label dan Alamat tidak boleh kosong')),
      );
      return;
    }

    Navigator.pop(context, {
      'label': label,
      'detail': detail,
      'primary': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambahkan Alamat'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Masukkan label dan alamat lengkap:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),

            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label Alamat (contoh: Rumah, Kantor)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Detail Alamat',
                hintText: 'Contoh: Jl. Jend. Sudirman No.123, Palembang',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitAddress,
                child: const Text('Simpan Alamat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
