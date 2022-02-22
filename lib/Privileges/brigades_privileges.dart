import 'package:json_annotation/json_annotation.dart';

part 'brigades_privileges.g.dart';

@JsonSerializable()
class BrigadesPrivileges{

  @JsonKey(name: 'add_brigade')
  var addBrigade;

  @JsonKey(name: 'change_brigade')
  var changeBrigade;

  @JsonKey(name: 'delete_brigade')
  var deleteBrigade;

  BrigadesPrivileges({this.addBrigade, this.changeBrigade, this.deleteBrigade});
  factory BrigadesPrivileges.fromJson(Map<String, dynamic> json) => _$BrigadesPrivilegesFromJson(json);

  Map<String, dynamic> toJson() => _$BrigadesPrivilegesToJson(this);
}