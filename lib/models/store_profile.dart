class StoreProfile {
  String name;
  String slogan;
  String address;
  String phone;
  String cashierName;
  String footerMessage;

  StoreProfile({
    this.name = 'WARUNG CAK ARIP',
    this.slogan = 'Standby 24 Jam • Sistem Kasir & Stok',
    this.address = 'Jl. Raya Madura No. 18, Jakarta Timur',
    this.phone = '0812-3456-7890',
    this.cashierName = 'Cak Arip',
    this.footerMessage = 'Matur Suksma!\nTerima kasih sudah belanja di Warung Cak Arip. Barang yang dibeli tidak dapat ditukar kecuali cacat pabrik.',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'slogan': slogan,
    'address': address,
    'phone': phone,
    'cashierName': cashierName,
    'footerMessage': footerMessage,
  };

  factory StoreProfile.fromJson(Map<String, dynamic> json) => StoreProfile(
    name: json['name'] as String? ?? 'WARUNG CAK ARIP',
    slogan: json['slogan'] as String? ?? 'Standby 24 Jam • Sistem Kasir & Stok',
    address: json['address'] as String? ?? 'Jl. Raya Madura No. 18, Jakarta Timur',
    phone: json['phone'] as String? ?? '0812-3456-7890',
    cashierName: json['cashierName'] as String? ?? 'Cak Arip',
    footerMessage: json['footerMessage'] as String? ??
        'Matur Suksma!\nTerima kasih sudah belanja di Warung Cak Arip. Barang yang dibeli tidak dapat ditukar kecuali cacat pabrik.',
  );
}

