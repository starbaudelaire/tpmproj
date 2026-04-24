import 'package:hive/hive.dart';

class DestinationModel {
  DestinationModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.rating,
    required this.ticketPrice,
    required this.openHours,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final double rating;
  final String ticketPrice;
  final String openHours;
  final bool isFavorite;

  DestinationModel copyWith({bool? isFavorite}) {
    return DestinationModel(
      id: id,
      name: name,
      category: category,
      description: description,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl,
      rating: rating,
      ticketPrice: ticketPrice,
      openHours: openHours,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'imageUrl': imageUrl,
        'rating': rating,
        'ticketPrice': ticketPrice,
        'openHours': openHours,
        'isFavorite': isFavorite,
      };

  factory DestinationModel.fromJson(Map<String, dynamic> json) =>
      DestinationModel(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        description: json['description'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String,
        rating: (json['rating'] as num).toDouble(),
        ticketPrice: json['ticketPrice'] as String,
        openHours: json['openHours'] as String,
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
}

class DestinationModelAdapter extends TypeAdapter<DestinationModel> {
  @override
  final int typeId = 1;

  @override
  DestinationModel read(BinaryReader reader) {
    return DestinationModel(
      id: reader.readString(),
      name: reader.readString(),
      category: reader.readString(),
      description: reader.readString(),
      latitude: reader.readDouble(),
      longitude: reader.readDouble(),
      imageUrl: reader.readString(),
      rating: reader.readDouble(),
      ticketPrice: reader.readString(),
      openHours: reader.readString(),
      isFavorite: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, DestinationModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeString(obj.category)
      ..writeString(obj.description)
      ..writeDouble(obj.latitude)
      ..writeDouble(obj.longitude)
      ..writeString(obj.imageUrl)
      ..writeDouble(obj.rating)
      ..writeString(obj.ticketPrice)
      ..writeString(obj.openHours)
      ..writeBool(obj.isFavorite);
  }
}
