// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'returned_privileges.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReturnedPrivileges _$ReturnedPrivilegesFromJson(Map<String, dynamic> json) =>
    ReturnedPrivileges(
      addReturnedItem: json['add_returned_item'],
      changeReturnedItem: json['change_returned_item'],
      deleteReturnedItem: json['delete_returned_item'],
    );

Map<String, dynamic> _$ReturnedPrivilegesToJson(ReturnedPrivileges instance) =>
    <String, dynamic>{
      'add_returned_item': instance.addReturnedItem,
      'change_returned_item': instance.changeReturnedItem,
      'delete_returned_item': instance.deleteReturnedItem,
    };
