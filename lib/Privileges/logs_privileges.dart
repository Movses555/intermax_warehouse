import 'package:json_annotation/json_annotation.dart';

part 'logs_privileges.g.dart';

@JsonSerializable()
class LogsPrivileges{

  @JsonKey(name: 'see_logs')
  var seeLogs;

  LogsPrivileges({this.seeLogs});
  factory LogsPrivileges.fromJson(Map<String, dynamic> json) => _$LogsPrivilegesFromJson(json);

  Map<String, dynamic> toJson() => _$LogsPrivilegesToJson(this);
}