// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issued_items.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IssuedItems _$IssuedItemsFromJson(Map<String, dynamic> json) => IssuedItems(
      id: json['id'],
      brigade: json['brigade'],
      members: json['members'],
      item: json['item'],
      date: json['date'],
      count: json['count'],
      countOption: json['count_option'],
      photo: json['photo'],
      user: json['user'],
    )..description = json['description'];

Map<String, dynamic> _$IssuedItemsToJson(IssuedItems instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brigade': instance.brigade,
      'members': instance.members,
      'item': instance.item,
      'description': instance.description,
      'date': instance.date,
      'count': instance.count,
      'count_option': instance.countOption,
      'photo': instance.photo,
      'user': instance.user,
    };
