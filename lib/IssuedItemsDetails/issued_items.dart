import 'package:json_annotation/json_annotation.dart';

part 'issued_items.g.dart';

@JsonSerializable()
class IssuedItems{
  
  @JsonKey(name: 'id')
  // ignore: prefer_typing_uninitialized_variables
  var id;

  @JsonKey(name: 'brigade')
  // ignore: prefer_typing_uninitialized_variables
  var brigade;
  
  @JsonKey(name: 'members')
  // ignore: prefer_typing_uninitialized_variables
  var members;

  @JsonKey(name: 'item')
  // ignore: prefer_typing_uninitialized_variables
  var item;
  
  @JsonKey(name: 'description')
  // ignore: prefer_typing_uninitialized_variables
  var description;
  
  @JsonKey(name: 'date')
  // ignore: prefer_typing_uninitialized_variables
  var date;

  @JsonKey(name: 'count')
  // ignore: prefer_typing_uninitialized_variables
  var count;
  
  @JsonKey(name: 'count_option')
  // ignore: prefer_typing_uninitialized_variables
  var countOption;
  
  @JsonKey(name: 'photo')
  // ignore: prefer_typing_uninitialized_variables
  var photo;
  
  @JsonKey(name: 'user')
  var user;

  IssuedItems({this.id, this.brigade, this.members, this.item, this.date, this.count, this.countOption, this.photo, this.user});

  factory IssuedItems.fromJson(Map<String, dynamic> json) => _$IssuedItemsFromJson(json);
  Map<String, dynamic> toJson() => _$IssuedItemsToJson(this);
}