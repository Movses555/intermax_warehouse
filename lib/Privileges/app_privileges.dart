import 'package:json_annotation/json_annotation.dart';

part 'app_privileges.g.dart';

@JsonSerializable()
class AppPrivileges{
   
   @JsonKey(name: 'see_settings_section')
   var seeSettingsSection;

   @JsonKey(name: 'add_new_user') 
   var addNewUser;

   @JsonKey(name: 'see_users_list')
   var seeUsersList;
   
   @JsonKey(name: 'change_users_privileges')
   var changeUsersPrivileges;
   
   @JsonKey(name: 'backup_data')
   var backupData;
   
   @JsonKey(name: 'restore_data')
   var restoreData;
   
   @JsonKey(name: 'change_users_password')
   var changeUsersPassword; 

   AppPrivileges({this.seeSettingsSection, this.addNewUser, this.seeUsersList, this.changeUsersPrivileges, this.backupData, this.restoreData, this.changeUsersPassword});
   factory AppPrivileges.fromJson(Map<String, dynamic> json) => _$AppPrivilegesFromJson(json);

   Map<String, dynamic> toJson() => _$AppPrivilegesToJson(this);
}