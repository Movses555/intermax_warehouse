// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brigade_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Brigades _$BrigadesFromJson(Map<String, dynamic> json) => Brigades(
      brigadeNumber: json['brigade_number'],
      brigadeMembers: json['brigade_members'],
      brigadePhoneNumber: json['brigade_phone_number'],
      brigadePhoto: json['brigade_photo'],
    )..id = json['id'];

Map<String, dynamic> _$BrigadesToJson(Brigades instance) => <String, dynamic>{
      'id': instance.id,
      'brigade_number': instance.brigadeNumber,
      'brigade_members': instance.brigadeMembers,
      'brigade_phone_number': instance.brigadePhoneNumber,
      'brigade_photo': instance.brigadePhoto,
    };
