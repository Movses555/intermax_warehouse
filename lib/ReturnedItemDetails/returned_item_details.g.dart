// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'returned_item_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReturnedItem _$ReturnedItemFromJson(Map<String, dynamic> json) => ReturnedItem(
      id: json['id'],
      item: json['item'],
      description: json['description'],
      brigade: json['brigade'],
      brigadeMembers: json['brigade_members'],
      date: json['date'],
      count: json['count'],
      countOption: json['count_option'],
    );

Map<String, dynamic> _$ReturnedItemToJson(ReturnedItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item': instance.item,
      'description': instance.description,
      'brigade': instance.brigade,
      'brigade_members': instance.brigadeMembers,
      'date': instance.date,
      'count': instance.count,
      'count_option': instance.countOption,
    };
