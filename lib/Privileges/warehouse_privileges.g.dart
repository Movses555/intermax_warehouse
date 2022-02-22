// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse_privileges.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WarehousePrivileges _$WarehousePrivilegesFromJson(Map<String, dynamic> json) =>
    WarehousePrivileges(
      seeWarehouseContent: json['see_warehouse_content'],
      addItemToWarehouse: json['add_item_to_warehouse'],
      seeItemDetails: json['see_item_details'],
      changeWarehouseItem: json['change_warehouse_item'],
      deleteWarehouseItem: json['delete_warehouse_item'],
      seeItemsReport: json['see_items_report'],
    );

Map<String, dynamic> _$WarehousePrivilegesToJson(
        WarehousePrivileges instance) =>
    <String, dynamic>{
      'see_warehouse_content': instance.seeWarehouseContent,
      'add_item_to_warehouse': instance.addItemToWarehouse,
      'see_item_details': instance.seeItemDetails,
      'change_warehouse_item': instance.changeWarehouseItem,
      'delete_warehouse_item': instance.deleteWarehouseItem,
      'see_items_report': instance.seeItemsReport,
    };
