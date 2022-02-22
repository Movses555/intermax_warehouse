// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse_item_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WarehouseItemDetails _$WarehouseItemDetailsFromJson(
        Map<String, dynamic> json) =>
    WarehouseItemDetails(
      id: json['id'],
      itemName: json['item_name'],
      itemDescription: json['item_description'],
      itemPrice: json['item_price'],
      itemDate: json['item_date'],
      itemCount: json['item_count'],
      itemCountOptions: json['item_count_options'],
      itemSupplier: json['item_supplier'],
      itemPhoto: json['item_photo'],
    );

Map<String, dynamic> _$WarehouseItemDetailsToJson(
        WarehouseItemDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_name': instance.itemName,
      'item_description': instance.itemDescription,
      'item_price': instance.itemPrice,
      'item_date': instance.itemDate,
      'item_count': instance.itemCount,
      'item_count_options': instance.itemCountOptions,
      'item_supplier': instance.itemSupplier,
      'item_photo': instance.itemPhoto,
    };
