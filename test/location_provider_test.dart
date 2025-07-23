import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/provider/location_provider.dart';

void main() {
  group('LocationProvider', () {
    late LocationProvider provider;

    setUp(() {
      provider = LocationProvider();
    });

    test('Default state harus Pickup tanpa alamat dan outlet', () {
      expect(provider.method, 'Pickup');
      expect(provider.addresses.isEmpty, true);
      expect(provider.outlet, null);
    });

    test('Menambahkan address dan trigger notify', () {
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.addAddress('Jl. Baru');

      expect(provider.addresses.contains('Jl. Baru'), true);
      expect(notified, true);

      // Tambah address sama lagi → tidak notify ulang
      notified = false;
      provider.addAddress('Jl. Baru');
      expect(provider.addresses.length, 1);
      expect(notified, false);
    });

    test('Hapus address dengan index valid', () {
      provider.addAddress('A');
      provider.addAddress('B');
      expect(provider.addresses.length, 2);

      provider.removeAddress(0);
      expect(provider.addresses.length, 1);
      expect(provider.addresses.first, 'B');
    });

    test('Set outlet berbeda → notify', () {
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.setOutlet('Outlet A');
      expect(provider.outlet, 'Outlet A');
      expect(notified, true);

      // Set outlet sama lagi → tidak notify
      notified = false;
      provider.setOutlet('Outlet A');
      expect(notified, false);
    });

    test('updateSafe ganti method Delivery dan tambah address', () {
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.updateSafe('Jl. Baru', 'Delivery');
      expect(provider.method, 'Delivery');
      expect(provider.addresses.last, 'Jl. Baru');
      expect(notified, true);

      // Panggil lagi dengan data sama → tidak notify
      notified = false;
      provider.updateSafe('Jl. Baru', 'Delivery');
      expect(notified, false);
    });

    test('updateSafe Pickup: clear address dan set outlet', () {
      provider.updateSafe('Jl. Lama', 'Delivery');
      expect(provider.method, 'Delivery');
      expect(provider.addresses.isNotEmpty, true);

      provider.updateSafe('Outlet B', 'Pickup');
      expect(provider.method, 'Pickup');
      expect(provider.outlet, 'Outlet B');
      expect(provider.addresses.isEmpty, true);
    });

    test('reset mengembalikan default', () {
      provider.updateSafe('Jl. Lama', 'Delivery');
      provider.setOutlet('Outlet Z');

      provider.reset();

      expect(provider.method, 'Pickup');
      expect(provider.addresses.isEmpty, true);
      expect(provider.outlet, null);
    });

    test('updateSafe reject method tidak dikenal', () {
      provider.updateSafe('Jl. X', 'Flying');
      // Harus tetap default, tidak berubah
      expect(provider.method, 'Pickup');
      expect(provider.addresses.isEmpty, true);
    });
  });
}
