// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issued_items_privileges.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IssuedItemsPrivileges _$IssuedItemsPrivilegesFromJson(
        Map<String, dynamic> json) =>
    IssuedItemsPrivileges(
      issueItem: json['issue_item'],
      changeIssuedItem: json['change_issued_item'],
      deleteIssuedItem: json['delete_issued_item'],
    );

Map<String, dynamic> _$IssuedItemsPrivilegesToJson(
        IssuedItemsPrivileges instance) =>
    <String, dynamic>{
      'issue_item': instance.issueItem,
      'change_issued_item': instance.changeIssuedItem,
      'delete_issued_item': instance.deleteIssuedItem,
    };
