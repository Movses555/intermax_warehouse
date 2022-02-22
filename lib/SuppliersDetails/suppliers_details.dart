import 'package:json_annotation/json_annotation.dart';

part 'suppliers_details.g.dart';

@JsonSerializable()
class Suppliers{

  @JsonKey(name: 'supplier_name')
  var supplierName;

  Suppliers({this.supplierName});

  factory Suppliers.fromJson(Map<String, dynamic> json) => _$SuppliersFromJson(json);
  Map<String, dynamic> toJson() => _$SuppliersToJson(this);
}