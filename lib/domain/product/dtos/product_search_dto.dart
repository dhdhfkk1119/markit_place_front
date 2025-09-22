class ProductSearchDTO {
  final String? keyword;
  final String? sortBy;
  final List<String>? tags;
  final String? sortOrder;
  final int? minPrice;
  final int? maxPrice;
  final String? priceRange;
  final int? itemCategoryId;
  final double? latitude;
  final double? longitude;
  final double? distanceInMeter;
  final int page;
  final int size;
  final bool? hasNext;

  const ProductSearchDTO({
    this.keyword,
    this.sortBy,
    this.tags,
    this.sortOrder,
    this.minPrice,
    this.maxPrice,
    this.priceRange,
    this.itemCategoryId,
    this.latitude,
    this.longitude,
    this.distanceInMeter,
    this.page = 0,
    this.size = 10,
    this.hasNext = true,
  });

  // copyWith 메서드 직접 구현
  ProductSearchDTO copyWith({
    String? keyword,
    String? sortBy,
    List<String>? tags,
    String? sortOrder,
    int? minPrice,
    int? maxPrice,
    String? priceRange,
    int? itemCategoryId,
    double? latitude,
    double? longitude,
    double? distanceInMeter,
    int? page,
    int? size,
    bool? hasNext,
  }) {
    return ProductSearchDTO(
      keyword: keyword ?? this.keyword,
      sortBy: sortBy ?? this.sortBy,
      tags: tags ?? this.tags,
      sortOrder: sortOrder ?? this.sortOrder,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      priceRange: priceRange ?? this.priceRange,
      itemCategoryId: itemCategoryId ?? this.itemCategoryId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceInMeter: distanceInMeter ?? this.distanceInMeter,
      page: page ?? this.page,
      size: size ?? this.size,
      hasNext: hasNext ?? this.hasNext,
    );
  }

  // toMap 메서드 (queryParameters에 사용)
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'page': page,
      'size': size,
    };
    if (keyword != null) map['keyword'] = keyword;
    if (sortBy != null) map['sortBy'] = sortBy;
    if (tags != null) map['tags'] = tags;
    if (sortOrder != null) map['sortOrder'] = sortOrder;
    if (minPrice != null) map['minPrice'] = minPrice;
    if (maxPrice != null) map['maxPrice'] = maxPrice;
    if (priceRange != null) map['priceRange'] = priceRange;
    if (itemCategoryId != null) map['itemCategoryId'] = itemCategoryId;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (distanceInMeter != null) map['distanceInMeter'] = distanceInMeter;
    return map;
  }
}
