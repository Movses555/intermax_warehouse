import 'package:json_annotation/json_annotation.dart';

part 'reports_privileges.g.dart';

@JsonSerializable()
class ReportsPrivileges{

  @JsonKey(name: 'see_reports')
  var seeReports;

  ReportsPrivileges({this.seeReports});
  factory ReportsPrivileges.fromJson(Map<String, dynamic> json) => _$ReportsPrivilegesFromJson(json);

  Map<String, dynamic> json() => _$ReportsPrivilegesToJson(this);
}