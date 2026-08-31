import 'telco.dart';

/// A purchasable data bundle offered by a [TelcoNetwork].
class DataPlan {
  final String id;
  final TelcoNetwork network;
  final String name;
  final double price;
  final String validity;

  const DataPlan({
    required this.id,
    required this.network,
    required this.name,
    required this.price,
    required this.validity,
  });

  factory DataPlan.fromJson(Map<String, dynamic> json) => DataPlan(
        id: json['id']?.toString() ?? '',
        network: TelcoNetwork.parse(json['network'] as String?),
        name: json['name'] as String? ?? '',
        price: (json['price'] as num? ?? 0).toDouble(),
        validity: json['validity'] as String? ?? '',
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'network': network.name, 'name': name, 'price': price, 'validity': validity};
}
