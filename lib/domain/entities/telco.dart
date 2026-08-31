/// Nigerian mobile networks supported for airtime and data.
///
/// OCP: adding a new network means adding an enum value and its brand colour —
/// no screen or repository code changes.
enum TelcoNetwork {
  mtn('MTN', 0xFFFFCC00, 0xFF1A1A1A),
  airtel('Airtel', 0xFFE63946, 0xFFFFFFFF),
  glo('Glo', 0xFF7CB342, 0xFFFFFFFF),
  nineMobile('9mobile', 0xFF1B4332, 0xFFFFFFFF);

  final String label;
  final int brandColor;
  final int onBrandColor;

  const TelcoNetwork(this.label, this.brandColor, this.onBrandColor);

  static TelcoNetwork parse(String? raw) => TelcoNetwork.values.firstWhere(
        (n) => n.name == raw || n.label.toLowerCase() == raw?.toLowerCase(),
        orElse: () => TelcoNetwork.mtn,
      );
}

/// Whether the customer is buying voice credit or a data bundle.
enum PurchaseType {
  airtime('Airtime'),
  data('Data Bundle');

  final String label;
  const PurchaseType(this.label);
}
