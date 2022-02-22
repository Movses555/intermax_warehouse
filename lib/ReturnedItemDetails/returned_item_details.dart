import 'package:json_annotation/json_annotation.dart';

part 'returned_item_details.g.dart';

@JsonSerializable()
class ReturnedItem{
  
  @JsonKey(name: 'id')
  // ignore: prefer_typing_uninitialized_variables
  var id;
  
  @JsonKey(name: 'item')
  // ignore: prefer_typing_uninitialized_variables
  var item;
  
  @JsonKey(name: 'description')
  // ignore: prefer_typing_uninitialized_variables
  var description;

  @JsonKey(name: 'brigade')
  // ignore: prefer_typing_uninitialized_variables
  var brigade;
  
  @JsonKey(name: 'brigade_members')
  // ignore: prefer_typing_uninitialized_variables
  var brigadeMembers;
  
  @JsonKey(name: 'date')
  // ignore: prefer_typing_uninitialized_variables
  var date;
  
  @JsonKey(name: 'count')
  // ignore: prefer_typing_uninitialized_variables
  var count;
  
  @JsonKey(name: 'count_option')
  // ignore: prefer_typing_uninitialized_variables
  var countOption;

  ReturnedItem({this.id, this.item, this.description, this.brigade, this.brigadeMembers, this.date, this.count, this.countOption});

  factory ReturnedItem.fromJson(Map<String, dynamic> json) => _$ReturnedItemFromJson(json);
  Map<String, dynamic> toJson() => _$ReturnedItemToJson(this);
}