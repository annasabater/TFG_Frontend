//lib/models/shipping_info.dart

class ShippingInfo {
  final String address;
  final String phone;

  ShippingInfo({required this.address, required this.phone});

  Map<String, dynamic> toJson() => {
        'address': address,
        'phone'  : phone,
      };
}
