import 'package:json_annotation/json_annotation.dart';

part 'user_details.g.dart';

@JsonSerializable()
class Users {
  
  @JsonKey(name: 'name')
  var name;

  @JsonKey(name: 'password') 
  var password;
  
  @JsonKey(name: 'status')
  var status;

  
  Users({this.name, this.password, this.status});
  factory Users.fromJson(Map<String, dynamic> json) => _$UsersFromJson(json);

  Map<String, dynamic> toJson() => _$UsersToJson(this);

}