import 'package:json_annotation/json_annotation.dart';

part 'issued_items_privileges.g.dart';

@JsonSerializable()
class IssuedItemsPrivileges{

  @JsonKey(name: 'issue_item')
  var issueItem;

  @JsonKey(name: 'change_issued_item') 
  var changeIssuedItem;

  @JsonKey(name: 'delete_issued_item')
  var deleteIssuedItem;

  IssuedItemsPrivileges({this.issueItem, this.changeIssuedItem, this.deleteIssuedItem});
  factory IssuedItemsPrivileges.fromJson(Map<String, dynamic> json) => _$IssuedItemsPrivilegesFromJson(json);

  Map<String, dynamic> toJson() => _$IssuedItemsPrivilegesToJson(this);
}