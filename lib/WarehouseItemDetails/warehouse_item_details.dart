import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'warehouse_item_details.g.dart';

@JsonSerializable()
class WarehouseItemDetails{
  
  @JsonKey(name: 'id')
  // ignore: prefer_typing_uninitialized_variables
  var id;

  @JsonKey(name: 'item_name')
  // ignore: prefer_typing_uninitialized_variables
  var itemName;
  
  @JsonKey(name: 'item_description')
  // ignore: prefer_typing_uninitialized_variables
  var itemDescription;
  
  @JsonKey(name: 'item_price')
  // ignore: prefer_typing_uninitialized_variables
  var itemPrice;
  
  @JsonKey(name: 'item_date')
  // ignore: prefer_typing_uninitialized_variables
  var itemDate;
  
  @JsonKey(name: 'item_count')
  // ignore: prefer_typing_uninitialized_variables
  var itemCount;
  
  @JsonKey(name: 'item_count_options')
  // ignore: prefer_typing_uninitialized_variables
  var itemCountOptions;
  
  @JsonKey(name: 'item_supplier')
  // ignore: prefer_typing_uninitialized_variables
  var itemSupplier;
  
  @JsonKey(name: 'item_photo')
  // ignore: prefer_typing_uninitialized_variables
  var itemPhoto;

  WarehouseItemDetails({this.id, this.itemName, this.itemDescription, this.itemPrice, this.itemDate, this.itemCount,
                        this.itemCountOptions, this.itemSupplier, this.itemPhoto});
  
  factory WarehouseItemDetails.fromJson(Map<String, dynamic> json) => _$WarehouseItemDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$WarehouseItemDetailsToJson(this);
}