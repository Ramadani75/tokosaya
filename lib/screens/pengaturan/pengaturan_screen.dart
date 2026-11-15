import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pos_provider.dart';
import '../../models/store_profile.dart';
import '../../models/printer_settings.dart';
import '../../theme/app_theme.dart';
import '../../widgets/thermal_receipt_widget.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _sloganCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _cashierCtrl;
  late TextEditingController _footerCtrl;

  bool _showMiniReceiptPreview = true;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<PosProvider>(context, listen: false).storeProfile;
    _nameCtrl = TextEditingController(text: profile.name);
    _sloganCtrl = TextEditingController(text: profile.slogan);
    _addressCtrl = TextEditingController(text: profile.address);
    _phoneCtrl = TextEditingController(text: profile.phone);
    _cashierCtrl = TextEditingController(text: profile.cashierName);
    _footerCtrl = TextEditingController(text: profile.footerMessage);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sloganCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _cashierCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final pos = Provider.of<PosProvider>(context, listen: false);
    final updated = StoreProfile(
      name: _nameCtrl.text.trim(),
      slogan: _sloganCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      cashierName: _cashierCtrl.text.trim(),
      footerMessage: _footerCtrl.text.trim(),
    );
    pos.saveStoreProfile(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Identitas warung berhasil disimpan!'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _testPrintDialog(BuildContext context, PrinterSettings printer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.print, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Tes Cetak Berhasil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Perintah cetak dikirim ke "${printer.deviceName}".'),
            const SizedBox(height: 8),
            Text('Ukuran: ${printer.paperSize} • Status: Kepala Thermal Siap.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '--- TEST PRINT POS MADURA ---\nOK! Printer Berfungsi Normal.\n------------------------------',
                style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  void _scanBluetoothDevices(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bluetooth_searching, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Pindai Printer Bluetooth',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 10),
            const LinearProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            _buildDeviceItem('POS-58 Bluetooth (Terhubung)', '66:32:B1:84:9A:12', true),
            _buildDeviceItem('Thermal-Printer-80', '88:42:A0:99:31:02', false),
            _buildDeviceItem('RPP-02N Mini Wireless', '00:1A:7D:DA:71:15', false),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem(String name, String mac, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.secondaryContainerSoft : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: isCurrent ? Border.all(color: AppColors.secondaryContainer) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text('MAC: $mac', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
            ],
          ),
          if (isCurrent)
            const Text('Aktif', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12))
          else
            OutlinedButton(
              onPressed: () {
                final pos = Provider.of<PosProvider>(context, listen: false);
                pos.printerSettings.deviceName = name;
                pos.printerSettings.macAddress = mac;
                pos.savePrinterSettings(pos.printerSettings);
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Pilih', style: TextStyle(fontSize: 11)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pos = Provider.of<PosProvider>(context);
    final printer = pos.printerSettings;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Sub-Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.roseTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengaturan & Perangkat',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  Text(
                    'Kelola profil warung, cetak struk, dan koneksi printer',
                    style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Section 1: Hardware Kasir (Bluetooth Thermal)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.print, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'HARDWARE KASIR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: printer.isConnected ? AppColors.secondary : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    printer.isConnected ? 'Siap Cetak' : 'Terputus',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: printer.isConnected ? AppColors.secondary : AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Main Printer Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device Info Row
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.bluetooth_connected, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                printer.deviceName,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainerSoft,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  '✓ Terhubung',
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            printer.macAddress,
                            style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.battery_5_bar, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            '${printer.batteryLevel}%',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Auto-print Toggle Tile
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Auto Cetak Struk', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text('Langsung cetak nota setelah pembayaran tuntas', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                      Switch(
                        value: printer.autoPrint,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          printer.autoPrint = val;
                          pos.savePrinterSettings(printer);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Paper Size Selector (58mm vs 80mm)
                const Text(
                  'Ukuran Kertas Thermal:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          printer.paperSize = '58mm';
                          pos.savePrinterSettings(printer);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: printer.paperSize == '58mm'
                                ? AppColors.primaryContainer
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '58 mm',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: printer.paperSize == '58mm' ? Colors.white : AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Standar Warung',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      color: printer.paperSize == '58mm' ? Colors.white70 : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                printer.paperSize == '58mm' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                size: 16,
                                color: printer.paperSize == '58mm' ? Colors.white : AppColors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          printer.paperSize = '80mm';
                          pos.savePrinterSettings(printer);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: printer.paperSize == '80mm'
                                ? AppColors.primaryContainer
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '80 mm',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: printer.paperSize == '80mm' ? Colors.white : AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Struk Lebar',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      color: printer.paperSize == '80mm' ? Colors.white70 : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                printer.paperSize == '80mm' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                size: 16,
                                color: printer.paperSize == '80mm' ? Colors.white : AppColors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _testPrintDialog(context, printer),
                        icon: const Icon(Icons.receipt_long, size: 16),
                        label: const Text('Tes Cetak Nota', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryFixed,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          printer.isConnected = !printer.isConnected;
                          pos.savePrinterSettings(printer);
                        },
                        icon: Icon(printer.isConnected ? Icons.link_off : Icons.link, size: 16),
                        label: Text(printer.isConnected ? 'Ganti / Putus' : 'Sambungkan', style: const TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _scanBluetoothDevices(context),
                    icon: const Icon(Icons.radar, size: 16, color: AppColors.primary),
                    label: const Text('Pindai Perangkat Printer Baru Sekitar', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 2: Identitas Usaha & Struk Kasir
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.storefront, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'INFORMASI WARUNG DI STRUK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => setState(() => _showMiniReceiptPreview = !_showMiniReceiptPreview),
                icon: Icon(_showMiniReceiptPreview ? Icons.visibility_off : Icons.visibility, size: 14, color: AppColors.primary),
                label: Text(_showMiniReceiptPreview ? 'Tutup Mini Nota' : 'Lihat Mini Nota', style: const TextStyle(fontSize: 11, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Collapsible Live Mini Receipt Preview
          if (_showMiniReceiptPreview) ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: ThermalReceiptWidget(
                storeProfile: StoreProfile(
                  name: _nameCtrl.text,
                  slogan: _sloganCtrl.text,
                  address: _addressCtrl.text,
                  phone: _phoneCtrl.text,
                  cashierName: _cashierCtrl.text,
                  footerMessage: _footerCtrl.text,
                ),
                previewItems: pos.cart.isNotEmpty ? pos.cart : null,
                previewTotal: pos.cart.isNotEmpty ? pos.cartTotalAmount : 87000,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Dynamic Profile Form Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Nama Warung / Toko *',
                    prefixIcon: Icon(Icons.store, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _sloganCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Slogan / Tagline *',
                    prefixIcon: Icon(Icons.short_text, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Alamat Fisik Toko *',
                    prefixIcon: Icon(Icons.place_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'No. Kontak / WA *',
                          prefixIcon: Icon(Icons.phone_outlined, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _cashierCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Kasir Bertugas *',
                          prefixIcon: Icon(Icons.badge_outlined, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _footerCtrl,
                  onChanged: (_) => setState(() {}),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Pesan Penutup Nota Struk *',
                    prefixIcon: Icon(Icons.message_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Perubahan Identitas Warung'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

