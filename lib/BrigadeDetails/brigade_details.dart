import 'package:json_annotation/json_annotation.dart';

part 'brigade_details.g.dart';

@JsonSerializable()
class Brigades{
  
  @JsonKey(name: 'id')
  // ignore: prefer_typing_uninitialized_variables
  var id;
  
  @JsonKey(name: 'brigade_number')
  // ignore: prefer_typing_uninitialized_variables
  var brigadeNumber;
  
  @JsonKey(name: 'brigade_members')
  // ignore: prefer_typing_uninitialized_variables
  var brigadeMembers;
  
  @JsonKey(name: 'brigade_phone_number')
  // ignore: prefer_typing_uninitialized_variables
  var brigadePhoneNumber;
  
  @JsonKey(name: 'brigade_photo')
  // ignore: prefer_typing_uninitialized_variables
  var brigadePhoto;

  Brigades({this.brigadeNumber, this.brigadeMembers, this.brigadePhoneNumber, this.brigadePhoto});

  factory Brigades.fromJson(Map<String, dynamic> json) => _$BrigadesFromJson(json);
  Map<String, dynamic> toJson() => _$BrigadesToJson(this);
}