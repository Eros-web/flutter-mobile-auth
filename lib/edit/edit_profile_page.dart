import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  final String uid; // UID, bukan email
  const EditProfilePage({super.key, required this.uid});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdateController;

  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];
  String _selectedGender = '';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _birthdateController = TextEditingController();
    _loadUserData();
  }

  String normalizeGender(String? value) {
    final lower = value?.toLowerCase().trim();

    if (lower == 'l' || lower == 'male' || lower == 'pria' || lower == 'laki-laki') {
      return 'Laki-laki';
    } else if (lower == 'p' || lower == 'female' || lower == 'wanita' || lower == 'perempuan') {
      return 'Perempuan';
    } else {
      return '';
    }
  }

  void _loadUserData() async {
    final details = await authService.getUserDetails(widget.uid);
    if (!mounted) return;

    if (details != null) {
      final rawBirthdate = details['birthdate'] ?? '';
      final displayBirthdate = _convertToDisplayDate(rawBirthdate);

      setState(() {
        _usernameController.text = details['username'] ?? '';
        _phoneController.text = details['phone'] ?? '';
        _birthdateController.text = displayBirthdate;
        _selectedGender = normalizeGender(details['gender']);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  String _convertToDisplayDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return '${date.day.toString().padLeft(2, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.year}';
    } catch (_) {
      return '';
    }
  }

  String _convertToIsoDate(String displayDate) {
    try {
      final parts = displayDate.split('-');
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _selectBirthdate() async {
    final initialDate = _birthdateController.text.isNotEmpty
        ? DateTime.tryParse(_convertToIsoDate(_birthdateController.text)) ?? DateTime(2000)
        : DateTime(2000);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepOrange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final formatted = '${picked.day.toString().padLeft(2, '0')}-'
            '${picked.month.toString().padLeft(2, '0')}-'
            '${picked.year}';
        _birthdateController.text = formatted;
      });
    }
  }

  void _saveChanges() async {
    if (_usernameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _selectedGender.isEmpty ||
        _birthdateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua data wajib diisi!')),
      );
      return;
    }

    final genderToSave = _selectedGender == 'Laki-laki' ? 'L' : 'P';
    final birthdateToSave = _convertToIsoDate(_birthdateController.text);

    await authService.updateUserDetails(widget.uid, {
      'username': _usernameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'gender': genderToSave,
      'birthdate': birthdateToSave,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sunting Profil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Nomor HP'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _genderOptions.contains(_selectedGender) ? _selectedGender : null,
                    items: _genderOptions.map((gender) {
                      return DropdownMenuItem(value: gender, child: Text(gender));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedGender = value ?? ''),
                    decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                  ),
                  TextField(
                    controller: _birthdateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Lahir (DD-MM-YYYY)',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: _selectBirthdate,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      child: const Text("Simpan"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
