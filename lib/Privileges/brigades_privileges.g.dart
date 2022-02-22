// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brigades_privileges.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrigadesPrivileges _$BrigadesPrivilegesFromJson(Map<String, dynamic> json) =>
    BrigadesPrivileges(
      addBrigade: json['add_brigade'],
      changeBrigade: json['change_brigade'],
      deleteBrigade: json['delete_brigade'],
    );

Map<String, dynamic> _$BrigadesPrivilegesToJson(BrigadesPrivileges instance) =>
    <String, dynamic>{
      'add_brigade': instance.addBrigade,
      'change_brigade': instance.changeBrigade,
      'delete_brigade': instance.deleteBrigade,
    };
