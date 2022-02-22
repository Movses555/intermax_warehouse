import 'package:json_annotation/json_annotation.dart';

part 'suppliers_privileges.g.dart';

@JsonSerializable()
class SuppliersPrivileges{
  
  @JsonKey(name: 'add_supplier')
  var addSupplier;
   
  @JsonKey(name: 'delete_supplier') 
  var deleteSupplier;

  SuppliersPrivileges({this.addSupplier, this.deleteSupplier});
  factory SuppliersPrivileges.fromJson(Map<String, dynamic> json) => _$SuppliersPrivilegesFromJson(json);

  Map<String, dynamic> toJson() => _$SuppliersPrivilegesToJson(this);
}