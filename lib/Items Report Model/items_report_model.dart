import 'package:json_annotation/json_annotation.dart';

part 'items_report_model.g.dart';

@JsonSerializable()
class ItemReport{

  @JsonKey(name: 'name')
  var name;

  @JsonKey(name: 'price')
  var price;

  @JsonKey(name: 'date')
  var date;

  @JsonKey(name: 'count')
  var count;

  @JsonKey(name: 'count_option')
  var count_option;

  @JsonKey(name: 'supplier')
  var supplier;

  @JsonKey(name: 'photo')
  var photo;

  ItemReport({
    this.name,
    this.price,
    this.date,
    this.count,
    this.count_option,
    this.supplier,
    this.photo
  });

  factory ItemReport.fromJson(Map<String, dynamic> json) => _$ItemReportFromJson(json);

  Map<String, dynamic> toJson() => _$ItemReportToJson(this);

}