// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_privileges.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppPrivileges _$AppPrivilegesFromJson(Map<String, dynamic> json) =>
    AppPrivileges(
      seeSettingsSection: json['see_settings_section'],
      addNewUser: json['add_new_user'],
      seeUsersList: json['see_users_list'],
      changeUsersPrivileges: json['change_users_privileges'],
      backupData: json['backup_data'],
      restoreData: json['restore_data'],
      changeUsersPassword: json['change_users_password'],
    );

Map<String, dynamic> _$AppPrivilegesToJson(AppPrivileges instance) =>
    <String, dynamic>{
      'see_settings_section': instance.seeSettingsSection,
      'add_new_user': instance.addNewUser,
      'see_users_list': instance.seeUsersList,
      'change_users_privileges': instance.changeUsersPrivileges,
      'backup_data': instance.backupData,
      'restore_data': instance.restoreData,
      'change_users_password': instance.changeUsersPassword,
    };
