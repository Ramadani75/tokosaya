class PrinterSettings {
  String paperSize; // '58mm' | '80mm'
  bool autoPrint;
  String deviceName;
  String macAddress;
  int batteryLevel;
  bool isConnected;

  PrinterSettings({
    this.paperSize = '58mm',
    this.autoPrint = true,
    this.deviceName = 'POS-58 Bluetooth',
    this.macAddress = '66:32:B1:84:9A:12 • Port 9100',
    this.batteryLevel = 85,
    this.isConnected = true,
  });

  Map<String, dynamic> toJson() => {
    'paperSize': paperSize,
    'autoPrint': autoPrint,
    'deviceName': deviceName,
    'macAddress': macAddress,
    'batteryLevel': batteryLevel,
    'isConnected': isConnected,
  };

  factory PrinterSettings.fromJson(Map<String, dynamic> json) => PrinterSettings(
    paperSize: json['paperSize'] as String? ?? '58mm',
    autoPrint: json['autoPrint'] as bool? ?? true,
    deviceName: json['deviceName'] as String? ?? 'POS-58 Bluetooth',
    macAddress: json['macAddress'] as String? ?? '66:32:B1:84:9A:12 • Port 9100',
    batteryLevel: (json['batteryLevel'] as num?)?.toInt() ?? 85,
    isConnected: json['isConnected'] as bool? ?? true,
  );
}

