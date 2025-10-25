// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sneaker.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SneakerAdapter extends TypeAdapter<Sneaker> {
  @override
  final int typeId = 0;

  @override
  Sneaker read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sneaker(
      name: fields[0] as String,
      brand: fields[1] as String,
      price: fields[2] as double,
      quantity: fields[3] as int,
      imagePath: fields[4] as String?,
      description: fields[5] as String?,
      dateAdded: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Sneaker obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.brand)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.dateAdded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SneakerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
