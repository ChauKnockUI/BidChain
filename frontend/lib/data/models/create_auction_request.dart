class CreateAuctionRequest {
  final String title;
  final String description;
  final double startPrice;
  final double stepPrice;
  final DateTime endTime;
  final List<String> images;
  final String categoryId;

  CreateAuctionRequest({
    required this.title,
    required this.description,
    required this.startPrice,
    required this.stepPrice,
    required this.endTime,
    required this.images,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start_price': startPrice,
      'step_price': stepPrice,
      'end_time': endTime.toIso8601String(),
      'images': images,
      'category_id': categoryId,
    };
  }
}
