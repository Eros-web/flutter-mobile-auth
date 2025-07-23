import 'package:flutter/material.dart';

class EditAddressPage extends StatefulWidget {
  final String initialLabel;
  final String initialDetail;

  const EditAddressPage({
    super.key,
    required this.initialLabel,
    required this.initialDetail,
  });

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  late TextEditingController _labelController;
  late TextEditingController _detailController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.initialLabel);
    _detailController = TextEditingController(text: widget.initialDetail);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sunting Alamat")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(labelText: "Label Alamat"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _detailController,
              decoration: const InputDecoration(labelText: "Detail Alamat"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'label': _labelController.text,
                  'detail': _detailController.text,
                });
              },
              child: const Text("Simpan Perubahan"),
            )
          ],
        ),
      ),
    );
  }
}
