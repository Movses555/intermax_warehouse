import 'package:json_annotation/json_annotation.dart';

part 'log_details.g.dart';

@JsonSerializable()
class Log{
  
  @JsonKey(name: 'id')
  var id;
  
  @JsonKey(name: 'subsection')
  var subsection;
  
  @JsonKey(name: 'item')
  var item;
  
  @JsonKey(name: 'brigade')
  var brigade;
  
  @JsonKey(name: 'members')
  var members;
  
  @JsonKey(name: 'changed_property')
  var changedProperty;
  
  @JsonKey(name: 'old_value')
  var oldValue;
  
  @JsonKey(name: 'new_value')
  var newValue;
  
  @JsonKey(name: 'date')
  var date;
  
  @JsonKey(name: 'user')
  var user;

  Log({this.id, this.subsection, this.item, this.brigade, this.members, this.changedProperty, this.oldValue, this.newValue, this.date, this.user});
  
  factory Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);
  Map<String, dynamic> toJson() => _$LogToJson(this);
}