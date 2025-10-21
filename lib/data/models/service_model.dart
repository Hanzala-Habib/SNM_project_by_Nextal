class ServiceModel {
  final String id;
  final String title;
  final double price;
  final double annualPrice;
  final String description;
  final String imageUrl;

  ServiceModel({
    required this.id,
    required this.annualPrice,
    required this.title,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  factory ServiceModel.fromMap(String id, Map<String, dynamic> data) {
    return ServiceModel(
      id: id,
      title: data['title'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      annualPrice: (data['annualPrice'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',

    );
  }
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "price": price,
      "description": description,
      "annualPrice":annualPrice
    };
  }
}
