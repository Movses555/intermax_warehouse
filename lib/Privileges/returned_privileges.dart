import 'package:json_annotation/json_annotation.dart';

part 'returned_privileges.g.dart';

@JsonSerializable()
class ReturnedPrivileges{

  @JsonKey(name: 'add_returned_item')
  var addReturnedItem;
  
  @JsonKey(name: 'change_returned_item')
  var changeReturnedItem;

  @JsonKey(name: 'delete_returned_item') 
  var deleteReturnedItem;

  ReturnedPrivileges({this.addReturnedItem, this.changeReturnedItem, this.deleteReturnedItem});
  factory ReturnedPrivileges.fromJson(Map<String, dynamic> json) => _$ReturnedPrivilegesFromJson(json);

  Map<String, dynamic> toJson() => _$ReturnedPrivilegesToJson(this);
}