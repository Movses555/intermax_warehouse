// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Log _$LogFromJson(Map<String, dynamic> json) => Log(
      id: json['id'],
      subsection: json['subsection'],
      item: json['item'],
      brigade: json['brigade'],
      members: json['members'],
      changedProperty: json['changed_property'],
      oldValue: json['old_value'],
      newValue: json['new_value'],
      date: json['date'],
      user: json['user'],
    );

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
      'id': instance.id,
      'subsection': instance.subsection,
      'item': instance.item,
      'brigade': instance.brigade,
      'members': instance.members,
      'changed_property': instance.changedProperty,
      'old_value': instance.oldValue,
      'new_value': instance.newValue,
      'date': instance.date,
      'user': instance.user,
    };
