class Item {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String? imageUrl;
  final String category; // "book" أو "stationery"

  Item({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.category,
  });

  Item copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
  }) {
    return Item(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl ?? '',
      'category': category,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      ownerId: json['ownerId'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'] == '' ? null : json['imageUrl'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toMap() => toJson();

  factory Item.fromMap(Map<String, dynamic> map) => Item.fromJson(map);
}
