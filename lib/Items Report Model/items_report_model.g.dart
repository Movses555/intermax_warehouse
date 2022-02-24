// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'items_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemReport _$ItemReportFromJson(Map<String, dynamic> json) => ItemReport(
      item: json['item'],
      price: json['price'],
      date: json['date'],
      count: json['count'],
      count_option: json['count_option'],
      supplier: json['supplier'],
      photo: json['photo'],
    );

Map<String, dynamic> _$ItemReportToJson(ItemReport instance) =>
    <String, dynamic>{
      'item': instance.item,
      'price': instance.price,
      'date': instance.date,
      'count': instance.count,
      'count_option': instance.count_option,
      'supplier': instance.supplier,
      'photo': instance.photo,
    };
