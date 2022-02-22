import 'package:json_annotation/json_annotation.dart';

part 'warehouse_privileges.g.dart';

@JsonSerializable()
class WarehousePrivileges{

  @JsonKey(name: 'see_warehouse_content')
  var seeWarehouseContent;
  
  @JsonKey(name: 'add_item_to_warehouse')
  var addItemToWarehouse;
  
  @JsonKey(name: 'see_item_details')
  var seeItemDetails;
  
  @JsonKey(name: 'change_warehouse_item')
  var changeWarehouseItem;
  
  @JsonKey(name: 'delete_warehouse_item')
  var deleteWarehouseItem;

  @JsonKey(name: 'see_items_report')
  var seeItemsReport;

  WarehousePrivileges({this.seeWarehouseContent, this.addItemToWarehouse, this.seeItemDetails, this.changeWarehouseItem, this.deleteWarehouseItem, this.seeItemsReport});
  factory WarehousePrivileges.fromJson(Map<String, dynamic> json) => _$WarehousePrivilegesFromJson(json);

  Map<String, dynamic> toJson() => _$WarehousePrivilegesToJson(this);
}