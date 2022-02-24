import 'package:json_annotation/json_annotation.dart';

part 'items_report_privileges.g.dart';

@JsonSerializable()
class ItemsReportPrivileges{

  @JsonKey(name: 'see_items_report')
  var seeItemsReport;

  @JsonKey(name: 'change_items_report')
  var changeItemsReport;

  @JsonKey(name: 'delete_items_report')
  var deleteItemsReport;

  ItemsReportPrivileges({
    this.seeItemsReport,
    this.changeItemsReport,
    this.deleteItemsReport
  });

  factory ItemsReportPrivileges.fromJson(Map<String, dynamic> json) => _$ItemsReportPrivilegesFromJson(json);

  Map<String, dynamic> toJson() => _$ItemsReportPrivilegesToJson(this);
}