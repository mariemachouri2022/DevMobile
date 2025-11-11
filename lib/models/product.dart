class Product {
  int? id;
  String name;
  String category;
  String description;
  double price;
  int quantityInStock;
  String? imagePath;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.quantityInStock,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'quantityInStock': quantityInStock,
      'imagePath': imagePath,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      description: map['description'],
      price: map['price'] is int ? (map['price'] as int).toDouble() : map['price'],
      quantityInStock: map['quantityInStock'],
      imagePath: map['imagePath'],
    );
  }

  // Méthode copyWith essentielle
  Product copyWith({
    int? id,
    String? name,
    String? category,
    String? description,
    double? price,
    int? quantityInStock,
    String? imagePath,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      quantityInStock: quantityInStock ?? this.quantityInStock,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}